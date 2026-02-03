import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pptx/flutter_pptx.dart';
import 'package:path_provider/path_provider.dart';
import 'ai_personality_service.dart';
import 'subscription_service.dart';
import 'file_service.dart';

/// Event types for streaming responses
enum StreamEventType {
  textDelta,    // Partial text chunk
  textDone,     // Text streaming complete
  error,        // Error occurred
  done,         // Full response complete
}

/// Represents a streaming event from OpenAI
class StreamEvent {
  final StreamEventType type;
  final String? textDelta;           // For textDelta events
  final String? fullText;            // For textDone/done events
  final String? title;               // For done events (new conversations)
  final List<String>? images;        // For done events
  final List<String>? files;         // For done events
  final String? error;               // For error events

  StreamEvent({
    required this.type,
    this.textDelta,
    this.fullText,
    this.title,
    this.images,
    this.files,
    this.error,
  });

  factory StreamEvent.textDelta(String delta) => StreamEvent(
    type: StreamEventType.textDelta,
    textDelta: delta,
  );

  factory StreamEvent.textDone(String fullText) => StreamEvent(
    type: StreamEventType.textDone,
    fullText: fullText,
  );

  factory StreamEvent.error(String message) => StreamEvent(
    type: StreamEventType.error,
    error: message,
  );

  factory StreamEvent.done({
    String? fullText,
    String? title,
    List<String>? images,
    List<String>? files,
  }) => StreamEvent(
    type: StreamEventType.done,
    fullText: fullText,
    title: title,
    images: images,
    files: files,
  );
}

class OpenAIService {
  // gpt-5.2 Responses API endpoint
  static const String _baseUrl = 'https://api.openai.com/v1/responses';
  static const String _audioTranscriptionUrl = 'https://api.openai.com/v1/audio/transcriptions';
  static String? _apiKey;
  static String _chatModel = 'gpt-5.2'; // Default value - gpt-5.2 flagship model
  static String _chatMiniModel = 'gpt-5-nano'; // Default value - GPT-5 mini model

  // HTTP timeout configurations - optimized for faster responses
  static const Duration _httpTimeout = Duration(seconds: 180); // 3 minutes for main requests (image generation can be slow)
  static const Duration _followupTimeout = Duration(seconds: 120); // 2 minutes for follow-up requests

  // Persistent HTTP client for connection reuse and better performance
  static http.Client? _httpClient;
  static http.Client get httpClient {
    _httpClient ??= http.Client();
    return _httpClient!;
  }

  // System prompt cache for improved performance
  static final Map<String, String> _promptCache = {};
  static const int _maxCacheSize = 100;

  // Initialize with env variables or direct values
  static Future<void> initialize({String? apiKey}) async {
    _apiKey = apiKey ?? dotenv.env['OPENAI_API_KEY'];
    if (_apiKey == null) {
      //// print('Warning: OpenAI API key not set');
    }

    // Initialize model names from .env
    _chatModel = dotenv.env['OPENAI_CHAT_MODEL'] ?? 'gpt-5.2';
    _chatMiniModel = dotenv.env['OPENAI_CHAT_MINI_MODEL'] ?? 'gpt-5-nano';
  }

  // Helper method for HTTP requests with timeout using persistent client
  static Future<http.Response> _httpPostWithTimeout(
    String url,
    Map<String, String> headers,
    String body,
    Duration timeout,
  ) async {
    return await httpClient
        .post(
          Uri.parse(url),
          headers: headers,
          body: body,
        )
        .timeout(timeout);
  }

  // Cleanup method for disposing HTTP client resources
  static void dispose() {
    _httpClient?.close();
    _httpClient = null;
    _promptCache.clear();
  }

  // Cached system prompt generation for improved performance
  static String _getCachedSystemPrompt({
    String? userName,
    String? characteristicsSummary,
    bool generateTitle = false,
    bool isPremiumUser = false,
    dynamic aiPersonality,
    bool userWantsPresentations = false,
    bool isSimpleQuery = false,
  }) {
    // For simple queries, use a lightweight prompt without complex features
    if (isSimpleQuery && !generateTitle && !userWantsPresentations) {
      return _getQuickSystemPrompt(userName: userName ?? 'User');
    }

    // Create cache key from parameters (simplified for common cases)
    final cacheKey = '${userName ?? 'User'}-$isPremiumUser-$generateTitle-$userWantsPresentations-${characteristicsSummary?.hashCode ?? 0}-${aiPersonality?.hashCode ?? 0}';

    // Check cache first
    if (_promptCache.containsKey(cacheKey)) {
      return _promptCache[cacheKey]!;
    }

    // Generate new prompt if not cached
    final prompt = AIPersonalityService.generateConciseSystemPrompt(
      userName: userName,
      characteristicsSummary: characteristicsSummary,
      generateTitle: generateTitle,
      isPremiumUser: isPremiumUser,
      aiPersonality: aiPersonality,
      userWantsPresentations: userWantsPresentations,
    );

    // Cache management - remove oldest entries if cache is full
    if (_promptCache.length >= _maxCacheSize) {
      final firstKey = _promptCache.keys.first;
      _promptCache.remove(firstKey);
    }

    _promptCache[cacheKey] = prompt;
    return prompt;
  }

  // Lightweight system prompt for simple queries
  static String _getQuickSystemPrompt({required String userName}) {
    return """You are HowAI Agent, a friendly and helpful AI assistant for $userName.

Key traits:
- Be concise and direct for quick questions
- Provide accurate information
- Be conversational and natural
- Keep responses brief unless detail is needed

Current date: ${DateTime.now().toIso8601String().split('T')[0]}""";
  }

  // New method for AI chat responses with subscription support
  // Uses gpt-5.2 Responses API with reasoning.effort parameter
  Future<Map<String, dynamic>?> generateChatResponse({
    required String message,
    required List<Map<String, dynamic>> history,
    String? userName,
    Map<String, dynamic>? userCharacteristics,
    List<XFile>? attachments,
    List<PlatformFile>? fileAttachments, // Add file attachments support
    bool generateTitle = false,
    // New subscription-related parameters
    bool isPremiumUser = false,
    bool allowWebSearch = true,
    bool allowImageGeneration = true,
    bool isDeepResearch = false, // Deep research mode uses reasoning.effort: high
    SubscriptionService? subscriptionService, // Add subscription service
    dynamic aiPersonality, // Add AI personality parameter
  }) async {
    // Determine which model to use based on subscription and attachments
    String modelToUse;

    if (attachments != null && attachments.isNotEmpty) {
      // Always use the main model for image analysis regardless of subscription
      // because mini models don't support vision as well
      modelToUse = _chatModel;
      //// print('[OpenAIService] Using main model ($_chatModel) for image analysis');
    } else if (isPremiumUser) {
      // Premium users get the main model for text-only conversations
      modelToUse = _chatModel;
      //// print('[OpenAIService] Using main model ($_chatModel) for premium user');
    } else {
      // Free users get the mini model for text-only conversations
      modelToUse = _chatMiniModel;
      //// print('[OpenAIService] Using mini model ($_chatMiniModel) for free user');
    }

    // Deep research mode uses high reasoning effort
    bool isDeepResearchMode = isDeepResearch;

    // Build user characteristics summary
    String characteristicsSummary = "";
    if (userCharacteristics != null && userCharacteristics.isNotEmpty) {
      characteristicsSummary = "Here is what I know about the user based on our previous conversations:\n";
      userCharacteristics.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          characteristicsSummary += "- $key: $value\n";
        }
      });
      characteristicsSummary += "\n";
    }

    // Quick intent detection for PowerPoint presentations
    // Disabled - not practical for mobile apps, adds latency for minimal benefit
    bool userWantsPresentations = false;
    // if (history.isNotEmpty) {
    //   userWantsPresentations = await detectPresentationIntent(
    //     recentMessages: history,
    //     currentUserMessage: message,
    //   );
    // }

    // Generate system prompt using cached approach for better performance
    String systemPrompt = _getCachedSystemPrompt(
      userName: userName,
      characteristicsSummary: characteristicsSummary,
      generateTitle: generateTitle,
      isPremiumUser: allowWebSearch,
      aiPersonality: aiPersonality,
      userWantsPresentations: userWantsPresentations,
      isSimpleQuery: _isSimpleQuery(message),
    );

    // Add special instructions for deep research mode (gpt-5.2 with high reasoning effort)
    if (isDeepResearchMode) {
      systemPrompt +=
          "\n\nDEEP RESEARCH MODE: You are using gpt-5.2 with high reasoning effort for thorough analysis. Provide deep, step-by-step logical analysis with comprehensive insights, multiple perspectives, and thorough explanations. You have access to web search for current information, image generation, and other tools - use them strategically to enhance your reasoning and provide the most accurate, up-to-date analysis possible. For stock or financial questions, prioritize using web search to get current market data.";

      // CRITICAL: Tell model NOT to include thinking process in output
      systemPrompt +=
          "\n\nCRITICAL OUTPUT FORMAT: Do NOT include your thinking process, planning steps, or internal reasoning in your response. Do NOT say things like 'I'll search for...', 'Let me look up...', 'I need to...', or describe what you're about to do. Do NOT include raw JSON data from tool calls in your response. Just provide the final, polished answer directly. Start your response with the actual content - your conclusion, analysis, or answer. Your internal reasoning is handled separately.";

      // Special handling for title generation in deep research mode
      if (generateTitle) {
        systemPrompt +=
            "\n\nIMPORTANT: If this is the first message of a conversation, provide BOTH a conversation title AND your full response. Format like this: Start with {\"title\": \"Your Title\"} followed by your complete analysis. Do not provide only the title - always include your full, detailed response after the title JSON.";
      }
    }

    // Debug: // print personality summary
    //// print('[AIPersonality] ${AIPersonalityService.getPersonalitySummary()}');

    // Build input array: conversation history + current message (NO system prompt - that goes in 'instructions')
    final List<Map<String, dynamic>> inputMessages = [];

    // Add conversation history
    for (var entry in history) {
      inputMessages.add(entry);
    }

    // If there are attachments (images or files), build a content block
    if ((attachments != null && attachments.isNotEmpty) || (fileAttachments != null && fileAttachments.isNotEmpty)) {
      List<Map<String, dynamic>> contentBlocks = [];

      // Add the text message as a block if not empty
      // Responses API uses 'input_text' instead of 'text'
      if (message.trim().isNotEmpty) {
        contentBlocks.add({
          'type': 'input_text',
          'text': message,
        });
      }

      // Add image attachments
      if (attachments != null && attachments.isNotEmpty) {
        for (final xfile in attachments) {
          try {
            // Keep original resolution, just compress quality to reduce file size
            final compressedBytes = await FlutterImageCompress.compressWithFile(
              xfile.path,
              quality: 80,
              format: CompressFormat.jpeg,
            );
            if (compressedBytes != null) {
              final base64Image = base64Encode(compressedBytes);
              // Responses API uses 'input_image' instead of 'image_url'
              contentBlocks.add({
                'type': 'input_image',
                'image_url': 'data:image/jpeg;base64,$base64Image',
              });
            }
          } catch (e) {
            //// print('Error compressing/encoding image: $e');
          }
        }
      }

      // Add file attachments using text extraction
      if (fileAttachments != null && fileAttachments.isNotEmpty) {
        //// print('[OpenAIService] Processing ${fileAttachments.length} file attachments');

        for (final file in fileAttachments) {
          try {
            //// print('[OpenAIService] Processing file: ${file.name} (${FileService.formatFileSize(file.size)})');

            // Extract text content instead of base64 encoding
            final extractedText = await FileService.extractTextFromFile(file);
            if (extractedText != null && extractedText.isNotEmpty) {
              //// print('[OpenAIService] Successfully extracted text from ${file.name} (${extractedText.length} chars)');

              // Add file as a text block with extracted content for OpenAI to analyze
              final fileContent = '''

📄 **File Analysis: ${file.name}** (${FileService.formatFileSize(file.size)})
File Type: ${file.extension?.toUpperCase() ?? 'Unknown'}

**Extracted Content:**
$extractedText

Please analyze this file content based on the user's request.
''';

              // Find existing text block and append file content, or create new text block
              bool foundTextBlock = false;
              for (int i = 0; i < contentBlocks.length; i++) {
                if (contentBlocks[i]['type'] == 'text') {
                  contentBlocks[i]['text'] += fileContent;
                  foundTextBlock = true;
                  break;
                }
              }

              if (!foundTextBlock) {
                contentBlocks.add({
                  'type': 'input_text',
                  'text': fileContent,
                });
              }

              //// print('[OpenAIService] Added extracted file content to message (total content blocks: ${contentBlocks.length})');
            } else {
              //// print('[OpenAIService] Failed to extract text from file ${file.name}');

              // Add a fallback message indicating the file type
              final fallbackContent = '''

📄 **File: ${file.name}** (${FileService.formatFileSize(file.size)})
File Type: ${file.extension?.toUpperCase() ?? 'Unknown'}

Note: Could not extract text content from this file. Please describe what you'd like me to help you with regarding this file.
''';

              // Add fallback content
              bool foundTextBlock = false;
              for (int i = 0; i < contentBlocks.length; i++) {
                if (contentBlocks[i]['type'] == 'text') {
                  contentBlocks[i]['text'] += fallbackContent;
                  foundTextBlock = true;
                  break;
                }
              }

              if (!foundTextBlock) {
                contentBlocks.add({
                  'type': 'input_text',
                  'text': fallbackContent,
                });
              }
            }
          } catch (e) {
            //// print('[OpenAIService] Error processing file ${file.name}: $e');
          }
        }
      } else {
        //// print('[OpenAIService] No file attachments to process');
      }

      inputMessages.add({
        'role': 'user',
        'content': contentBlocks,
      });
    } else {
      // Add the current message as plain text
      inputMessages.add({'role': 'user', 'content': message});
    }

    try {
      final stopwatch = Stopwatch()..start();

      // Build tools list based on permissions
      // gpt-5.2 supports both built-in tools and function calling
      List<Map<String, dynamic>> tools = [];

      // Add built-in tools - OpenAI handles these natively
      {
        // Image generation - built-in tool (OpenAI handles DALL-E internally)
        if (allowImageGeneration) {
          tools.add({'type': 'image_generation'});
        }

        // Web search - built-in tool (OpenAI handles search internally)
        if (allowWebSearch) {
          tools.add({'type': 'web_search'});
        }

        // PPTX generation - only add if user wants presentations
        if (userWantsPresentations) {
          tools.add({
            'type': 'function',
            'name': 'generate_pptx',
            'description':
                'Generate and create a PowerPoint presentation (PPTX file) when user explicitly requests creating presentations, slides, PPTX files, PowerPoint files, or asks to generate/create/make a presentation. This function creates the actual downloadable PPTX file.',
            'parameters': {
              'type': 'object',
              'properties': {
                'title': {'type': 'string', 'description': 'Main title of the presentation'},
                'slides': {
                  'type': 'array',
                  'description': 'Array of slide objects',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'title': {'type': 'string', 'description': 'Slide title'},
                      'content': {'type': 'string', 'description': 'Main slide content or bullet points (use \\n for new lines)'},
                      'type': {
                        'type': 'string',
                        'enum': ['title', 'content', 'bullets'],
                        'description': 'Type of slide'
                      },
                    },
                    'required': ['title', 'content', 'type']
                  }
                },
                'theme': {
                  'type': 'string',
                  'enum': ['professional', 'modern', 'minimal'],
                  'description': 'Presentation theme/style'
                },
                'author': {'type': 'string', 'description': 'Author name for the presentation'}
              },
              'required': ['title', 'slides']
            }
          });
        }
      } // Close the tools block

      // Detect if this is a simple/small talk query for faster, shorter responses
      final isSimpleQuery = _isSimpleQuery(message);

      // Configure response length based on query complexity
      int maxTokens;
      String reasoningEffort;

      if (isDeepResearchMode) {
        maxTokens = 3000;
        reasoningEffort = 'high';
      } else if (isSimpleQuery) {
        maxTokens = 500; // Short responses for small talk
        reasoningEffort = 'low';
      } else {
        maxTokens = 1500;
        reasoningEffort = 'low'; // Optimized for speed
      }

      // Configure request parameters for gpt-5.2 Responses API
      // Format matches Teams bot: instructions separate from input, no tool_choice
      final requestPayload = {
        'model': modelToUse,
        'instructions': systemPrompt, // System prompt as separate field (not in input)
        'input': inputMessages, // Only conversation history + current user message
        'max_output_tokens': maxTokens,
        'reasoning': {
          'effort': reasoningEffort,
        },
        // Note: temperature is NOT supported with reasoning.effort != 'none'
      };

      // Only add tools if we have any (no explicit tool_choice needed)
      if (tools.isNotEmpty) {
        requestPayload['tools'] = tools;
      }

      //// print('[OpenAIService] Sending request to $_baseUrl with model: $modelToUse');
      //// print('[OpenAIService] Available tools: ${tools.map((t) => t['name']).join(', ')}');
      //// print('[OpenAIService] System prompt length: ${systemPrompt.length} chars');
      //// print('[OpenAIService] UserWantsPresentations: $userWantsPresentations');

      // print('[OpenAIService] DEBUG - Request Debug:');
      // print('[OpenAIService] - User message: "${message.substring(0, message.length > 100 ? 100 : message.length)}..."');
      // print('[OpenAIService] - allowWebSearch: $allowWebSearch');
      // print('[OpenAIService] - Available tools: ${tools.map((t) => t['name']).join(', ')}');
      // print('[OpenAIService] - Model: $modelToUse');
      // print('[OpenAIService] - isPremiumUser: $isPremiumUser');
      // print('[OpenAIService] - isDeepResearch: $isDeepResearch');
      if (isDeepResearchMode) {
        // print('[OpenAIService] 🧠 DEEP RESEARCH MODE ACTIVE - gpt-5.2 with high reasoning effort');
        // print('[OpenAIService] 🔧 Has access to ${tools.length} tools: ${tools.map((t) => t['type']).join(', ')}');
      }

      // Debug: Print request payload for troubleshooting
      print('[OpenAIService] 📤 Request to $_baseUrl');
      print('[OpenAIService] 📤 Model: $modelToUse');
      print('[OpenAIService] 📤 API Key present: ${_apiKey != null}');

      final response = await _httpPostWithTimeout(
        _baseUrl,
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        jsonEncode(requestPayload),
        _httpTimeout,
      );

      final elapsed = stopwatch.elapsedMilliseconds;
      print('[OpenAIService] Response status: ${response.statusCode}');
      print('[OpenAIService] Response time: ${elapsed}ms');
      if (response.statusCode != 200) {
        print('[OpenAIService] ❌ ERROR RESPONSE: ${response.body}');

        // Special handling for deep research mode errors
        if (isDeepResearchMode) {
          // print('[OpenAIService] 🧠 gpt-5.2 deep research mode error detected');
        }
      } else {
        // print('[OpenAIService] ✅ Success - Raw response preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? textContent;
        String? conversationTitle;
        List<String> imageUrls = [];
        List<String> filePaths = [];
        List<dynamic>? toolCalls;

        // Debug: Print raw response structure
        print('[OpenAIService] 📥 Raw response keys: ${data.keys.toList()}');
        print('[OpenAIService] 📥 Response status: ${data['status']}');
        if (data['status'] != 'completed') {
          print('[OpenAIService] ⚠️ Response not completed! Status: ${data['status']}');
          print('[OpenAIService] 📥 incomplete_details: ${data['incomplete_details']}');
          print('[OpenAIService] 📥 error: ${data['error']}');
        }
        if (data.containsKey('output')) {
          print('[OpenAIService] 📥 Output is List: ${data['output'] is List}');
          if (data['output'] is List && (data['output'] as List).isNotEmpty) {
            print('[OpenAIService] 📥 Output items: ${(data['output'] as List).map((e) => e['type']).toList()}');
          }
        }

        // Parse Responses API format
        // Prefer parsing the 'output' array to get only message content (not reasoning)
        if (data.containsKey('output') && data['output'] is List) {
          // Parse output array - extract message content, built-in tool results, and function calls
          for (final item in data['output']) {
            final itemType = item['type'];

            if (itemType == 'reasoning') {
              // Skip reasoning output - this is chain-of-thought, not for display
              print('[OpenAIService] 📥 Skipping reasoning output');
              continue;
            } else if (itemType == 'message' && item['content'] != null) {
              for (final content in item['content']) {
                if (content['type'] == 'output_text' && content['text'] != null) {
                  textContent = (textContent ?? '') + content['text'];
                } else if (content['type'] == 'text' && content['text'] != null) {
                  textContent = (textContent ?? '') + content['text'];
                } else if (content['type'] == 'tool_use') {
                  // Collect tool calls
                  toolCalls ??= [];
                  toolCalls.add(content);
                } else if (content['type'] == 'image' && content['image_url'] != null) {
                  // Built-in image generation returns images in message content
                  print('[OpenAIService] 📥 Found image in message content');
                  imageUrls.add(content['image_url']);
                }
              }
            } else if (itemType == 'function_call') {
              // Handle custom function calls (e.g., generate_pptx)
              print('[OpenAIService] 📥 Found function_call in output: ${item['name']}');
              toolCalls ??= [];
              toolCalls.add(item);
            } else if (itemType == 'image_generation_call') {
              // Built-in image generation tool result - returns base64 in 'result' field
              print('[OpenAIService] 📥 Found built-in image_generation_call');
              print('[OpenAIService] 📥 image_generation_call status: ${item['status']}');
              print('[OpenAIService] 📥 image_generation_call keys: ${item.keys.toList()}');

              if (item['result'] != null) {
                String base64Data = item['result'].toString();
                print('[OpenAIService] 📥 Got image result, length: ${base64Data.length}');

                // Remove data URI prefix if present (e.g., "data:image/png;base64,")
                if (base64Data.contains('base64,')) {
                  base64Data = base64Data.split('base64,').last;
                }

                // Convert to data URL for Flutter to display
                final dataUrl = 'data:image/png;base64,$base64Data';
                imageUrls.add(dataUrl);
                print('[OpenAIService] 📥 Added base64 image to imageUrls');
              } else {
                print('[OpenAIService] ⚠️ image_generation_call has no result field');
                print('[OpenAIService] 📥 Status: ${item['status']}, Error: ${item['error']}');
              }
            } else if (itemType == 'web_search_call') {
              // Built-in web search tool result - results are handled automatically by OpenAI
              print('[OpenAIService] 📥 Found built-in web_search_call - results integrated into response');
              // No manual handling needed - OpenAI incorporates search results into the response
            } else {
              print('[OpenAIService] 📥 Unknown item type in output: $itemType');
            }
          }
        }
        // Fallback to output_text only if output array didn't provide content
        if (textContent == null && data.containsKey('output_text') && data['output_text'] != null) {
          textContent = data['output_text'];
          print('[OpenAIService] 📥 Got output_text as fallback');
        }
        // Fallback: Check for Chat Completions format (for backwards compatibility)
        else if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          final choice = data['choices'][0];
          final messageData = choice['message'];
          if (messageData['content'] != null) {
            textContent = messageData['content'];
          }
          if (messageData['tool_calls'] != null) {
            toolCalls = messageData['tool_calls'];
          }
        }

        // Parse text content for title extraction
        if (textContent != null && textContent.isNotEmpty) {
          // Extract title if this is the first message of a conversation
          if (generateTitle) {
            // Look for JSON at the beginning of the response
            final titleMatch = RegExp(r'^\s*\{\s*"title"\s*:\s*"([^"]+)"\s*\}').firstMatch(textContent);
            if (titleMatch != null && titleMatch.groupCount >= 1) {
              conversationTitle = titleMatch.group(1);
              // Remove the JSON from the beginning of the response
              textContent = textContent.substring(titleMatch.end).trim();
            } else {
              // Fallback: try to extract any JSON object with a title key
              final jsonMatch = RegExp(r'\{\s*"title"\s*:\s*"([^"]+)"\s*\}').firstMatch(textContent);
              if (jsonMatch != null && jsonMatch.groupCount >= 1) {
                conversationTitle = jsonMatch.group(1);
                // Remove the JSON from the response
                textContent = textContent.replaceFirst(jsonMatch.group(0)!, '').trim();
              }
            }
          }
        }

        // Handle custom function tool calls (only generate_pptx now - web_search and image_generation are built-in)
        if (toolCalls != null && toolCalls.isNotEmpty) {
          print('[OpenAIService] 🔧 AI made ${toolCalls.length} tool calls');
          print('[OpenAIService] 🔧 Tool calls: ${toolCalls.map((t) => t.toString()).toList()}');

          List<Map<String, dynamic>> toolResults = [];

          // Process custom function calls (generate_pptx only)
          for (final toolCall in toolCalls) {
            // Handle both Responses API and Chat Completions API formats
            String? functionName;
            dynamic functionArgs;
            String? toolCallId;

            if (toolCall['type'] == 'function' && toolCall['function'] != null) {
              // Chat Completions format
              functionName = toolCall['function']['name'];
              functionArgs = toolCall['function']['arguments'];
              toolCallId = toolCall['id'];
            } else if (toolCall['type'] == 'function_call') {
              // Responses API format
              functionName = toolCall['name'];
              functionArgs = toolCall['arguments'];
              toolCallId = toolCall['call_id'] ?? toolCall['id'];
            } else if (toolCall['name'] != null) {
              // Simple tool call format
              functionName = toolCall['name'];
              functionArgs = toolCall['arguments'];
              toolCallId = toolCall['call_id'] ?? toolCall['id'] ?? 'tool_${DateTime.now().millisecondsSinceEpoch}';
            }

            print('[OpenAIService] 🔧 Processing tool call: $functionName, id: $toolCallId');

            // Handle PPTX generation (custom function - the only one we handle manually now)
            if (functionName == 'generate_pptx' && functionArgs != null) {
                Map<String, dynamic> argMap;
                if (functionArgs is String) {
                  argMap = jsonDecode(functionArgs);
                } else {
                  argMap = functionArgs;
                }

                final title = argMap['title'] as String?;
                final slides = argMap['slides'] as List?;
                final theme = argMap['theme'] as String? ?? 'professional';
                final author = argMap['author'] as String? ?? 'HaoGPT';

                if (title != null && slides != null && slides.isNotEmpty) {
                  //// print('[OpenAIService] Generating PPTX with title: $title, slides: ${slides.length}');

                  try {
                    final pptxPath = await _generatePptxFile(
                      title: title,
                      slides: slides.cast<Map<String, dynamic>>(),
                      theme: theme,
                      author: author,
                    );

                    if (pptxPath != null) {
                      toolResults.add({
                        'role': 'tool',
                        'tool_call_id': toolCallId,
                        'content': jsonEncode({'pptx_path': pptxPath, 'message': 'PPTX presentation generated successfully! File ready.'}),
                      });
                    } else {
                      toolResults.add({
                        'role': 'tool',
                        'tool_call_id': toolCallId,
                        'content': jsonEncode({'error': 'Failed to generate PPTX file'}),
                      });
                    }
                  } catch (e) {
                    //// print('[OpenAIService] Error generating PPTX: $e');
                    toolResults.add({
                      'role': 'tool',
                      'tool_call_id': toolCallId,
                      'content': jsonEncode({'error': 'Error generating PPTX: $e'}),
                    });
                  }
                }
            }
          }

          // Extract file paths from tool results before sending follow-up
          for (final toolResult in toolResults) {
            try {
              final toolContent = jsonDecode(toolResult['content']);
              if (toolContent['pptx_path'] != null) {
                filePaths.add(toolContent['pptx_path']);
              }
            } catch (e) {
              // Ignore parsing errors
            }
          }

          // If we have tool results, send them all together in one follow-up request
          if (toolResults.isNotEmpty) {
            print('[OpenAIService] 📤 Preparing follow-up with ${toolResults.length} tool results');

            // For Responses API, convert tool results to function_call_output format
            List<Map<String, dynamic>> functionCallOutputs = [];
            for (final toolResult in toolResults) {
              functionCallOutputs.add({
                'type': 'function_call_output',
                'call_id': toolResult['tool_call_id'],
                'output': toolResult['content'],
              });
            }

            // Build follow-up payload with gpt-5.2 Responses API format
            // Use previous_response_id to continue the conversation
            final followupPayload = {
              'model': modelToUse,
              'input': functionCallOutputs, // Send function call outputs directly
              'previous_response_id': data['id'], // Reference the previous response
              'max_output_tokens': 2000,
              'reasoning': {
                'effort': isDeepResearchMode ? 'high' : 'low',
              },
            };

            print('[OpenAIService] 📤 Follow-up using previous_response_id: ${data['id']}');

            print('[OpenAIService] 📤 Sending ${toolResults.length} tool results to OpenAI');

            // Debug: Show follow-up payload for deep research mode
            if (isDeepResearchMode) {
              // print('[OpenAIService] 🧠 gpt-5.2 Follow-up payload preview:');
              // print('[OpenAIService] - Model: ${followupPayload['model']}');
              // print('[OpenAIService] - Input count: ${followupMessages.length}');
              // print('[OpenAIService] - Has tools: ${followupPayload.containsKey('tools')}');
              // print('[OpenAIService] - Parameters: ${followupPayload.keys.toList()}');
            }

            // Send follow-up with retry for 500 errors
            http.Response followupResponse;
            int retryCount = 0;
            const maxRetries = 2;

            do {
              followupResponse = await _httpPostWithTimeout(
                _baseUrl,
                {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $_apiKey',
                },
                jsonEncode(followupPayload),
                _followupTimeout,
              );

              if (followupResponse.statusCode == 500 && retryCount < maxRetries) {
                retryCount++;
                print('[OpenAIService] ⚠️ Server error (500), retrying... (attempt $retryCount/$maxRetries)');
                await Future.delayed(Duration(seconds: 2 * retryCount)); // Exponential backoff
              } else {
                break;
              }
            } while (retryCount <= maxRetries);

            print('[OpenAIService] 📥 Follow-up response status: ${followupResponse.statusCode}');
            if (followupResponse.statusCode != 200) {
              print('[OpenAIService] ❌ Follow-up error: ${followupResponse.body}');
            }

            if (followupResponse.statusCode == 200) {
              final followupData = jsonDecode(followupResponse.body);
              String? followupTextContent;
              List<dynamic>? followupToolCalls;

              // Debug: Print follow-up response structure
              print('[OpenAIService] 📥 Follow-up response keys: ${followupData.keys.toList()}');
              if (followupData.containsKey('output_text')) {
                print('[OpenAIService] 📥 Follow-up has output_text: ${followupData['output_text']?.toString().substring(0, followupData['output_text'].toString().length > 100 ? 100 : followupData['output_text'].toString().length)}...');
              }
              if (followupData.containsKey('output') && followupData['output'] is List) {
                final outputItems = (followupData['output'] as List).map((e) => e['type']).toList();
                print('[OpenAIService] 📥 Follow-up output items: $outputItems');
              }

              // Parse Responses API format for follow-up - skip reasoning output
              if (followupData.containsKey('output') && followupData['output'] is List) {
                for (final item in followupData['output']) {
                  final itemType = item['type'];

                  if (itemType == 'reasoning') {
                    // Skip reasoning output - this is chain-of-thought, not for display
                    print('[OpenAIService] 📥 Skipping follow-up reasoning output');
                    continue;
                  } else if (itemType == 'message' && item['content'] != null) {
                    print('[OpenAIService] 📥 Found message item, content types: ${(item['content'] as List).map((c) => c['type']).toList()}');
                    for (final content in item['content']) {
                      if (content['type'] == 'output_text' && content['text'] != null) {
                        followupTextContent = (followupTextContent ?? '') + content['text'];
                        print('[OpenAIService] 📥 Got text from output_text in message');
                      } else if (content['type'] == 'text' && content['text'] != null) {
                        // Also check for 'text' type (alternative format)
                        followupTextContent = (followupTextContent ?? '') + content['text'];
                        print('[OpenAIService] 📥 Got text from text type in message');
                      } else if (content['type'] == 'tool_use') {
                        followupToolCalls ??= [];
                        followupToolCalls.add(content);
                      }
                    }
                  } else if (itemType == 'function_call') {
                    followupToolCalls ??= [];
                    followupToolCalls.add(item);
                  }
                }
              }
              // Fallback to output_text only if output array didn't provide content
              if (followupTextContent == null && followupData.containsKey('output_text') && followupData['output_text'] != null) {
                followupTextContent = followupData['output_text'];
                print('[OpenAIService] 📥 Got follow-up text from output_text as fallback');
              }
              // Fallback: Check for Chat Completions format
              else if (followupData.containsKey('choices') && followupData['choices'].isNotEmpty) {
                final followupChoice = followupData['choices'][0];
                final followupMessage = followupChoice['message'];
                followupTextContent = followupMessage['content'];
                if (followupMessage['tool_calls'] != null) {
                  followupToolCalls = followupMessage['tool_calls'];
                }
              }

              print('[OpenAIService] 📥 Follow-up parsed text: ${followupTextContent?.substring(0, followupTextContent.length > 100 ? 100 : followupTextContent.length) ?? "NULL"}...');

              // Update the main textContent with follow-up response
              if (followupTextContent != null && followupTextContent.isNotEmpty) {
                // Extract title from follow-up if this is a new conversation
                if (generateTitle && conversationTitle == null) {
                  final titleMatch = RegExp(r'\{\s*"title"\s*:\s*"([^"]+)"\s*\}').firstMatch(followupTextContent);
                  if (titleMatch != null && titleMatch.groupCount >= 1) {
                    conversationTitle = titleMatch.group(1);
                    // Remove the title JSON from the response
                    followupTextContent = followupTextContent.replaceFirst(titleMatch.group(0)!, '').trim();
                    print('[OpenAIService] 📥 Extracted title from follow-up: $conversationTitle');
                  }
                }

                // Clean up AI thinking/planning text that shouldn't be shown to users
                followupTextContent = _cleanupAIThinkingText(followupTextContent);

                // Extract only the final answer portion - look for the actual answer after all tool processing
                followupTextContent = _extractFinalAnswer(followupTextContent);

                textContent = followupTextContent;
                print('[OpenAIService] ✅ Updated textContent with follow-up response');
              }

              // Check if there are additional tool calls in the follow-up response
              if (followupToolCalls != null && followupToolCalls.isNotEmpty) {
                //// print('[OpenAIService] Follow-up response contains additional tool calls');

                // Process additional tool calls (for multi-step workflows like search -> PPTX)
                List<Map<String, dynamic>> additionalToolResults = [];

                for (final toolCall in followupToolCalls) {
                  // Handle both API formats
                  String? funcName;
                  dynamic funcArgs;
                  String? tcId;

                  if (toolCall['type'] == 'function' && toolCall['function'] != null) {
                    funcName = toolCall['function']['name'];
                    funcArgs = toolCall['function']['arguments'];
                    tcId = toolCall['id'];
                  } else if (toolCall['type'] == 'function_call' || toolCall['name'] != null) {
                    funcName = toolCall['name'];
                    funcArgs = toolCall['arguments'];
                    tcId = toolCall['call_id'] ?? toolCall['id'] ?? 'tool_${DateTime.now().millisecondsSinceEpoch}';
                  }

                  // Handle PPTX generation in follow-up
                  if (funcName == 'generate_pptx' && funcArgs != null) {
                    Map<String, dynamic> argMap;
                    if (funcArgs is String) {
                      argMap = jsonDecode(funcArgs);
                    } else {
                      argMap = funcArgs;
                    }

                    final title = argMap['title'] as String?;
                    final slides = argMap['slides'] as List?;
                    final theme = argMap['theme'] as String? ?? 'professional';
                    final author = argMap['author'] as String? ?? 'HaoGPT';

                    if (title != null && slides != null && slides.isNotEmpty) {
                      //// print('[OpenAIService] Generating PPTX in follow-up with title: $title, slides: ${slides.length}');

                      try {
                        final pptxPath = await _generatePptxFile(
                          title: title,
                          slides: slides.cast<Map<String, dynamic>>(),
                          theme: theme,
                          author: author,
                        );

                        if (pptxPath != null) {
                          filePaths.add(pptxPath); // Add to file paths
                          additionalToolResults.add({
                            'role': 'tool',
                            'tool_call_id': tcId,
                            'content': jsonEncode({'pptx_path': pptxPath, 'message': 'PPTX presentation generated successfully! File ready.'}),
                          });
                        } else {
                          additionalToolResults.add({
                            'role': 'tool',
                            'tool_call_id': tcId,
                            'content': jsonEncode({'error': 'Failed to generate PPTX file'}),
                          });
                        }
                      } catch (e) {
                        //// print('[OpenAIService] Error generating PPTX in follow-up: $e');
                        additionalToolResults.add({
                          'role': 'tool',
                          'tool_call_id': tcId,
                          'content': jsonEncode({'error': 'Error generating PPTX: $e'}),
                        });
                      }
                    }
                  }
                }

                // If we have additional tool results, send another follow-up
                if (additionalToolResults.isNotEmpty) {
                  // Convert tool results to function_call_output format for Responses API
                  List<Map<String, dynamic>> secondFunctionCallOutputs = [];
                  for (final toolResult in additionalToolResults) {
                    secondFunctionCallOutputs.add({
                      'type': 'function_call_output',
                      'call_id': toolResult['tool_call_id'],
                      'output': toolResult['content'],
                    });
                  }

                  final secondFollowupPayload = {
                    'model': modelToUse,
                    'input': secondFunctionCallOutputs,
                    'previous_response_id': followupData['id'], // Reference the follow-up response
                    'max_output_tokens': 2000,
                    'reasoning': {
                      'effort': isDeepResearchMode ? 'high' : 'low',
                    },
                  };

                  //// print('[OpenAIService] Sending second follow-up for PPTX generation');
                  final secondFollowupResponse = await _httpPostWithTimeout(
                    _baseUrl,
                    {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $_apiKey',
                    },
                    jsonEncode(secondFollowupPayload),
                    _followupTimeout,
                  );

                  if (secondFollowupResponse.statusCode == 200) {
                    final secondFollowupData = jsonDecode(secondFollowupResponse.body);
                    // Parse Responses API format
                    if (secondFollowupData.containsKey('output_text') && secondFollowupData['output_text'] != null) {
                      textContent = secondFollowupData['output_text'];
                      //// print('[OpenAIService] Successfully extracted second follow-up content for PPTX generation');
                    } else if (secondFollowupData.containsKey('output') && secondFollowupData['output'] is List) {
                      for (final item in secondFollowupData['output']) {
                        if (item['type'] == 'message' && item['content'] != null) {
                          for (final content in item['content']) {
                            if (content['type'] == 'output_text' && content['text'] != null) {
                              textContent = (textContent ?? '') + content['text'];
                            }
                          }
                        }
                      }
                    }
                    // Fallback: Check for Chat Completions format
                    else if (secondFollowupData.containsKey('choices') && secondFollowupData['choices'].isNotEmpty) {
                      final secondFollowupChoice = secondFollowupData['choices'][0];
                      final secondFollowupMessage = secondFollowupChoice['message'];
                      if (secondFollowupMessage['content'] != null && secondFollowupMessage['content'].toString().trim().isNotEmpty) {
                        textContent = secondFollowupMessage['content'];
                      }
                    }
                  }
                }
              }

              // Extract text content from follow-up if not already set by second follow-up
              if (textContent == null && followupTextContent != null && followupTextContent.trim().isNotEmpty) {
                textContent = followupTextContent;
                // print('[OpenAIService] Successfully extracted follow-up content: ${textContent?.substring(0, min(200, textContent?.length ?? 0)) ?? 'null'}...');

                // Debug: Check if only returned a title in deep research mode
                if (isDeepResearchMode && generateTitle && textContent != null) {
                  // print('[OpenAIService] 🧠 gpt-5.2 title generation - Content preview: "${textContent.substring(0, min(100, textContent.length))}..."');
                  if (textContent.trim().startsWith('{"title":') && textContent.length < 100) {
                    // print('[OpenAIService] ⚠️ gpt-5.2 seems to have returned only title JSON, missing full content');
                  }
                }

                // Check if AI completed the workflow properly by looking for actual tool calls
                // If we have search results but no PPTX file was generated, continue the workflow
                // BUT ONLY if the user actually wanted presentations
                bool hasSearchResults = toolResults.any((result) => result['role'] == 'tool' && result['content'] != null);
                bool hasPptxGeneration = followupToolCalls != null && followupToolCalls.any((call) => call['function']?['name'] == 'generate_pptx' || call['name'] == 'generate_pptx');

                if (userWantsPresentations && hasSearchResults && !hasPptxGeneration && filePaths.isEmpty) {
                  //// print('[OpenAIService] Detected incomplete workflow - AI searched but did not generate PPTX file');

                  // Send additional prompt to complete PPTX generation using Responses API format
                  final completionPayload = {
                    'model': modelToUse,
                    'input': [
                      {
                        'role': 'user',
                        'content':
                            'You performed the search but did not call the generate_pptx function. Please now use the generate_pptx function to create the actual PowerPoint file with the search results you gathered. I need the downloadable PPTX file, not just a description.',
                      }
                    ],
                    'previous_response_id': followupData['id'], // Continue from the follow-up response
                    'tools': tools,
                    'max_output_tokens': 2000,
                    'reasoning': {
                      'effort': isDeepResearchMode ? 'high' : 'low',
                    },
                  };

                  //// print('[OpenAIService] Sending completion prompt for PPTX generation');
                  final completionResponse = await _httpPostWithTimeout(
                    _baseUrl,
                    {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $_apiKey',
                    },
                    jsonEncode(completionPayload),
                    _followupTimeout,
                  );

                  if (completionResponse.statusCode == 200) {
                    final completionData = jsonDecode(completionResponse.body);
                    String? completionTextContent;
                    List<dynamic>? completionToolCalls;

                    // Parse Responses API format for completion response
                    if (completionData.containsKey('output_text') && completionData['output_text'] != null) {
                      completionTextContent = completionData['output_text'];
                    } else if (completionData.containsKey('output') && completionData['output'] is List) {
                      for (final item in completionData['output']) {
                        if (item['type'] == 'message' && item['content'] != null) {
                          for (final content in item['content']) {
                            if (content['type'] == 'output_text' && content['text'] != null) {
                              completionTextContent = (completionTextContent ?? '') + content['text'];
                            } else if (content['type'] == 'tool_use') {
                              completionToolCalls ??= [];
                              completionToolCalls.add(content);
                            }
                          }
                        } else if (item['type'] == 'function_call') {
                          completionToolCalls ??= [];
                          completionToolCalls.add(item);
                        }
                      }
                    }
                    // Fallback: Check for Chat Completions format
                    else if (completionData.containsKey('choices') && completionData['choices'].isNotEmpty) {
                      final completionChoice = completionData['choices'][0];
                      final completionMessage = completionChoice['message'];
                      completionTextContent = completionMessage['content'];
                      if (completionMessage['tool_calls'] != null) {
                        completionToolCalls = completionMessage['tool_calls'];
                      }
                    }

                    // Process any tool calls in the completion response
                    if (completionToolCalls != null && completionToolCalls.isNotEmpty) {
                      for (final toolCall in completionToolCalls) {
                        // Handle both API formats
                        String? cFuncName;
                        dynamic cFuncArgs;

                        if (toolCall['type'] == 'function' && toolCall['function'] != null) {
                          cFuncName = toolCall['function']['name'];
                          cFuncArgs = toolCall['function']['arguments'];
                        } else if (toolCall['type'] == 'function_call' || toolCall['name'] != null) {
                          cFuncName = toolCall['name'];
                          cFuncArgs = toolCall['arguments'];
                        }

                        if (cFuncName == 'generate_pptx' && cFuncArgs != null) {
                          Map<String, dynamic> argMap;
                          if (cFuncArgs is String) {
                            argMap = jsonDecode(cFuncArgs);
                          } else {
                            argMap = cFuncArgs;
                          }

                          final title = argMap['title'] as String?;
                          final slides = argMap['slides'] as List?;
                          final theme = argMap['theme'] as String? ?? 'professional';
                          final author = argMap['author'] as String? ?? 'HowAI Agent';

                          if (title != null && slides != null && slides.isNotEmpty) {
                            //// print('[OpenAIService] Generating PPTX in completion step with title: $title, slides: ${slides.length}');

                            try {
                              final pptxPath = await _generatePptxFile(
                                title: title,
                                slides: slides.cast<Map<String, dynamic>>(),
                                theme: theme,
                                author: author,
                              );

                              if (pptxPath != null) {
                                filePaths.add(pptxPath);
                                textContent = 'I\'ve successfully created your PowerPoint presentation. It includes comprehensive analysis with current market insights and trends.';
                                //// print('[OpenAIService] Successfully completed PPTX generation in completion step');
                              }
                            } catch (e) {
                              //// print('[OpenAIService] Error generating PPTX in completion step: $e');
                            }
                          }
                        }
                      }

                      // If completion message has content and no PPTX was generated, update text
                      if (completionTextContent != null && filePaths.isEmpty) {
                        textContent = completionTextContent;
                      }
                    }
                  }
                }
              }
            } else {
              //// print('[OpenAIService] Follow-up response error: ${followupResponse.body}');
            }
          }
        }
        print('[OpenAIService] 📊 Parsed text: ${textContent?.substring(0, textContent.length > 100 ? 100 : textContent.length) ?? "NULL"}...');
        print('[OpenAIService] 📊 Parsed images: ${imageUrls.length}');
        print('[OpenAIService] 📊 Parsed files: ${filePaths.length}');
        if (conversationTitle != null) {
          print('[OpenAIService] 📊 Generated conversation title: $conversationTitle');
        }

        // Return successful response
        return {
          'text': textContent,
          'images': imageUrls,
          'files': filePaths,
          'title': conversationTitle,
        };
      } else {
        //// print('Error - Status code: ${response.statusCode}');
        //// print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      //// print('Exception in OpenAI API call: $e');
      //// print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Streaming version of generateChatResponse
  /// Yields StreamEvent objects as chunks arrive from the API
  Stream<StreamEvent> generateChatResponseStream({
    required String message,
    required List<Map<String, dynamic>> history,
    String? userName,
    Map<String, dynamic>? userCharacteristics,
    List<XFile>? attachments,
    List<PlatformFile>? fileAttachments,
    bool generateTitle = false,
    bool isPremiumUser = false,
    bool allowWebSearch = true,
    bool allowImageGeneration = true,
    bool isDeepResearch = false,
    SubscriptionService? subscriptionService,
    dynamic aiPersonality,
  }) async* {
    if (_apiKey == null) {
      yield StreamEvent.error('API key not configured');
      return;
    }

    // Determine model
    String modelToUse;
    if (attachments != null && attachments.isNotEmpty) {
      modelToUse = _chatModel;
    } else if (isPremiumUser) {
      modelToUse = _chatModel;
    } else {
      modelToUse = _chatMiniModel;
    }

    bool isDeepResearchMode = isDeepResearch;

    // Build user characteristics summary
    String characteristicsSummary = "";
    if (userCharacteristics != null && userCharacteristics.isNotEmpty) {
      characteristicsSummary = "Here is what I know about the user based on our previous conversations:\n";
      userCharacteristics.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          characteristicsSummary += "- $key: $value\n";
        }
      });
      characteristicsSummary += "\n";
    }

    bool userWantsPresentations = false;

    // Generate system prompt
    String systemPrompt = _getCachedSystemPrompt(
      userName: userName,
      characteristicsSummary: characteristicsSummary,
      generateTitle: generateTitle,
      isPremiumUser: allowWebSearch,
      aiPersonality: aiPersonality,
      userWantsPresentations: userWantsPresentations,
      isSimpleQuery: _isSimpleQuery(message),
    );

    if (isDeepResearchMode) {
      systemPrompt += "\n\nDEEP RESEARCH MODE: You are using gpt-5.2 with high reasoning effort for thorough analysis.";
      systemPrompt += "\n\nCRITICAL OUTPUT FORMAT: Do NOT include your thinking process in your response. Just provide the final answer directly.";
    }

    // Build input messages
    final List<Map<String, dynamic>> inputMessages = [];
    for (var entry in history) {
      inputMessages.add(entry);
    }

    // Handle attachments
    if ((attachments != null && attachments.isNotEmpty) || (fileAttachments != null && fileAttachments.isNotEmpty)) {
      List<Map<String, dynamic>> contentBlocks = [];

      if (message.trim().isNotEmpty) {
        contentBlocks.add({
          'type': 'input_text',
          'text': message,
        });
      }

      if (attachments != null && attachments.isNotEmpty) {
        for (final xfile in attachments) {
          try {
            final compressedBytes = await FlutterImageCompress.compressWithFile(
              xfile.path,
              quality: 80,
              format: CompressFormat.jpeg,
            );
            if (compressedBytes != null) {
              final base64Image = base64Encode(compressedBytes);
              contentBlocks.add({
                'type': 'input_image',
                'image_url': 'data:image/jpeg;base64,$base64Image',
              });
            }
          } catch (e) {
            // Skip failed images
          }
        }
      }

      if (fileAttachments != null && fileAttachments.isNotEmpty) {
        for (final file in fileAttachments) {
          try {
            final fileContent = await FileService.extractTextFromFile(file);
            if (fileContent != null && fileContent.isNotEmpty) {
              // Sanitize filename - remove potentially problematic characters
              final sanitizedFileName = file.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
              contentBlocks.add({
                'type': 'input_text',
                'text': '--- Content of uploaded file "$sanitizedFileName" (${FileService.formatFileSize(file.size)}) ---\n$fileContent\n--- End of file content ---',
              });
            }
          } catch (e) {
            // Skip failed files
          }
        }
      }

      inputMessages.add({'role': 'user', 'content': contentBlocks});
    } else {
      inputMessages.add({'role': 'user', 'content': message});
    }

    // Build tools list - NOTE: image_generation not included in streaming mode
    // because OpenAI's streaming API doesn't return image results properly
    // (stream ends before image generation completes)
    List<Map<String, dynamic>> tools = [];
    // Skip image_generation for streaming - use non-streaming generateChatResponse for images
    if (allowWebSearch) {
      tools.add({'type': 'web_search_preview'});
    }

    // Build request payload with stream: true
    Map<String, dynamic> requestPayload = {
      'model': modelToUse,
      'instructions': systemPrompt,
      'input': inputMessages,
      'stream': true,  // Enable streaming
    };

    if (tools.isNotEmpty) {
      requestPayload['tools'] = tools;
    }

    if (isDeepResearchMode) {
      requestPayload['reasoning'] = {'effort': 'high'};
    }

    try {
      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      });
      request.body = jsonEncode(requestPayload);

      final streamedResponse = await httpClient.send(request).timeout(_httpTimeout);

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        yield StreamEvent.error('API error: ${streamedResponse.statusCode} - $body');
        return;
      }

      String fullText = '';
      String? title;
      List<String> images = [];
      List<String> files = [];

      // Process SSE stream
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        // SSE format: each event is prefixed with "data: " and separated by newlines
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

            try {
              final event = jsonDecode(jsonStr);
              final eventType = event['type'] as String?;

              if (eventType == 'response.output_text.delta') {
                // Text delta event
                final delta = event['delta'] as String?;
                if (delta != null && delta.isNotEmpty) {
                  fullText += delta;
                  yield StreamEvent.textDelta(delta);
                }
              } else if (eventType == 'response.output_text.done') {
                // Text complete
                final text = event['text'] as String?;
                if (text != null) {
                  fullText = text;
                }
                yield StreamEvent.textDone(fullText);
              } else if (eventType == 'response.completed' || eventType == 'response.done') {
                // Response complete - parse final data
                print('[OpenAIService-Stream] 📦 Response completed event received');
                final response = event['response'];
                if (response != null && response['output'] is List) {
                  print('[OpenAIService-Stream] 📦 Output items: ${(response['output'] as List).length}');
                  for (final item in response['output']) {
                    print('[OpenAIService-Stream] 📦 Item type: ${item['type']}');
                    if (item['type'] == 'message' && item['content'] != null) {
                      for (final content in item['content']) {
                        if (content['type'] == 'output_text' && content['text'] != null) {
                          fullText = content['text'];
                        }
                      }
                    } else if (item['type'] == 'image_generation_call') {
                      print('[OpenAIService-Stream] 🖼️ Found image_generation_call');
                      print('[OpenAIService-Stream] 🖼️ Keys: ${item.keys.toList()}');
                      print('[OpenAIService-Stream] 🖼️ Has result: ${item['result'] != null}');
                      if (item['result'] != null) {
                        String base64Data = item['result'].toString();
                        print('[OpenAIService-Stream] 🖼️ Result length: ${base64Data.length}');
                        if (base64Data.contains('base64,')) {
                          base64Data = base64Data.split('base64,').last;
                        }
                        images.add('data:image/png;base64,$base64Data');
                        print('[OpenAIService-Stream] 🖼️ Added image to list');
                      }
                    }
                  }
                }

                // Parse title if generating - always strip title JSON from text
                if (fullText.isNotEmpty) {
                  final titleMatch = RegExp(r'\{"title"\s*:\s*"([^"]+)"\}').firstMatch(fullText);
                  if (titleMatch != null) {
                    if (generateTitle && title == null) {
                      title = titleMatch.group(1);
                    }
                    // Always strip title JSON from text regardless of generateTitle
                    fullText = fullText.replaceAll(RegExp(r'\s*\{"title"\s*:\s*"[^"]*"\}\s*'), '').trim();
                  }
                }
              }
            } catch (e) {
              // Skip malformed JSON
            }
          }
        }
      }

      // Debug: Log final state
      print('[OpenAIService-Stream] 📊 Final state: text=${fullText.length} chars, images=${images.length}');

      // Emit final done event
      print('[OpenAIService-Stream] ✅ Stream complete - text: ${fullText.length} chars, images: ${images.length}, title: $title');
      yield StreamEvent.done(
        fullText: fullText,
        title: title,
        images: images.isNotEmpty ? images : null,
        files: files.isNotEmpty ? files : null,
      );

    } catch (e) {
      yield StreamEvent.error('Stream error: $e');
    }
  }

  // Transcribe audio using OpenAI's Whisper API
  Future<String?> transcribeAudio(List<int> audioBytes, {String? language}) async {
    if (_apiKey == null) {
      //// print('Error: OpenAI API key not found');
      return null;
    }

    // Create a multipart request
    final request = http.MultipartRequest('POST', Uri.parse(_audioTranscriptionUrl));
    // Add the API key to the headers
    request.headers.addAll({
      'Authorization': 'Bearer $_apiKey',
    });

    // Add the audio file as a multipart field
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        audioBytes,
        filename: 'audio.webm', // The filename matters for the MIME type
      ),
    );
    //// print('Added audio file to request (${audioBytes.length} bytes)');

    // Add parameters
    request.fields['model'] = 'whisper-1';

    // Smart language detection - let Whisper auto-detect if no language specified
    if (language != null) {
      request.fields['language'] = language;
      //// print('Using specified language: $language');
    } else {
      // Don't specify language - let Whisper auto-detect for maximum flexibility
      //// print('Using auto-detection for language recognition');
    }

    // Add prompt that prioritizes English and Chinese but supports other languages
    request.fields['prompt'] = 'This is a natural conversation, most likely in English or Chinese. Please transcribe accurately with proper punctuation and formatting.';

    //// print('Whisper transcription configured with flexible language detection and context prompt');
    try {
      final stopwatch = Stopwatch()..start();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final elapsed = stopwatch.elapsedMilliseconds;
      //// print('Response received in ${elapsed}ms');

      if (response.statusCode == 200) {
        //// print('Success - Status code: ${response.statusCode}');

        final data = jsonDecode(response.body);
        final transcription = data['text'];

        //// print('Transcription result (${transcription.length} chars): "${transcription.substring(0, min(100, transcription.length))}${transcription.length > 100 ? '...' : ''}"');
        return transcription;
      } else {
        //// print('Error - Status code: ${response.statusCode}');
        //// print('Error response: ${response.body.substring(0, min(200, response.body.length))}...');
        return null;
      }
    } catch (e) {
      //// print('Exception in OpenAI Whisper API call: $e');
      //// print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  Future<Map<String, dynamic>> analyzeUserCharacteristics({
    required List<Map<String, String>> history,
    required String userName,
  }) async {
    String systemPrompt = """
You are an AI analyst tasked with understanding the user's characteristics from their conversation history.
Analyze the conversation and extract key characteristics about the user. Focus on:
1. Communication style (formal/casual, detailed/brief)
2. Topics of interest
3. Personality traits
4. Knowledge level in different areas
5. Preferred conversation patterns

Return the analysis as a JSON object with these categories.
Be concise and specific. Only include characteristics you're confident about.
""";

    final userMessage = [
      {'role': 'user', 'content': 'Analyze this conversation history and extract user characteristics: ${jsonEncode(history)}'},
    ];

    try {
      final response = await _httpPostWithTimeout(
        _baseUrl,
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        jsonEncode({
          'model': _chatMiniModel,
          'instructions': systemPrompt, // System prompt as separate field
          'input': userMessage, // Only user message
          'max_output_tokens': 500,
          'reasoning': {
            'effort': 'low',
          },
        }),
        _followupTimeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? content;

        // Parse Responses API format
        if (data.containsKey('output_text') && data['output_text'] != null) {
          content = data['output_text'];
        } else if (data.containsKey('output') && data['output'] is List) {
          for (final item in data['output']) {
            if (item['type'] == 'message' && item['content'] != null) {
              for (final c in item['content']) {
                if (c['type'] == 'output_text' && c['text'] != null) {
                  content = (content ?? '') + c['text'];
                }
              }
            }
          }
        }
        // Fallback: Check for Chat Completions format
        else if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          content = data['choices'][0]['message']['content'];
        }

        if (content != null) {
          try {
            // Parse the AI's response as JSON
            return jsonDecode(content) as Map<String, dynamic>;
          } catch (e) {
            //// print('Error parsing characteristics JSON: $e');
            return {};
          }
        }
      }
      return {};
    } catch (e) {
      //// print('Error analyzing user characteristics: $e');
      return {};
    }
  }

  // Generate PPTX file using dart_pptx library
  Future<String?> _generatePptxFile({
    required String title,
    required List<Map<String, dynamic>> slides,
    required String theme,
    required String author,
  }) async {
    try {
      //// print('[PPTXGenerator] Creating presentation with title: $title');
      //// print('[PPTXGenerator] Number of slides: ${slides.length}');
      //// print('[PPTXGenerator] Theme: $theme, Author: $author');

      // Use a more basic and compatible approach
      final pres = FlutterPowerPoint();

      // Set minimal metadata to avoid compatibility issues
      pres.title = _cleanText(title);
      pres.author = _cleanText(author);

      // Don't set company or other metadata that might cause issues
      // pres.company = 'HowAI Agent';

      // Add slides based on AI-generated content
      bool addedSlides = false;

      for (int i = 0; i < slides.length; i++) {
        final slide = slides[i];
        final slideTitle = slide['title'] as String? ?? 'Slide ${i + 1}';
        final slideContent = slide['content'] as String? ?? '';
        final slideType = slide['type'] as String? ?? 'content';

        //// print('[PPTXGenerator] Adding slide ${i + 1}: $slideTitle (type: $slideType)');

        // Clean and validate text content
        final cleanTitle = _cleanText(slideTitle);
        final cleanContent = _cleanText(slideContent);

        if (cleanTitle.isEmpty && cleanContent.isEmpty) {
          //// print('[PPTXGenerator] Skipping empty slide ${i + 1}');
          continue;
        }

        try {
          switch (slideType.toLowerCase()) {
            case 'title':
              if (i == 0 || !addedSlides) {
                // First slide should be title slide
                pres.addTitleSlide(
                  title: cleanTitle.toTextValue(),
                  author: (cleanContent.isNotEmpty ? cleanContent : author).toTextValue(),
                );
                addedSlides = true;
              } else {
                // Subsequent title slides as section headers
                pres.addSectionSlide(
                  section: cleanTitle.toTextValue(),
                );
                addedSlides = true;
              }
              break;

            case 'bullets':
              final bullets = _extractBullets(cleanContent);
              if (bullets.isNotEmpty) {
                pres.addTitleAndBulletsSlide(
                  title: cleanTitle.toTextValue(),
                  bullets: bullets.map((e) => e.toTextValue()).toList(),
                );
                addedSlides = true;
              } else {
                // Fallback to title-only slide
                pres.addTitleOnlySlide(
                  title: cleanTitle.toTextValue(),
                  subtitle: cleanContent.toTextValue(),
                );
                addedSlides = true;
              }
              break;

            default: // 'content'
              // Auto-detect if content should be bullets
              if (_shouldTreatAsBullets(cleanContent)) {
                final bullets = _extractBullets(cleanContent);
                if (bullets.isNotEmpty && bullets.length > 1) {
                  pres.addTitleAndBulletsSlide(
                    title: cleanTitle.toTextValue(),
                    bullets: bullets.map((e) => e.toTextValue()).toList(),
                  );
                  addedSlides = true;
                } else {
                  pres.addTitleOnlySlide(
                    title: cleanTitle.toTextValue(),
                    subtitle: cleanContent.toTextValue(),
                  );
                  addedSlides = true;
                }
              } else {
                // Regular content slide with length limit
                final limitedContent = _limitTextLength(cleanContent, 600);
                pres.addTitleOnlySlide(
                  title: cleanTitle.toTextValue(),
                  subtitle: limitedContent.toTextValue(),
                );
                addedSlides = true;
              }
              break;
          }
        } catch (e) {
          //// print('[PPTXGenerator] Error adding slide ${i + 1}: $e');
          // Try adding a simple text slide as fallback
          try {
            pres.addTitleOnlySlide(
              title: cleanTitle.toTextValue(),
              subtitle: _limitTextLength(cleanContent, 300).toTextValue(),
            );
            addedSlides = true;
          } catch (e2) {
            //// print('[PPTXGenerator] Failed to add fallback slide: $e2');
          }
        }
      }

      // If no slides were successfully added, create a basic title slide
      if (!addedSlides) {
        //// print('[PPTXGenerator] No slides added, creating default title slide');
        pres.addTitleSlide(
          title: _cleanText(title).toTextValue(),
          author: _cleanText(author).toTextValue(),
        );
      }

      // Generate the PPTX file with better error handling
      final bytes = await pres.save();
      if (bytes == null || bytes.isEmpty) {
        //// print('[PPTXGenerator] Failed to generate PPTX bytes - null or empty result');
        return null;
      }

      // Validate minimum file size (a valid PPTX should be at least a few KB)
      if (bytes.length < 1024) {
        //// print('[PPTXGenerator] Generated file too small (${bytes.length} bytes), likely corrupted');
        return null;
      }

      // Save to documents directory with improved path handling
      final directory = await getApplicationDocumentsDirectory();
      final cleanFileName = _createSafeFileName(title);
      final fileName = '${cleanFileName}_${DateTime.now().millisecondsSinceEpoch}.pptx';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Verify file was written successfully
      if (!await file.exists()) {
        //// print('[PPTXGenerator] File was not created successfully');
        return null;
      }

      final fileSize = await file.length();
      //// print('[PPTXGenerator] PPTX file saved to: $filePath');
      //// print('[PPTXGenerator] File size: $fileSize bytes');

      return filePath;
    } catch (e) {
      //// print('[PPTXGenerator] Error generating PPTX: $e');
      //// print('[PPTXGenerator] Stack trace: $stackTrace');
      return null;
    }
  }

  // Helper method to clean text for PPTX compatibility
  String _cleanText(String input) {
    if (input.isEmpty) return '';

    // Remove problematic characters that might cause OOXML issues
    return input
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '') // Control characters
        .replaceAll(RegExp(r'[\uFFFE\uFFFF]'), '') // Invalid Unicode
        .replaceAll(RegExp(r'&(?![a-zA-Z]+;)'), '&amp;') // Escape unescaped ampersands
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .trim();
  }

  // Helper method to extract bullet points from text
  List<String> _extractBullets(String content) {
    if (content.isEmpty) return [];

    final bullets = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r'^[•\-\*\+]\s*'), ''))
        .where((line) => line.isNotEmpty)
        .take(8) // Limit bullets to avoid overcrowding
        .map((line) => _cleanText(line))
        .where((line) => line.isNotEmpty)
        .toList();

    return bullets;
  }

  // Helper method to determine if content should be treated as bullets
  bool _shouldTreatAsBullets(String content) {
    if (content.isEmpty) return false;

    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.length < 2) return false;

    // Check if multiple lines start with bullet indicators
    final bulletLines = lines.where((line) => line.trim().startsWith('•') || line.trim().startsWith('-') || line.trim().startsWith('*') || line.trim().startsWith('+')).length;

    return bulletLines >= 2 && bulletLines >= (lines.length * 0.5);
  }

  // Helper method to limit text length
  String _limitTextLength(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    // Try to break at word boundary near the limit
    final truncated = text.substring(0, maxLength);
    final lastSpace = truncated.lastIndexOf(' ');

    if (lastSpace > maxLength * 0.7) {
      return '${truncated.substring(0, lastSpace)}...';
    }

    return '${truncated}...';
  }

  // Helper method to create safe file names
  String _createSafeFileName(String input) {
    if (input.isEmpty) return 'document';

    String cleaned = input
        .replaceAll(RegExp(r'[^\w\s\-]'), '') // Remove special chars except word chars, spaces, hyphens
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
        .replaceAll(RegExp(r'_+'), '_') // Collapse multiple underscores
        .trim();

    // Limit length safely using the cleaned string's actual length
    if (cleaned.length > 50) {
      cleaned = cleaned.substring(0, 50);
    }

    // Remove trailing underscores
    cleaned = cleaned.replaceAll(RegExp(r'_+$'), '');

    // Ensure we have a valid filename
    return cleaned.isEmpty ? 'document' : cleaned;
  }

  // Add a new method to detect if user wants PowerPoint presentation
  Future<bool> detectPresentationIntent({
    required List<Map<String, dynamic>> recentMessages,
    required String currentUserMessage,
  }) async {
    if (_apiKey == null) {
      return false;
    }

    // Take the LAST (most recent) 10 messages for context, in reverse chronological order
    final lastMessages = recentMessages.reversed.take(10).toList().reversed.toList();

    final intentDetectionPrompt = """
You are an intent analyzer. Analyze the conversation context and the user's latest message to determine if the user is REQUESTING ACTION related to PowerPoint presentations, slides, or PPTX files.

DETECT "YES" ONLY if the user is:
- Explicitly asking to CREATE a new presentation/slides/PowerPoint
- Asking to MODIFY/EDIT an existing presentation (add slides, change content, etc.)
- Using words like "create presentation", "make slides", "generate PowerPoint", "build slides"

DETECT "NO" if the user is:
- Requesting IMAGE GENERATION (even if the images could be used in presentations later)
- Asking for drawings, artwork, pictures, or visual content
- Just MENTIONING presentations in casual conversation
- ASKING QUESTIONS about presentations without requesting action
- Making OBSERVATIONS or COMMENTS about presentations

IMPORTANT EXAMPLES:
- "Generate an image of..." = NO (this is image generation, not presentation creation)
- "Draw me a picture..." = NO (this is image generation)
- "Create a presentation about..." = YES (this is presentation creation)
- "Make slides for..." = YES (this is presentation creation)

Answer ONLY with "YES" or "NO" - nothing else.
""";

    // Build input: conversation history + current user message (instructions separate)
    final inputMessages = [
      ...lastMessages,
      {'role': 'user', 'content': currentUserMessage},
      {'role': 'user', 'content': 'Based on the conversation context and my latest message, am I REQUESTING ACTION related to PowerPoint presentations?'}
    ];

    try {
      final response = await _httpPostWithTimeout(
        _baseUrl,
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        jsonEncode({
          'model': _chatMiniModel, // Use gpt-5-nano for intent detection
          'instructions': intentDetectionPrompt, // System prompt as separate field
          'input': inputMessages, // Only conversation + user messages
          'max_output_tokens': 10, // Very short response needed
          'reasoning': {
            'effort': 'low',
          },
        }),
        Duration(seconds: 30), // Quick timeout for intent detection
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? content;

        // Parse Responses API format
        if (data.containsKey('output_text') && data['output_text'] != null) {
          content = data['output_text']?.toString().trim().toLowerCase();
        } else if (data.containsKey('output') && data['output'] is List) {
          for (final item in data['output']) {
            if (item['type'] == 'message' && item['content'] != null) {
              for (final c in item['content']) {
                if (c['type'] == 'output_text' && c['text'] != null) {
                  content = c['text']?.toString().trim().toLowerCase();
                  break;
                }
              }
            }
          }
        }
        // Fallback: Check for Chat Completions format
        else if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          content = data['choices'][0]['message']['content']?.toString().trim().toLowerCase();
        }

        //// print('[OpenAIService] Presentation intent detection result: $content');
        //// print('[OpenAIService] Current user message: ${currentUserMessage.substring(0, min(100, currentUserMessage.length))}...');
        //// print('[OpenAIService] Recent messages for context: ${lastMessages.length} messages');
        for (int i = 0; i < lastMessages.length && i < 3; i++) {
          final msg = lastMessages[i];
          final preview = msg['content']?.toString().substring(0, min(50, msg['content']?.toString().length ?? 0)) ?? '';
          //// print('[OpenAIService] Message ${i + 1}: ${msg['role']} - "$preview..."');
        }
        return content?.contains('yes') ?? false;
      }
      return false;
    } catch (e) {
      //// print('[OpenAIService] Error in presentation intent detection: $e');
      return false;
    }
  }

  /// Detects if a query is simple/small talk that deserves a quick, short response.
  /// Returns true for greetings, short questions, simple requests, etc.
  static bool _isSimpleQuery(String message) {
    final lowerMessage = message.toLowerCase().trim();
    final wordCount = lowerMessage.split(RegExp(r'\s+')).length;

    // Very short messages (1-5 words) are likely simple
    if (wordCount <= 5) {
      return true;
    }

    // Common greetings and small talk
    final greetings = [
      'hi',
      'hello',
      'hey',
      'yo',
      'sup',
      'howdy',
      'good morning',
      'good afternoon',
      'good evening',
      'good night',
      'what\'s up',
      'whats up',
      'how are you',
      'how\'s it going',
      'thanks',
      'thank you',
      'thx',
      'ty',
      'bye',
      'goodbye',
      'see you',
      'later',
      'ok',
      'okay',
      'sure',
      'yes',
      'no',
      'yeah',
      'nope',
      'cool',
      'nice',
      'great',
      'awesome',
    ];

    for (final greeting in greetings) {
      if (lowerMessage == greeting || lowerMessage.startsWith('$greeting ') || lowerMessage.startsWith('$greeting,')) {
        return true;
      }
    }

    // Simple question patterns (short, direct questions)
    final simplePatterns = [
      RegExp(r"^what is .{1,30}\?*$"), // "what is X?"
      RegExp(r"^what's .{1,30}\?*$"), // "what's X?"
      RegExp(r"^who is .{1,30}\?*$"), // "who is X?"
      RegExp(r"^where is .{1,30}\?*$"), // "where is X?"
      RegExp(r"^when is .{1,30}\?*$"), // "when is X?"
      RegExp(r"^is .{1,40}\?*$"), // "is X Y?"
      RegExp(r"^can you .{1,30}\?*$"), // "can you X?"
      RegExp(r"^do you .{1,30}\?*$"), // "do you X?"
      RegExp(r"^define .{1,20}$"), // "define X"
      RegExp(r"^translate .{1,50}$"), // short translation
    ];

    for (final pattern in simplePatterns) {
      if (pattern.hasMatch(lowerMessage)) {
        return true;
      }
    }

    // Medium-length messages (6-15 words) without complex indicators are considered moderate
    // Only return true for simple if very short or matches patterns above
    return false;
  }

  /// Cleans up AI response by removing thinking/planning text that shouldn't be shown to users.
  /// This includes lines like "I'll search for...", "Let me...", raw JSON blocks, etc.
  static String _cleanupAIThinkingText(String text) {
    if (text.isEmpty) return text;

    String cleaned = text;

    // Remove raw JSON blocks more aggressively - handle multiple patterns
    // Pattern 1: {"query":"...", "search_results":[...]}
    // Pattern 2: {"search_results":[{"title":"...","snippet":"...","link":"..."}]}
    // Pattern 3: Any JSON block with "search_results", "query", "title", "snippet"
    final jsonPatterns = [
      RegExp(r'\{[^{}]*"query"[^{}]*\}'),
      RegExp(r'\{[^{}]*"search_results"[^{}]*\}'),
      RegExp(r'\{[^{}]*"title"[^{}]*"snippet"[^{}]*\}'),
      RegExp(r'\{[^{}]*"link"[^{}]*\}'),
    ];

    // Remove complex nested JSON using brace counting
    while (cleaned.contains('"search_results"') && cleaned.contains('{')) {
      final jsonStart = cleaned.indexOf('{"search_results"');
      if (jsonStart == -1) {
        // Try finding other JSON patterns
        final altStart = cleaned.indexOf('{');
        if (altStart != -1 && cleaned.substring(altStart, altStart + 100).contains('"search_results"')) {
          final endBrace = cleaned.indexOf('}', altStart);
          if (endBrace != -1) {
            cleaned = cleaned.substring(0, altStart) + cleaned.substring(endBrace + 1);
          }
        }
        break;
      }

      int braceCount = 0;
      int endIndex = jsonStart;
      for (int i = jsonStart; i < cleaned.length; i++) {
        if (cleaned[i] == '{') braceCount++;
        if (cleaned[i] == '}') braceCount--;
        if (braceCount == 0) {
          endIndex = i + 1;
          break;
        }
      }

      if (endIndex > jsonStart) {
        cleaned = cleaned.substring(0, jsonStart) + cleaned.substring(endIndex);
      } else {
        break;
      }
    }

    // Remove any remaining JSON patterns with simple regex
    for (final pattern in jsonPatterns) {
      cleaned = cleaned.replaceAll(pattern, '');
    }

    // Remove any malformed JSON fragments
    cleaned = cleaned.replaceAll(RegExp(r'\{[^}]*"[^"]*":[^}]*\}'), '');

    // Remove standalone bracketed content that looks like JSON keys
    cleaned = cleaned.replaceAll(RegExp(r'\[[^\]]*\]'), '');

    // Split into lines to process
    final lines = cleaned.split('\n');
    final filteredLines = <String>[];
    bool foundMainContent = false;

    for (final line in lines) {
      final trimmedLine = line.trim();

      // Skip empty lines at the start
      if (trimmedLine.isEmpty && !foundMainContent) continue;

      // Patterns that indicate AI thinking/planning (not actual content)
      final isThinkingLine = trimmedLine.startsWith("I'll ") ||
          trimmedLine.startsWith("I will ") ||
          trimmedLine.startsWith("Let me ") ||
          trimmedLine.startsWith("I don't actually need") ||
          trimmedLine.startsWith("The earlier search") ||
          trimmedLine.startsWith("I need to ") ||
          trimmedLine.startsWith("I should ") ||
          trimmedLine.startsWith("Now I'll ") ||
          trimmedLine.startsWith("Now let me") ||
          trimmedLine.startsWith("First, I'll") ||
          trimmedLine.startsWith("Next, I'll") ||
          (trimmedLine.contains("search") && trimmedLine.contains("for") && trimmedLine.startsWith("I")) ||
          (trimmedLine.contains("pull") && trimmedLine.contains("data") && trimmedLine.startsWith("I")) ||
          (trimmedLine.contains("grab") && trimmedLine.startsWith("I"));

      // If we haven't found main content yet, skip thinking lines
      if (!foundMainContent && isThinkingLine) {
        continue;
      }

      // Check if this line looks like the start of main content
      // Main content often starts with headers, bullet points, or clear answer phrases
      if (!foundMainContent) {
        final isMainContentStart = trimmedLine.startsWith("Short answer") ||
            trimmedLine.startsWith("**") ||
            trimmedLine.startsWith("##") ||
            trimmedLine.startsWith("# ") ||
            trimmedLine.startsWith("1.") ||
            trimmedLine.startsWith("1)") ||
            trimmedLine.startsWith("•") ||
            trimmedLine.startsWith("-") ||
            trimmedLine.startsWith("Here") ||
            trimmedLine.startsWith("The answer") ||
            trimmedLine.startsWith("Based on") ||
            trimmedLine.startsWith("As of") ||
            trimmedLine.startsWith("Currently") ||
            trimmedLine.startsWith("In summary") ||
            trimmedLine.contains("is trading") ||
            trimmedLine.contains("stock price") ||
            (trimmedLine.length > 50 && !isThinkingLine); // Longer lines are likely content

        if (isMainContentStart) {
          foundMainContent = true;
        }
      }

      // Once we've found main content, include everything except obvious thinking lines
      if (foundMainContent) {
        // Still filter out obvious thinking lines even in main content
        if (!isThinkingLine || trimmedLine.length > 100) {
          filteredLines.add(line);
        }
      }
    }

    // If we didn't find main content markers, return the JSON-cleaned version
    if (filteredLines.isEmpty) {
      return cleaned.trim();
    }

    return filteredLines.join('\n').trim();
  }

  /// Extracts the final, clean answer from AI response, removing all tool call data and metadata
  static String _extractFinalAnswer(String text) {
    if (text.isEmpty) return text;

    String cleaned = text;

    // Look for common answer patterns that indicate the start of the actual answer
    final answerMarkers = [
      'Short answer:',
      'Based on the search results:',
      'According to the data:',
      'Here\'s what I found:',
      'The weather for',
      'Current weather in',
      // Weather-specific patterns
      RegExp(r'[A-Z][a-z]+ weather for today'),
      RegExp(r'weather for [A-Z][a-z]+'),
      // Stock/financial patterns
      RegExp(r'As of [A-Z][a-z]+ \d+, 2025'),
      RegExp(r'Currently [A-Z][a-z]+ is trading'),
      // General data patterns
      RegExp(r'\*\*[^*]+\*\*'), // Bold headers
    ];

    // Try to find where the actual answer begins
    int bestAnswerStart = -1;

    for (final marker in answerMarkers) {
      int markerPos = -1;
      if (marker is String) {
        markerPos = cleaned.toLowerCase().indexOf(marker.toLowerCase());
      } else if (marker is RegExp) {
        final match = marker.firstMatch(cleaned);
        if (match != null) {
          markerPos = match.start;
        }
      }

      if (markerPos != -1) {
        if (bestAnswerStart == -1 || markerPos < bestAnswerStart) {
          bestAnswerStart = markerPos;
        }
      }
    }

    // If we found an answer marker, extract from there
    if (bestAnswerStart != -1) {
      cleaned = cleaned.substring(bestAnswerStart);
    }

    // Alternative approach: look for the last paragraph that seems like a summary/conclusion
    final lines = cleaned.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      // Find lines that look like final answers (contain key info without JSON)
      final meaningfulLines = lines.where((line) {
        final trimmed = line.trim();
        // Skip lines that are clearly JSON or tool data
        if (trimmed.startsWith('{') || trimmed.startsWith('[') || trimmed.contains('"title":') || trimmed.contains('"snippet":') || trimmed.contains('"link":') || trimmed.contains('search_results')) {
          return false;
        }
        // Skip very short lines unless they're headers
        if (trimmed.length < 20 && !trimmed.startsWith('**') && !trimmed.startsWith('#')) {
          return false;
        }
        return true;
      }).toList();

      if (meaningfulLines.isNotEmpty) {
        // Take the meaningful lines, preferring later ones as they're likely the conclusion
        final meaningfulText = meaningfulLines.join('\n').trim();
        if (meaningfulText.isNotEmpty) {
          cleaned = meaningfulText;
        }
      }
    }

    // Final cleanup - remove any remaining artifacts
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[\{\[].*[\}\]]\s*$', multiLine: true), ''); // Remove JSON lines
    cleaned = cleaned.replaceAll(RegExp(r'search_results?'), ''); // Remove search result mentions
    cleaned = cleaned.replaceAll(RegExp(r'\{[^}]*\}'), ''); // Remove any remaining JSON objects
    cleaned = cleaned.replaceAll(RegExp(r'\[[^\]]*\]'), ''); // Remove any arrays

    // Clean up excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n'); // Multiple newlines to double
    cleaned = cleaned.trim();

    return cleaned;
  }

  /// Helper to extract images from various possible response formats
  /// Handles: direct URL string, b64_json, Map with url/image_url/b64_json, List of images
  static void _extractImagesFromData(dynamic data, List<String> imageUrls) {
    if (data == null) return;

    if (data is String) {
      // Could be a URL or base64 data
      if (data.startsWith('http://') || data.startsWith('https://')) {
        imageUrls.add(data);
      } else if (data.length > 100) {
        // Likely base64 data
        imageUrls.add('data:image/png;base64,$data');
      }
    } else if (data is Map) {
      // Check various possible field names
      if (data['url'] != null) {
        imageUrls.add(data['url'] as String);
      } else if (data['image_url'] != null) {
        imageUrls.add(data['image_url'] as String);
      } else if (data['b64_json'] != null) {
        imageUrls.add('data:image/png;base64,${data['b64_json']}');
      } else if (data['b64'] != null) {
        imageUrls.add('data:image/png;base64,${data['b64']}');
      } else if (data['base64'] != null) {
        imageUrls.add('data:image/png;base64,${data['base64']}');
      } else if (data['data'] != null) {
        // Nested data field - recurse
        _extractImagesFromData(data['data'], imageUrls);
      } else if (data['image'] != null) {
        _extractImagesFromData(data['image'], imageUrls);
      }
    } else if (data is List) {
      // List of images
      for (final item in data) {
        _extractImagesFromData(item, imageUrls);
      }
    }
  }
}

// Helper function to get smaller of two integers
int min(int a, int b) {
  return a < b ? a : b;
}
