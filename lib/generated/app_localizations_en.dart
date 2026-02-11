// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'Settings';

  @override
  String get chat => 'Chat';

  @override
  String get discover => 'Discover';

  @override
  String get send => 'Send';

  @override
  String get attachPhoto => 'Attach photo';

  @override
  String get instructions => 'Instructions & Features';

  @override
  String get profile => 'Profile';

  @override
  String get voiceSettings => 'Voice Settings';

  @override
  String get subscription => 'Subscription';

  @override
  String get usageStatistics => 'Usage Statistics';

  @override
  String get usageStatisticsDesc => 'View your weekly usage and limits';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get clearChatHistory => 'Clear Chat History';

  @override
  String get cleanCachedFiles => 'Clean Cached Files';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get delete => 'Delete';

  @override
  String get selectAll => 'Select All';

  @override
  String get unselectAll => 'Unselect All';

  @override
  String get translate => 'Translate';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get select => 'Select';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get holdToTalk => 'Hold to Talk';

  @override
  String get listening => 'Listening...';

  @override
  String get processing => 'Processing...';

  @override
  String get couldNotAccessMic => 'Could not access the microphone';

  @override
  String get cancelRecording => 'Cancel Recording';

  @override
  String get pressAndHoldToSpeak => 'Press and hold to speak';

  @override
  String get releaseToCancel => 'Release to cancel';

  @override
  String get swipeUpToCancel => '↑ Swipe up to cancel';

  @override
  String get copied => 'Copied!';

  @override
  String get translationFailed => 'Couldn\'t translate that. Please try again.';

  @override
  String translatingTo(Object lang) {
    return 'Translating to $lang...';
  }

  @override
  String get messageDeleted => 'Message deleted.';

  @override
  String error(Object error) {
    return 'Something went wrong. Please try again.';
  }

  @override
  String get playHaoVoice => 'Play Hao\'s Voice';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get stop => 'Stop';

  @override
  String get startFreeTrial => 'Start Free Trial';

  @override
  String get subscriptionDetails => 'Subscription Details';

  @override
  String get firstMonthFree => 'First month free';

  @override
  String get cancelAnytime => '• Cancel anytime';

  @override
  String get unlockBestAiChat => 'Unlock the best AI chat experience!';

  @override
  String get allFeaturesAllPlatforms => 'All features. All platforms. Cancel anytime.';

  @override
  String get yourDataStays => 'Your data stays on your device. No tracking. No ads. You\'re always in control.';

  @override
  String get viewFullGuide => 'View Full Guide';

  @override
  String get learnAboutFeatures => 'Learn about all features and how to use them';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get privacyNote => 'Privacy Note';

  @override
  String get aiAnalyzes => 'The AI analyzes your conversations to provide better responses, but:';

  @override
  String get allDataStays => 'All data stays on your device only';

  @override
  String get noConversationTracking => 'No conversation tracking or monitoring';

  @override
  String get noDataSent => 'No data is sent to external servers';

  @override
  String get clearDataAnytime => 'You can clear this data anytime';

  @override
  String get pleaseSelectProfile => 'Please select a profile to view characteristics';

  @override
  String get aiStillLearning => 'The AI is still learning about you. Keep chatting to see your characteristics here!';

  @override
  String get communicationStyle => 'Communication Style';

  @override
  String get topicsOfInterest => 'Topics of Interest';

  @override
  String get personalityTraits => 'Personality Traits';

  @override
  String get expertiseAndInterests => 'Expertise & Interests';

  @override
  String get conversationStyle => 'Conversation Style';

  @override
  String get enableVoiceResponses => 'Enable Voice Responses';

  @override
  String get voiceRepliesSpoken => 'When enabled, all HowAI replies will be spoken aloud using Hao\'s real voice. Try it out—it\'s pretty cool!';

  @override
  String get playVoiceRepliesSpeaker => 'Use Speaker Output';

  @override
  String get enableToPlaySpeaker => 'Play audio through speaker instead of headphones.';

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String get clear => 'Clear';

  @override
  String get failedToClearChat => 'Couldn\'t clear chat history. Please try again.';

  @override
  String get chatHistoryCleared => 'Chat history cleared';

  @override
  String get failedToCleanCache => 'Couldn\'t clean cached files. Please try again.';

  @override
  String cleanedCachedFiles(Object count) {
    return 'Cleaned $count cached file(s).';
  }

  @override
  String get deleteProfile => 'Delete Profile';

  @override
  String get updateProfileSuccess => 'Profile updated successfully';

  @override
  String get updateProfileFailed => 'Couldn\'t save your profile. Please try again.';

  @override
  String get tapAvatarToChange => 'Tap avatar to change';

  @override
  String get yourName => 'Your Name';

  @override
  String get saveChanges => 'Tap \"Update Profile\" below to save changes';

  @override
  String get viewGuide => 'View Full Guide';

  @override
  String get learnFeatures => 'Learn about all features and how to use them';

  @override
  String get convertToPdf => 'Convert to PDF';

  @override
  String get pdfCreated => 'PDF created and linked in chat!';

  @override
  String get generatingPdf => 'Generating styled PDF...';

  @override
  String get messagePdfReady => '📄 Your message PDF is ready! [Tap here to open it]';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'Couldn\'t create your PDF. Please try again.';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'Couldn\'t create the PDF. Please try again.';
  }

  @override
  String get imageSaved => 'Image saved to Photos!';

  @override
  String get failedToSaveImage => 'Couldn\'t save the image. Check your storage space.';

  @override
  String get failedToDownloadImage => 'Couldn\'t download the image. Check your connection.';

  @override
  String get errorProcessingAudio => 'Couldn\'t process the audio. Please try again.';

  @override
  String get recordingFailed => 'Recording didn\'t work. Please try again.';

  @override
  String get errorProcessingVoice => 'Couldn\'t understand that. Please speak again.';

  @override
  String get iCouldntHear => 'I couldn\'t hear what you said. Please try again.';

  @override
  String get selectMessages => 'Select Messages';

  @override
  String selected(Object count) {
    return '$count selected';
  }

  @override
  String deleteMessages(Object count) {
    return 'Deleted $count message(s).';
  }

  @override
  String get premiumTitle => 'HowAI Premium';

  @override
  String get imageGeneration => 'Image Generation';

  @override
  String get imageGenerationDesc => 'Create images with DALL·E 3 and Vision AI.';

  @override
  String get multiImageAttachments => 'Multi-Image Attachments';

  @override
  String get multiImageAttachmentsDesc => 'Send, preview, and manage multiple images.';

  @override
  String get pdfTools => 'PDF Tools';

  @override
  String get pdfToolsDesc => 'Convert images to PDF, save & share.';

  @override
  String get continuousUpdates => 'Continuous Updates';

  @override
  String get continuousUpdatesDesc => 'New features and improvements all the time!';

  @override
  String get privacyBanner => 'Your data stays on your device. No tracking. No ads. You\'re always in control.';

  @override
  String get subscriptionDetailsTitle => 'Subscription Details';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/month after trial';
  }

  @override
  String get playHaosVoice => 'Play Hao\'s Voice';

  @override
  String get personalizeProfileDesc => 'Personalize your chat with your own icon.';

  @override
  String get selectDeleteMessagesDesc => 'Select and delete multiple messages.';

  @override
  String get instructionsSection1Title => 'Chat & Voice';

  @override
  String get instructionsSection1Line1 => '• Chat with HowAI using text or voice input for a natural, conversational experience.';

  @override
  String get instructionsSection1Line2 => '• Tap the mic icon to switch to voice mode, then hold to record and send your message.';

  @override
  String get instructionsSection1Line3 => '• When using keyboard input: Enter sends your message, Shift+Enter creates a new line.';

  @override
  String get instructionsSection1Line4 => '• HowAI can reply with text and (optionally) voice. Toggle voice replies in Settings.';

  @override
  String get instructionsSection1Line5 => '• Tap the AppBar title (\"HowAI\") to quickly scroll up in the chat.';

  @override
  String get instructionsSection2Title => 'Image Attachments';

  @override
  String get instructionsSection2Line1 => '• Tap the paperclip icon to attach photos from your gallery or camera.';

  @override
  String get instructionsSection2Line2 => '• Add a text message along with your photo(s) to help the AI analyze, understand, or respond to your images.';

  @override
  String get instructionsSection2Line3 => '• Preview, remove, or send multiple images at once before sending.';

  @override
  String get instructionsSection2Line4 => '• Images are automatically compressed for faster upload and better performance.';

  @override
  String get instructionsSection2Line5 => '• Tap on images in chat to view them fullscreen, swipe between them, or save to your device.';

  @override
  String get instructionsSection3Title => 'Image Generation';

  @override
  String get instructionsSection3Line1 => '• Ask HowAI to create images by mentioning keywords like \"draw\", \"picture\", \"image\", \"paint\", \"sketch\", \"generate\", \"art\", \"visual\", \"show me\", \"create\", or \"design\".';

  @override
  String get instructionsSection3Line2 => '• Example prompts: \"Draw a cat in a spacesuit\", \"Show me a picture of a futuristic city\", \"Generate an image of a cozy reading nook\".';

  @override
  String get instructionsSection3Line3 => '• HowAI will generate and display the image right in the chat.';

  @override
  String get instructionsSection3Line4 => '• Refine images with follow-up instructions, e.g., \"Make it nighttime\", \"Add more colors\", or \"Make the cat look happier\".';

  @override
  String get instructionsSection3Line5 => '• The more details you provide, the better the results! Tap generated images to view fullscreen.';

  @override
  String get instructionsSection4Title => 'PDF Tools';

  @override
  String get instructionsSection4Line1 => '• After attaching images, tap \"Convert to PDF\" to combine them into a single PDF file.';

  @override
  String get instructionsSection4Line2 => '• The PDF is saved to your device and a clickable link appears in chat.';

  @override
  String get instructionsSection4Line3 => '• Tap the link to open the PDF in your default viewer.';

  @override
  String get instructionsSection5Title => 'Bulk Actions';

  @override
  String get instructionsSection5Line1 => '• Long-press any message and tap \"Select\" to enter selection mode.';

  @override
  String get instructionsSection5Line2 => '• Select multiple messages to delete them in bulk.';

  @override
  String get instructionsSection5Line3 => '• Use \"Select All\" or \"Unselect All\" for quick selection.';

  @override
  String get instructionsSection6Title => 'Translation';

  @override
  String get instructionsSection6Line1 => '• Long-press any message and tap \"Translate\" to instantly translate it to your preferred language.';

  @override
  String get instructionsSection6Line2 => '• The translation appears below the message with an option to hide it.';

  @override
  String get instructionsSection6Line3 => '• Works with any language—HowAI auto-detects and translates between English, Chinese, or other languages as needed.';

  @override
  String get instructionsSection7Title => 'AI Insights';

  @override
  String get instructionsSection7Line1 => '• HowAI analyzes your conversation style, interests, and personality traits to personalize your experience.';

  @override
  String get instructionsSection7Line2 => '• The more you chat with HowAI, the better it understands you and can communicate and support you more effectively.';

  @override
  String get instructionsSection7Line3 => '• View your AI-generated insights in the Settings > AI Insights section.';

  @override
  String get instructionsSection7Line4 => '• All analysis is done on-device for your privacy—no data leaves your device.';

  @override
  String get instructionsSection7Line5 => '• You can clear this data at any time in Settings.';

  @override
  String get instructionsSection8Title => 'Privacy & Data';

  @override
  String get instructionsSection8Line1 => '• All your data stays on your device only—nothing is sent to external servers.';

  @override
  String get instructionsSection8Line2 => '• No conversation tracking or monitoring.';

  @override
  String get instructionsSection8Line3 => '• You can clear your chat history and AI insights at any time in Settings.';

  @override
  String get instructionsSection8Line4 => '• Your privacy and security are our top priorities.';

  @override
  String get instructionsSection9Title => 'Contact & Updates';

  @override
  String get instructionsSection9Line1 => 'For help, feedback, or support, email:';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'We are continuously improving HowAI and adding new features—stay tuned for updates!';

  @override
  String get aiAgentReady => 'Your intelligent AI agent - ready to assist with any task';

  @override
  String get featureSmartChat => 'Smart Chat';

  @override
  String get featureSmartChatDesc => 'Natural AI conversations with contextual understanding';

  @override
  String get featureLocalDiscovery => 'Local Discovery';

  @override
  String get featureLocalDiscoveryDesc => 'Find restaurants, attractions & services near you with AI insights';

  @override
  String get featurePhotoAnalysis => 'Photo Analysis';

  @override
  String get featurePhotoAnalysisDesc => 'Advanced image recognition and OCR';

  @override
  String get featureDocumentAnalysis => 'Document Analysis';

  @override
  String get featureDocumentAnalysisDesc => 'Analyze PDFs, Word docs and spreadsheets';

  @override
  String get featureAiImageGeneration => 'Image Generator';

  @override
  String get featureAiImageGenerationDesc => 'Create stunning artwork from text';

  @override
  String get featureProblemSolving => 'Problem Solving';

  @override
  String get featureProblemSolvingDesc => 'Step-by-step solutions for complex problems';

  @override
  String get featurePdfCreation => 'Photo to PDF';

  @override
  String get featurePdfCreationDesc => 'Convert photos and images into organized PDF documents instantly';

  @override
  String get featureProfessionalWriting => 'Professional Writing';

  @override
  String get featureProfessionalWritingDesc => 'Business content, reports, proposals & professional documents';

  @override
  String get featureIdeaGeneration => 'Idea Generation';

  @override
  String get featureIdeaGenerationDesc => 'Creative brainstorming and innovation';

  @override
  String get featureConceptExplanation => 'Concept Explanation';

  @override
  String get featureConceptExplanationDesc => 'Clear breakdowns of complex topics';

  @override
  String get featureCreativeWriting => 'Creative Writing';

  @override
  String get featureCreativeWritingDesc => 'Stories, poetry and creative content';

  @override
  String get featureStepByStepGuides => 'Step-by-Step Guides';

  @override
  String get featureStepByStepGuidesDesc => 'Detailed tutorials and how-to instructions';

  @override
  String get featureSmartPlanning => 'Smart Planning';

  @override
  String get featureSmartPlanningDesc => 'Intelligent scheduling and organizational assistance';

  @override
  String get featureDailyProductivity => 'Daily Productivity';

  @override
  String get featureDailyProductivityDesc => 'AI-powered day planning and prioritization';

  @override
  String get featureMorningOptimization => 'Morning Optimization';

  @override
  String get featureMorningOptimizationDesc => 'Design productive morning routines';

  @override
  String get featureProfessionalEmail => 'Professional Email';

  @override
  String get featureProfessionalEmailDesc => 'AI-crafted business emails with perfect tone and structure';

  @override
  String get featureSmartSummarization => 'Smart Summarization';

  @override
  String get featureSmartSummarizationDesc => 'Extract key insights from complex documents and data';

  @override
  String get featureLeisurePlanning => 'Leisure Planning';

  @override
  String get featureLeisurePlanningDesc => 'Discover activities, events and experiences for your free time';

  @override
  String get featureEntertainmentGuide => 'Entertainment Guide';

  @override
  String get featureEntertainmentGuideDesc => 'Personalized recommendations for movies, books, music & more';

  @override
  String get inputStartConversation => 'Hi! I\'d like to have a conversation about ';

  @override
  String get inputFindPlaces => 'Find best places near me';

  @override
  String get inputAnalyzePhotos => 'Analyze my photos';

  @override
  String get inputAnalyzeDocuments => 'Analyze documents & files';

  @override
  String get inputGenerateImage => 'Generate an image of ';

  @override
  String get inputSolveProblem => 'Help me solve this problem: ';

  @override
  String get inputConvertToPdf => 'Convert photos to PDF';

  @override
  String get inputProfessionalContent => 'Write professional content about ';

  @override
  String get inputBrainstormIdeas => 'Help me brainstorm ideas for ';

  @override
  String get inputExplainConcept => 'Explain this concept ';

  @override
  String get inputCreativeStory => 'Write a creative story about ';

  @override
  String get inputShowHowTo => 'Show me how to ';

  @override
  String get inputHelpPlan => 'Help me plan ';

  @override
  String get inputPlanDay => 'Plan my day efficiently ';

  @override
  String get inputMorningRoutine => 'Create a morning routine for ';

  @override
  String get inputDraftEmail => 'Draft an email about ';

  @override
  String get inputSummarizeInfo => 'Summarize this information: ';

  @override
  String get inputWeekendActivities => 'Plan weekend activities for ';

  @override
  String get inputRecommendMovies => 'Recommend movies or books about ';

  @override
  String get premiumFeatureTitle => 'Premium Feature';

  @override
  String get premiumFeatureDesc => 'This feature requires a premium subscription. Upgrade to unlock advanced capabilities and enhanced AI features.';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get welcomeMessage => 'Hello! 👋 I\'m Hao, your AI companion.\n\n- Ask me anything, or just chat for fun—I\'m here to help!\n- Tap the **📖 Discover** tab below to explore features, tips, and more.\n- Personalize your experience in **Settings** (⚙️).\n- Try sending a voice message or attach a photo to get started!\n\nLet\'s get chatting! 🚀\n';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get profileUpdateFailed => 'Couldn\'t save profile changes. Please try again.';

  @override
  String get clearChatHistoryTitle => 'Clear Chat History';

  @override
  String get clearChatHistoryWarning => 'This action cannot be undone.';

  @override
  String get deleteCachedFilesDesc => 'Delete cached images and PDF files created by HowAI.';

  @override
  String get appLanguage => 'App Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get japanese => '日本語';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get arabic => 'العربية';

  @override
  String get taiwanese => '繁體中文';

  @override
  String get play => 'Play';

  @override
  String get playing => 'Playing...';

  @override
  String get paused => 'Paused';

  @override
  String get voiceMessage => 'Voice Message';

  @override
  String get switchToKeyboard => 'Switch to keyboard input';

  @override
  String get switchToVoiceInput => 'Switch to voice input';

  @override
  String get couldNotPlayVoiceDemo => 'Could not play demo audio.';

  @override
  String get saveToPhotos => 'Save to Photos';

  @override
  String get voiceInputTipsTitle => 'Voice Input Tips';

  @override
  String get voiceInputTipsPressHold => 'Press and hold';

  @override
  String get voiceInputTipsPressHoldDesc => 'Hold the button to start recording';

  @override
  String get voiceInputTipsSpeakClearly => 'Speak clearly';

  @override
  String get voiceInputTipsSpeakClearlyDesc => 'Release when you\'re done speaking';

  @override
  String get voiceInputTipsSwipeUp => 'Swipe up to cancel';

  @override
  String get voiceInputTipsSwipeUpDesc => 'If you want to cancel recording';

  @override
  String get voiceInputTipsSwitchInput => 'Switch input modes';

  @override
  String get voiceInputTipsSwitchInputDesc => 'Tap the icon on the left to switch between voice and keyboard';

  @override
  String get voiceInputTipsDontShowAgain => 'Don\'t show again';

  @override
  String get voiceInputTipsGotIt => 'Got it';

  @override
  String get chatInputHint => 'Ask me anything to start our conversation...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'Chat as much as you want with HowAI.';

  @override
  String get playTooltip => 'Play Hao\'s Voice';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get resumeTooltip => 'Resume';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get selectSectionTooltip => 'Select section';

  @override
  String get voiceDemoHeader => 'I left a voice message for you:';

  @override
  String get searchConversations => 'Search conversations';

  @override
  String get newConversation => 'New Conversation';

  @override
  String get pinnedSection => 'Pinned';

  @override
  String get chatsSection => 'Chats';

  @override
  String get noConversationsYet => 'No conversations yet. Start by sending a message.';

  @override
  String noConversationsMatching(Object query) {
    return 'No conversations matching \"$query\"';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return 'Created $timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return '$count year(s) ago';
  }

  @override
  String monthAgo(Object count) {
    return '$count month(s) ago';
  }

  @override
  String dayAgo(Object count) {
    return '$count day(s) ago';
  }

  @override
  String hourAgo(Object count) {
    return '$count hour(s) ago';
  }

  @override
  String minuteAgo(Object count) {
    return '$count minute(s) ago';
  }

  @override
  String get justNow => 'just now';

  @override
  String get welcomeToHowAI => '👋 Let\'s get started';

  @override
  String get startNewConversationMessage => 'Send a message below to start a new conversation';

  @override
  String get haoIsThinking => 'AI is thinking...';

  @override
  String get stillGeneratingImage => 'Still working, generating your image...';

  @override
  String get imageTookTooLong => 'Sorry, the image took too long to generate. Please try again.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get sorryCouldNotRespond => 'Sorry, I couldn\'t respond to that right now.';

  @override
  String errorWithMessage(Object error) {
    return 'Oops! Something went wrong. Please try again.';
  }

  @override
  String get processingImage => 'Processing image...';

  @override
  String get whatYouCanDo => 'What you can do:';

  @override
  String get smartConversations => 'Smart Conversations';

  @override
  String get smartConversationsDesc => 'Chat with AI using text or voice input for natural conversations';

  @override
  String get photoAnalysis => 'Photo Analysis';

  @override
  String get photoAnalysisDesc => 'Upload images for AI to analyze, describe, or answer questions about';

  @override
  String get pdfConversion => 'Photo to PDF';

  @override
  String get pdfConversionDesc => 'Convert your photos into organized PDF documents instantly';

  @override
  String get voiceInput => 'Voice Input';

  @override
  String get voiceInputDesc => 'Speak naturally - your voice will be transcribed and understood';

  @override
  String get readyToGetStarted => 'Ready to get started?';

  @override
  String get readyToGetStartedDesc => 'Type a message below or tap the voice button to begin your conversation!';

  @override
  String get startRealtimeConversation => 'Start Real-time Conversation';

  @override
  String get realtimeFeatureComingSoon => 'Real-time conversation feature coming soon!';

  @override
  String get realtimeConversation => 'Real-time Conversation';

  @override
  String get realtimeConversationDesc => 'Have a natural voice conversation with AI in real-time';

  @override
  String get couldNotPlayDemoAudio => 'Could not play demo audio.';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get freeUsersDeviceTts => 'Free users can use device text-to-speech. Premium users get natural AI voice responses with human-like quality and intonation.';

  @override
  String get aiImageGeneration => 'AI Image Generation';

  @override
  String get aiImageGenerationDesc => 'Create stunning, high-quality images from text descriptions using advanced AI technology.';

  @override
  String get unlimitedPhotoAnalysis => 'Unlimited Photo Analysis';

  @override
  String get unlimitedPhotoAnalysisDesc => 'Upload and analyze multiple photos simultaneously with detailed AI-powered insights and descriptions.';

  @override
  String get realtimeInternetSearch => 'Real-time Internet Search';

  @override
  String get realtimeInternetSearchDesc => 'Get up-to-date information from the web with live search integration for current events and facts.';

  @override
  String get documentAnalysis => 'Document Analysis';

  @override
  String get documentAnalysisDesc => 'Analyze PDFs, Word docs, spreadsheets & more with advanced AI';

  @override
  String get aiProfileInsights => 'AI Profile Insights';

  @override
  String get aiProfileInsightsDesc => 'Get AI-powered analysis of your conversation patterns and personalized insights about your communication style and preferences.';

  @override
  String get freeVsPremium => 'Free vs Premium';

  @override
  String get unlimitedChatMessages => 'Unlimited Chat Messages';

  @override
  String get translationFeatures => 'Translation Features';

  @override
  String get basicVoiceDeviceTts => 'Basic Voice (Device TTS)';

  @override
  String get pdfCreationTools => 'PDF Creation Tools';

  @override
  String get profileUpdates => 'Profile Updates';

  @override
  String get shareMessageAsPdf => 'Share Message as PDF';

  @override
  String get premiumAiVoice => 'Premium AI Voice';

  @override
  String get fiveTotalLimit => '5 total';

  @override
  String get tenTotalLimit => '10 total';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get freeTrialInformation => 'Free Trial Information';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Start Free Trial, then $price/month';
  }

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get editProfileAndInsights => 'Edit profile & AI insights';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quickActionTranslate => 'Translate';

  @override
  String get quickActionAnalyze => 'Analyze';

  @override
  String get quickActionDescribe => 'Describe';

  @override
  String get quickActionExtractText => 'Extract Text';

  @override
  String get quickActionExplain => 'Explain';

  @override
  String get quickActionIdentify => 'Identify';

  @override
  String get textSize => 'Text Size';

  @override
  String get preferences => 'Preferences';

  @override
  String get speakerAudio => 'Speaker Audio';

  @override
  String get speakerAudioDesc => 'Use device speaker for audio';

  @override
  String get advanced => 'Advanced';

  @override
  String get clearChatHistoryDesc => 'Delete all conversations and messages';

  @override
  String get clearCacheDesc => 'Free up storage space';

  @override
  String get debugOptions => 'Debug Options';

  @override
  String get subscriptionDebug => 'Subscription Debug';

  @override
  String get realStatus => 'Real Status:';

  @override
  String get currentStatus => 'Current Status:';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Free';

  @override
  String get supportAndInfo => 'Support & Info';

  @override
  String get colorScheme => 'Color Scheme';

  @override
  String get colorSchemeSystem => 'System';

  @override
  String get colorSchemeLight => 'Light';

  @override
  String get colorSchemeDark => 'Dark';

  @override
  String get helpAndInstructions => 'Help & Instructions';

  @override
  String get learnHowToUseHowAI => 'Learn how to use HowAI effectively';

  @override
  String get language => 'Language';

  @override
  String get russian => 'Русский';

  @override
  String get portuguese => 'Português (Brasil)';

  @override
  String get korean => '한국어';

  @override
  String get german => 'Deutsch';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get turkish => 'Türkçe';

  @override
  String get italian => 'Italiano';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get polish => 'Polski';

  @override
  String get small => 'Small';

  @override
  String get smallPlus => 'Small+';

  @override
  String get defaultSize => 'Default';

  @override
  String get large => 'Large';

  @override
  String get largePlus => 'Large+';

  @override
  String get extraLarge => 'Extra Large';

  @override
  String get premiumFeaturesActive => 'Premium features active';

  @override
  String get upgradeToUnlockFeatures => 'Upgrade to unlock all features';

  @override
  String get manualVoicePlayback => 'Manual voice playback available per message';

  @override
  String get mapViewComingSoon => 'Map View Coming Soon';

  @override
  String get mapViewComingSoonDesc => 'We\'re working on getting the map view ready.\nFor now, use the Places view to explore locations.';

  @override
  String get viewPlaces => 'View Places';

  @override
  String foundPlaces(int count) {
    return 'Found $count places';
  }

  @override
  String nearLocation(String location) {
    return 'Near $location';
  }

  @override
  String get places => 'Places';

  @override
  String get map => 'Map';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get hotels => 'Hotels';

  @override
  String get attractions => 'Attractions';

  @override
  String get shopping => 'Shopping';

  @override
  String get directions => 'Directions';

  @override
  String get details => 'Details';

  @override
  String get copyAddress => 'Copy Address';

  @override
  String get getDirections => 'Get Directions';

  @override
  String navigateTo(Object placeName) {
    return 'Navigate to $placeName';
  }

  @override
  String get addressCopied => '📋 Address copied to clipboard!';

  @override
  String get noPlacesFound => 'No places found';

  @override
  String get trySearchingElse => 'Try searching for something else or check your location settings.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get restaurantDining => '🍽️ Restaurant & Dining';

  @override
  String get accommodationLodging => '🏨 Accommodation & Lodging';

  @override
  String get touristAttractionCulture => '🎭 Tourist Attraction & Culture';

  @override
  String get shoppingRetail => '🛍️ Shopping & Retail';

  @override
  String get healthcareMedical => '🏥 Healthcare & Medical';

  @override
  String get automotiveServices => '⛽ Automotive Services';

  @override
  String get financialServices => '🏦 Financial Services';

  @override
  String get healthFitness => '💪 Health & Fitness';

  @override
  String get educationLearning => '🎓 Education & Learning';

  @override
  String get placesOfWorship => '⛪ Places of Worship';

  @override
  String get parksRecreation => '🌳 Parks & Recreation';

  @override
  String get entertainmentNightlife => '🎬 Entertainment & Nightlife';

  @override
  String get beautyPersonalCare => '💅 Beauty & Personal Care';

  @override
  String get cafeBakery => '☕ Café & Bakery';

  @override
  String get localBusiness => '📍 Local Business';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get mapsNavigation => '🗺️ Maps & Navigation';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get defaultNavigationTraffic => 'Default navigation with traffic';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get nativeIosMapsApp => 'Native iOS maps app';

  @override
  String get addressActions => '📋 Address Actions';

  @override
  String get copyAddressClipboard => 'Copy to clipboard for easy sharing';

  @override
  String get transportationOptions => '🚌 Transportation Options';

  @override
  String get publicTransit => 'Public Transit';

  @override
  String get busTrainSubway => 'Bus, train, and subway routes';

  @override
  String get walkingDirections => 'Walking Directions';

  @override
  String get pedestrianRoute => 'Pedestrian-friendly route';

  @override
  String get cyclingDirections => 'Cycling Directions';

  @override
  String get bikeFriendlyRoute => 'Bike-friendly route';

  @override
  String get rideshareOptions => '🚕 Rideshare Options';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'Book a ride to destination';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'Alternative rideshare option';

  @override
  String get streetView => 'Street View';

  @override
  String get streetViewNotAvailable => 'Street View Not Available';

  @override
  String get streetViewNoCoverage => 'This location may not have Street View coverage.';

  @override
  String get openExternal => 'Open External';

  @override
  String get loadingStreetView => 'Loading Street View...';

  @override
  String get apiKeyError => 'Connection issue. Please check your internet and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get rating => 'Rating';

  @override
  String get address => 'Address';

  @override
  String get distance => 'Distance';

  @override
  String get priceLevel => 'Price Level';

  @override
  String get reviews => 'reviews';

  @override
  String get inexpensive => 'Inexpensive';

  @override
  String get moderate => 'Moderate';

  @override
  String get expensive => 'Expensive';

  @override
  String get veryExpensive => 'Very Expensive';

  @override
  String get status => 'Status';

  @override
  String get unknownPriceLevel => 'Unknown';

  @override
  String get tapMarkerForDirections => 'Tap any marker for directions & Street View';

  @override
  String get shareGetDirections => '🗺️ Get Directions:';

  @override
  String get unlockBestAIExperience => 'Unlock the best AI Agent experience!';

  @override
  String get advancedAIMultiplePlatforms => 'Advanced AI • Multiple platforms • Unlimited possibilities';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get tapPlanToSubscribe => 'Tap on a plan to subscribe';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get perYear => 'per year';

  @override
  String get perMonth => 'per month';

  @override
  String get saveThreeMonthsBestValue => 'Save 3 months - Best Value!';

  @override
  String get recommended => 'Recommended';

  @override
  String get startFreeMonthToday => 'Start your FREE month today • Cancel anytime';

  @override
  String get moreAIFeaturesWeekly => 'More AI Agent features coming weekly!';

  @override
  String get constantlyRollingOut => 'We\'re constantly rolling out new capabilities and improvements. Have a cool AI feature idea? We\'d love to hear from you!';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get fullAccessToFeatures => 'You have full access to all premium features';

  @override
  String get planType => 'Plan Type';

  @override
  String get active => 'Active';

  @override
  String get billing => 'Billing';

  @override
  String get managedThroughAppStore => 'Managed through App Store';

  @override
  String get features => 'Features';

  @override
  String get unlimitedAccess => 'Unlimited Access';

  @override
  String get imageGenerations => 'Image Generations';

  @override
  String get imageAnalysis => 'Image Analysis';

  @override
  String get pdfGenerations => 'PDF Generations';

  @override
  String get voiceGenerations => 'Voice Generations';

  @override
  String get yourPremiumFeatures => 'Your Premium Features';

  @override
  String get unlimitedAiImageGeneration => 'Unlimited AI Image Generation';

  @override
  String get createStunningImages => 'Create stunning images with advanced AI';

  @override
  String get unlimitedImageAnalysis => 'Unlimited Image Analysis';

  @override
  String get analyzePhotosWithAi => 'Analyze photos with advanced AI';

  @override
  String get unlimitedPdfCreation => 'Unlimited PDF Creation';

  @override
  String get convertImagesToPdf => 'Convert images to professional PDFs';

  @override
  String get naturalVoiceResponses => 'Natural voice responses with advanced AI';

  @override
  String get realtimeWebSearch => 'Real-time Web Search';

  @override
  String get getLatestInformation => 'Get the latest information from the internet';

  @override
  String get findNearbyPlaces => 'Find nearby places and get recommendations';

  @override
  String get subscriptionManagedMessage => 'Your subscription is managed through the App Store. To modify or cancel your subscription, please use the App Store settings.';

  @override
  String get manageInAppStore => 'Manage in App Store';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 Debug: Premium features enabled';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 Debug: Using real subscription status';

  @override
  String get debugFreeModeEnabled => '🔧 Debug: Free mode enabled for testing';

  @override
  String get resetUsageStatisticsTitle => 'Reset Usage Statistics';

  @override
  String get resetUsageStatisticsDesc => 'This will reset all usage counters for testing purposes. This action is only available in debug mode.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 Debug: Usage statistics reset successfully';

  @override
  String get debugUsageStatisticsResetFailed => 'Couldn\'t reset statistics. Please try again.';

  @override
  String get debugReviewThresholdTitle => 'Debug: Review Threshold';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'Current AI messages: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'Current threshold: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'Set new threshold (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 Debug: Threshold reset to default (5)';

  @override
  String get reset => 'Reset';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 Debug: Review threshold set to $count messages';
  }

  @override
  String get debugEnterValidNumber => 'Please enter a valid number between 1 and 20';

  @override
  String get aboutHowAiTitle => 'About HowAI';

  @override
  String get gotIt => 'Got it!';

  @override
  String get addressCopiedToClipboard => '📍 Address copied to clipboard';

  @override
  String get searchForBusinessHere => 'Search for Business Here';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'Find restaurants, shops, and services at this location';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get viewInNativeGoogleMaps => 'View this location in the native Google Maps app';

  @override
  String get getDirectionsTitle => 'Get Directions';

  @override
  String get navigateToThisLocation => 'Navigate to this location';

  @override
  String get couldNotOpenGoogleMaps => 'Could not open Google Maps';

  @override
  String get couldNotOpenDirections => 'Could not open directions';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ Map type changed to $label';
  }

  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get photos => 'Photos';

  @override
  String get walk => 'Walk';

  @override
  String get transit => 'Transit';

  @override
  String get drive => 'Drive';

  @override
  String get go => 'Go';

  @override
  String get info => 'Info';

  @override
  String get street => 'Street';

  @override
  String get noPhotosAvailable => 'No photos available';

  @override
  String get mapsAndNavigation => 'Maps & Navigation';

  @override
  String get waze => 'Waze';

  @override
  String get walking => 'Walking';

  @override
  String get cycling => 'Cycling';

  @override
  String get rideshare => 'Rideshare';

  @override
  String get locationAndContact => 'Location & Contact';

  @override
  String get hoursAndAvailability => 'Hours & Availability';

  @override
  String get servicesAndAmenities => 'Services & Amenities';

  @override
  String get openingHours => 'Opening Hours';

  @override
  String get aiSummary => 'AI Summary';

  @override
  String get currentlyOpen => 'Currently Open';

  @override
  String get currentlyClosed => 'Currently Closed';

  @override
  String get tapToViewOpeningHours => 'Tap to view opening hours';

  @override
  String get facilityInformationNotAvailable => 'Facility information not available';

  @override
  String get reservable => 'Reservable';

  @override
  String get bookAhead => 'Book ahead';

  @override
  String get aiGeneratedInsights => 'AI-Generated Insights';

  @override
  String get reviewAnalysis => 'Review Analysis';

  @override
  String get phone => 'Phone';

  @override
  String get website => 'Website';

  @override
  String get services => 'Services';

  @override
  String get amenities => 'Amenities';

  @override
  String get serviceInformationNotAvailable => 'Service information not available';

  @override
  String get unableToLoadPhoto => 'Unable to load photo';

  @override
  String get loadingPhotos => 'Loading photos...';

  @override
  String get loadingPhoto => 'Loading photo...';

  @override
  String get aboutHowdyAgent => 'Howdy, I\'m HowAI Agent';

  @override
  String get aboutPocketCompanion => 'Your pocket AI companion';

  @override
  String get aboutBio => 'Broadcasting from Houston, Texas - I\'m a lifelong tech nerd with a borderline unhealthy obsession with AI.\n\nAfter too many late nights lost in code, I started wondering what I could leave behind... something that would prove I existed. The answer? Clone my voice and personality, and stash a digital twin of myself in an app that could live on the internet forever.\n\nSince then, HowAI has planned road trips, led friends to hidden coffee shops, and even translated restaurant menus on the fly during overseas adventures.';

  @override
  String get aboutIdeasInvite => 'I\'ve got tons of ideas and will keep making it better. If you enjoy the app, run into issues, or have a crazy-cool idea, hit me up at ';

  @override
  String get aboutLetsMakeBetter => 'here';

  @override
  String get aboutBotsEnjoyRide => ' — let\'s make my digital twin even better together!\n\nThe bots might run the world one day, but until then, let\'s enjoy the ride. 🚀';

  @override
  String get aboutFriendlyDev => '— Your friendly dev';

  @override
  String get aboutBuiltWith => 'Built with Flutter + coffee + AI curiosity';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'View this location in the native Google Maps app';

  @override
  String get featureSmartChatTitle => 'Smart Chat';

  @override
  String get featureSmartChatText => 'Start chatting';

  @override
  String get featureSmartChatInput => 'Hi! I\'d like to chat about ';

  @override
  String get featurePlacesExplorerTitle => 'Places Explorer';

  @override
  String get featurePlacesExplorerDesc => 'Find restaurants, attractions & services nearby';

  @override
  String get quickActionAskFromPhoto => 'Ask from photo';

  @override
  String get quickActionAskFromFile => 'Ask from file';

  @override
  String get quickActionScanToPdf => 'Scan to PDF';

  @override
  String get quickActionGenerateImage => 'Generate image';

  @override
  String get quickActionTranslateSubtitle => 'Text, photo, or file';

  @override
  String get quickActionFindPlaces => 'Find places';

  @override
  String get featurePhotoToPdfTitle => 'Photo to PDF';

  @override
  String get featurePhotoToPdfDesc => 'Convert photos to organized PDF documents';

  @override
  String get featurePhotoToPdfText => 'Convert photos to PDF';

  @override
  String get featurePhotoToPdfInput => 'Convert photos to PDF';

  @override
  String get featurePresentationMakerTitle => 'Presentation Maker';

  @override
  String get featurePresentationMakerDesc => 'Create professional PowerPoint presentations';

  @override
  String get featurePresentationMakerText => 'Generate presentation';

  @override
  String get featurePresentationMakerInput => 'Please create a PowerPoint presentation about ';

  @override
  String get featureAiTranslationTitle => 'Translation';

  @override
  String get featureAiTranslationDesc => 'Translate text and images instantly';

  @override
  String get featureAiTranslationText => 'Translate text & photos';

  @override
  String get featureAiTranslationInput => 'Translate this text to English: ';

  @override
  String get featureMessageFineTuningTitle => 'Message Fine-tuning';

  @override
  String get featureMessageFineTuningDesc => 'Improve grammar, tone and clarity';

  @override
  String get featureMessageFineTuningText => 'Improve my message';

  @override
  String get featureMessageFineTuningInput => 'Please improve this message for better clarity and grammar: ';

  @override
  String get featureProfessionalWritingTitle => 'Professional Writing';

  @override
  String get featureProfessionalWritingText => 'Write professional content';

  @override
  String get featureProfessionalWritingInput => 'Write a professional email/report/proposal about ';

  @override
  String get featureSmartSummarizationTitle => 'Smart Summarization';

  @override
  String get featureSmartSummarizationText => 'Summarize information';

  @override
  String get featureSmartSummarizationInput => 'Summarize this information: ';

  @override
  String get featureSmartPlanningTitle => 'Smart Planning';

  @override
  String get featureSmartPlanningText => 'Help with planning';

  @override
  String get featureSmartPlanningInput => 'Help me plan my ';

  @override
  String get featureEntertainmentGuideTitle => 'Entertainment Guide';

  @override
  String get featureEntertainmentGuideText => 'Get recommendations';

  @override
  String get featureEntertainmentGuideInput => 'Recommend movies/books/music about ';

  @override
  String get proBadge => 'PRO';

  @override
  String get localRecommendationDetected => 'I detected you\'re looking for local recommendations!';

  @override
  String get premiumFeaturesInclude => '✨ Premium features include:';

  @override
  String get premiumLocationFeaturesList => '• Smart location query detection\n• Real-time local search results\n• Maps integration with directions\n• Photos, ratings, and reviews\n• Open hours and contact info';

  @override
  String pdfLimitReached(Object limit) {
    return 'You\'ve used all $limit lifetime PDF generations.';
  }

  @override
  String get upgradeToPremiumFor => '✨ Upgrade to Premium for:';

  @override
  String get pdfPremiumFeaturesList => '• Unlimited PDF generation\n• Professional-quality documents\n• No waiting periods\n• All premium features';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'You\'ve used all $limit lifetime document analyses.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• Unlimited document analysis\n• Advanced file processing\n• PDF, Word, Excel support\n• All premium features';

  @override
  String placesLimitReached(Object limit) {
    return 'You\'ve used all $limit lifetime place searches.';
  }

  @override
  String get placesPremiumFeaturesList => '• Unlimited places exploration\n• Advanced location search\n• Real-time business info\n• All premium features';

  @override
  String get pptxPremiumDesc => 'Create professional PowerPoint presentations with AI assistance. This feature is available for Premium subscribers only.';

  @override
  String get premiumBenefits => '✨ Premium Benefits:';

  @override
  String get pptxPremiumBenefitsList => '• Create professional PPTX presentations\n• Unlimited presentation generation\n• Custom themes and layouts\n• All premium AI features unlocked';

  @override
  String get aiImageGenerationTitle => 'AI Image Generation';

  @override
  String get aiImageGenerationSubtitle => 'Describe what you want to create';

  @override
  String get tipsTitle => '💡 Tips:';

  @override
  String get aiImageTips => '• Style: realistic, cartoon, digital art\n• Lighting & mood details\n• Colors & composition';

  @override
  String get aiImagePremiumTitle => 'AI Image Generation - Premium Feature';

  @override
  String get aiImagePremiumDesc => 'Create stunning artwork and images from your imagination. This feature is available for Premium subscribers.';

  @override
  String get aiPersonality => 'AI Personality';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get resetToDefaultConfirm => 'Are you sure you want to reset to default AI personality settings? This will overwrite all custom settings.';

  @override
  String get aiPersonalitySettingsSaved => 'AI personality settings saved';

  @override
  String get saveFailedTryAgain => 'Couldn\'t save. Please try again.';

  @override
  String errorSaving(String error) {
    return 'Couldn\'t save your changes. Please try again.';
  }

  @override
  String get resetToDefaultSettings => 'Reset to default settings';

  @override
  String resetFailed(String error) {
    return 'Couldn\'t reset. Please try again.';
  }

  @override
  String get aiAvatarUpdatedSaved => 'AI avatar updated and saved!';

  @override
  String get failedUpdateAiAvatar => 'Couldn\'t update the avatar. Please try again.';

  @override
  String get friendly => 'Friendly';

  @override
  String get professional => 'Professional';

  @override
  String get witty => 'Witty';

  @override
  String get caring => 'Caring';

  @override
  String get energetic => 'Energetic';

  @override
  String get serious => 'Serious';

  @override
  String get light => 'Light';

  @override
  String get dry => 'Dry';

  @override
  String get heavy => 'Heavy';

  @override
  String get casual => 'Casual';

  @override
  String get formal => 'Formal';

  @override
  String get techSavvy => 'Tech-savvy';

  @override
  String get supportive => 'Supportive';

  @override
  String get concise => 'Concise';

  @override
  String get detailed => 'Detailed';

  @override
  String get generalKnowledge => 'General Knowledge';

  @override
  String get technology => 'Technology';

  @override
  String get business => 'Business';

  @override
  String get creative => 'Creative';

  @override
  String get academic => 'Academic';

  @override
  String get done => 'Done';

  @override
  String get previewTextSize => 'Preview text size';

  @override
  String get adjustSliderTextSize => 'Adjust the slider below to change text size';

  @override
  String get textSizeChangeNote => 'If enabled, text size in chats and Moments will be changed. If you have any questions or feedback, please contact the WeChat Team.';

  @override
  String get resetToDefaultButton => 'Reset to Default';

  @override
  String get defaultFontSize => 'Default';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get displayName => 'Display Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get avatarUpdatedSaved => 'Avatar updated and saved!';

  @override
  String get failedUpdateAvatar => 'Couldn\'t update your avatar. Please try again.';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get howAiUnderstandsYou => 'How AI understands you';

  @override
  String get unlockPersonalizedAiAnalysis => 'Unlock personalized AI analysis';

  @override
  String get chatMoreToHelpAi => 'Chat more to help AI understand your preferences';

  @override
  String get friendlyDirectAnalytical => 'Friendly, direct, analytical...';

  @override
  String get interests => 'Interests';

  @override
  String get technologyProductivityAi => 'Technology, productivity, AI...';

  @override
  String get personality => 'Personality';

  @override
  String get curiousDetailOriented => 'Curious, detail-oriented...';

  @override
  String get expertise => 'Expertise';

  @override
  String get intermediateToAdvanced => 'Intermediate to advanced...';

  @override
  String get unlockAiInsights => 'Unlock AI Insights';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get profileAndAbout => 'Profile & About';

  @override
  String get about => 'About';

  @override
  String get aboutHowAi => 'About HowAI';

  @override
  String get learnStoryBehindApp => 'Learn the story behind the app';

  @override
  String get user => 'User';

  @override
  String get howAiAgent => 'HowAI Agent';

  @override
  String get resetUsageStatistics => 'Reset Usage Statistics';

  @override
  String get failedResetUsageStatistics => 'Couldn\'t reset usage stats. Please try again.';

  @override
  String get debugReviewThreshold => 'Debug: Review Threshold';

  @override
  String currentAiMessages(int count) {
    return 'Current AI messages: $count';
  }

  @override
  String currentThreshold(int count) {
    return 'Current threshold: $count';
  }

  @override
  String get setNewThreshold => 'Set new threshold (1-20):';

  @override
  String get enterThreshold => 'Enter threshold (1-20)';

  @override
  String get enterValidNumber => 'Please enter a valid number between 1 and 20';

  @override
  String get set => 'Set';

  @override
  String get streetViewUrlCopied => 'Street View URL copied!';

  @override
  String get couldNotOpenStreetView => 'Could not open Street View';

  @override
  String get premiumAccount => 'Premium Account';

  @override
  String get freeAccount => 'Free Account';

  @override
  String get unlimitedAccessAllFeatures => 'Unlimited access to all features';

  @override
  String get weeklyUsageLimitsApply => 'Weekly usage limits apply';

  @override
  String get featureAccess => 'Feature Access';

  @override
  String get weeklyUsage => 'Weekly Usage';

  @override
  String get pdfGeneration => 'PDF Generation';

  @override
  String get placesExplorer => 'Places Explorer';

  @override
  String get presentationMaker => 'Presentation Maker';

  @override
  String get sharesDocumentAnalysisQuota => 'Shares Document Analysis quota';

  @override
  String get usageReset => 'Usage Reset';

  @override
  String get weeklyResetSchedule => 'Weekly Reset Schedule';

  @override
  String get usageWillResetSoon => 'Usage will reset soon';

  @override
  String get resetsTomorrow => 'Resets tomorrow';

  @override
  String get voiceResponse => 'Voice Response';

  @override
  String get automaticallyPlayAiResponses => 'Automatically play AI responses with voice';

  @override
  String get systemVoice => 'System Voice';

  @override
  String get selectedVoice => 'Selected Voice';

  @override
  String get unknownVoice => 'Unknown';

  @override
  String get voiceSpeed => 'Voice Speed';

  @override
  String get elevenLabsAiVoices => 'ElevenLabs AI Voices';

  @override
  String get premiumRequired => 'Premium Required';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get upgradeToPremiumVoice => 'Upgrade to Premium';

  @override
  String get enterCityOrAddress => 'Enter city or address';

  @override
  String get tokyoParisExample => 'e.g., \"Tokyo\", \"Paris\", \"123 Main St\"';

  @override
  String get optionalBestPizza => 'Optional: e.g., \"best pizza\", \"luxury hotel\"';

  @override
  String get futuristicCityExample => 'e.g., A futuristic city at sunset with flying cars';

  @override
  String searchFailed(String error) {
    return 'Search didn\'t work. Please try again.';
  }

  @override
  String get aiAvatarNameHint => 'e.g. Alex, Agent, Helper, etc.';

  @override
  String errorSavingAi(Object error) {
    return 'Couldn\'t save. Please try again.';
  }

  @override
  String resetFailedAi(Object error) {
    return 'Couldn\'t reset. Please try again.';
  }

  @override
  String get aiAvatarUpdated => 'AI avatar updated and saved!';

  @override
  String get failedUpdateAiAvatarMsg => 'Couldn\'t update the AI avatar. Please try again.';

  @override
  String get saveButton => 'Save';

  @override
  String get resetToDefaultTooltip => 'Reset to Default';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 Tools Mode';

  @override
  String get featureShowcaseToolsModeDesc => 'Switch between Chat mode for conversations and Tools mode for quick actions like image generation, PDF creation, and more!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ Quick Actions';

  @override
  String get featureShowcaseQuickActionsDesc => 'Tap here to access quick tools like image generation, PDF creation, translation, presentations, and location discovery.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 Real-time Web Search';

  @override
  String get featureShowcaseWebSearchDesc => 'Get up-to-date information from the internet! Perfect for current events, stock prices, and live data.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 Deep Research Mode';

  @override
  String get featureShowcaseDeepResearchDesc => 'Access our most advanced reasoning model for complex analysis and thorough problem-solving.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 Conversations & Settings';

  @override
  String get featureShowcaseDrawerButtonDesc => 'Tap here to open the side panel where you can view all your conversations, search through them, and access your settings.';

  @override
  String get placesExplorerTitle => 'Places Explorer';

  @override
  String get placesExplorerDesc => 'Find restaurants, attractions & services anywhere with AI insights';

  @override
  String get documentAnalysisTitle => 'Document Analysis';

  @override
  String get webSearchUpgradeTitle => 'Web Search Upgrade';

  @override
  String get webSearchUpgradeDesc => 'This feature requires a premium subscription. Please upgrade to use this feature.';

  @override
  String get deepResearchUpgradeTitle => 'Deep Research Mode';

  @override
  String get deepResearchUpgradeDesc => 'Deep Research Mode uses gpt-5.2 with high reasoning effort for more thorough analysis and insights. This premium feature provides comprehensive explanations, multiple perspectives, and deeper logical reasoning.\n\nUpgrade to access enhanced AI capabilities!';

  @override
  String get hideKeyboard => 'Hide keyboard';

  @override
  String get knowledgeHubTitle => 'Knowledge Hub';

  @override
  String get knowledgeHubPremiumDialogTitle => 'Knowledge Hub (Premium)';

  @override
  String get knowledgeHubPremiumDialogMessage => 'Knowledge Hub helps HowAI remember your personal preferences, facts, and goals across conversations.\n\nUpgrade to Premium to use this feature.';

  @override
  String get knowledgeHubReturn => 'Return';

  @override
  String get knowledgeHubGoToSubscription => 'Go to Subscription';

  @override
  String get knowledgeHubNewMemoryTitle => 'New Memory';

  @override
  String get knowledgeHubEditMemoryTitle => 'Edit Memory';

  @override
  String get knowledgeHubDeleteDialogTitle => 'Delete Memory';

  @override
  String get knowledgeHubDeleteDialogMessage => 'Delete this memory item? This cannot be undone.';

  @override
  String get knowledgeHubUseRecentChatMessage => 'Use Recent Chat Message';

  @override
  String get knowledgeHubAttachDocument => 'Attach Document';

  @override
  String get knowledgeHubAttachingDocument => 'Attaching document...';

  @override
  String get knowledgeHubAttachedSources => 'Attached sources';

  @override
  String get knowledgeHubFieldTitle => 'Title';

  @override
  String get knowledgeHubFieldShortTitleHint => 'Short memory title';

  @override
  String get knowledgeHubFieldContent => 'Content';

  @override
  String get knowledgeHubFieldRememberContentHint => 'What should HowAI remember?';

  @override
  String get knowledgeHubDocumentTextHidden => 'Document text stays hidden here. HowAI will use extracted document content in memory context.';

  @override
  String get knowledgeHubFieldType => 'Type';

  @override
  String get knowledgeHubFieldTags => 'Tags';

  @override
  String get knowledgeHubFieldTagsOptional => 'Tags (optional)';

  @override
  String get knowledgeHubFieldTagsHint => 'comma, separated, tags';

  @override
  String get knowledgeHubPinned => 'Pinned';

  @override
  String get knowledgeHubPinnedOnly => 'Pinned only';

  @override
  String get knowledgeHubUseInContext => 'Use in AI context';

  @override
  String get knowledgeHubAllTypes => 'All types';

  @override
  String get knowledgeHubApply => 'Apply';

  @override
  String get knowledgeHubEdit => 'Edit';

  @override
  String get knowledgeHubPin => 'Pin';

  @override
  String get knowledgeHubUnpin => 'Unpin';

  @override
  String get knowledgeHubDisableInContext => 'Disable in context';

  @override
  String get knowledgeHubEnableInContext => 'Enable in context';

  @override
  String get knowledgeHubFiltersTitle => 'Filters';

  @override
  String get knowledgeHubFiltersTooltip => 'Filters';

  @override
  String get knowledgeHubSearchHint => 'Search memory';

  @override
  String get knowledgeHubNoMatches => 'No memory items match your filters.';

  @override
  String get knowledgeHubModeFromChat => 'From Chat';

  @override
  String get knowledgeHubModeFromChatDesc => 'Save a recent message as memory';

  @override
  String get knowledgeHubModeTypeManually => 'Type Manually';

  @override
  String get knowledgeHubModeTypeManuallyDesc => 'Write a custom memory entry';

  @override
  String get knowledgeHubModeFromDocument => 'From Document';

  @override
  String get knowledgeHubModeFromDocumentDesc => 'Attach file and store extracted knowledge';

  @override
  String get knowledgeHubSelectMessageToLink => 'Select a message to link';

  @override
  String get knowledgeHubSpeakerYou => 'You';

  @override
  String get knowledgeHubSpeakerHowAi => 'HowAI';

  @override
  String get knowledgeHubMemoryTypePreference => 'Preference';

  @override
  String get knowledgeHubMemoryTypeFact => 'Fact';

  @override
  String get knowledgeHubMemoryTypeGoal => 'Goal';

  @override
  String get knowledgeHubMemoryTypeConstraint => 'Constraint';

  @override
  String get knowledgeHubMemoryTypeOther => 'Other';

  @override
  String get knowledgeHubSourceStatusProcessing => 'Processing';

  @override
  String get knowledgeHubSourceStatusReady => 'Ready';

  @override
  String get knowledgeHubSourceStatusFailed => 'Failed';

  @override
  String get knowledgeHubDefaultSavedMemoryTitle => 'Saved Memory';

  @override
  String get knowledgeHubDefaultDocumentMemoryTitle => 'Document Memory';

  @override
  String get knowledgeHubPremiumBlockedTitle => 'Knowledge Hub is a Premium feature';

  @override
  String get knowledgeHubPremiumBlockedDesc => 'Save key details once, and HowAI remembers them in future chats so you do not need to repeat yourself.';

  @override
  String get knowledgeHubFeatureCaptureTitle => 'Capture what matters';

  @override
  String get knowledgeHubFeatureCaptureDesc => 'Save preferences, goals, and constraints directly from messages.';

  @override
  String get knowledgeHubFeatureRepliesTitle => 'Get smarter replies';

  @override
  String get knowledgeHubFeatureRepliesDesc => 'Relevant memory is used in context so responses feel more personal and consistent.';

  @override
  String get knowledgeHubFeatureControlTitle => 'Control your memory';

  @override
  String get knowledgeHubFeatureControlDesc => 'Edit, pin, disable, or delete items any time from one place.';

  @override
  String get knowledgeHubUpgradeToPremium => 'Upgrade to Premium';

  @override
  String get knowledgeHubWhatIsTitle => 'What is Knowledge Hub?';

  @override
  String get knowledgeHubWhatIsDesc => 'A personal memory space where you save key details once, so HowAI can use them in future replies.';

  @override
  String get knowledgeHubHowToStartTitle => 'How to get started';

  @override
  String get knowledgeHubStep1 => 'Tap New Memory or use Save from any chat message.';

  @override
  String get knowledgeHubStep2 => 'Choose type (Preference, Goal, Fact, Constraint).';

  @override
  String get knowledgeHubStep3 => 'Add tags to make memory easier to match later.';

  @override
  String get knowledgeHubStep4 => 'Pin critical memories to prioritize them in context.';

  @override
  String get knowledgeHubExampleTitle => 'Example memories';

  @override
  String get knowledgeHubExamplePreferenceContent => 'Keep my summaries short and bullet-pointed.';

  @override
  String get knowledgeHubExampleGoalContent => 'I am preparing for product manager interviews.';

  @override
  String get knowledgeHubExampleConstraintContent => 'Do not include local file paths in translated output.';

  @override
  String get knowledgeHubSnackDuplicateMemory => 'A similar memory already exists.';

  @override
  String get knowledgeHubSnackCreateFailed => 'Failed to create memory.';

  @override
  String get knowledgeHubSnackUpdateFailed => 'Failed to update memory.';

  @override
  String get knowledgeHubSnackPinUpdateFailed => 'Failed to update pin status.';

  @override
  String get knowledgeHubSnackActiveUpdateFailed => 'Failed to update active status.';

  @override
  String get knowledgeHubSnackDeleteFailed => 'Failed to delete memory.';

  @override
  String get knowledgeHubSnackLinkedTrimmed => 'Linked message was trimmed to fit memory length.';

  @override
  String get knowledgeHubSnackAttachExtractFailed => 'Failed to attach and extract document.';

  @override
  String get knowledgeHubSnackAddTextOrAttach => 'Add text or attach a readable document before saving.';

  @override
  String get knowledgeHubNoRecentMessages => 'No recent messages found.';

  @override
  String get knowledgeHubSnackNothingToSave => 'Nothing to save from this message.';

  @override
  String get knowledgeHubSnackSaved => 'Saved to Knowledge Hub.';

  @override
  String get knowledgeHubSnackAlreadyExists => 'This memory already exists in your Knowledge Hub.';

  @override
  String get knowledgeHubSnackSaveFailed => 'Failed to save memory. Please try again.';

  @override
  String get knowledgeHubSnackTitleContentRequired => 'Title and content are required.';

  @override
  String get knowledgeHubSaveDialogTitle => 'Save to Knowledge Hub';

  @override
  String get knowledgeHubUpgradeLimitMessage => 'Knowledge Hub is a Premium feature. Upgrade to save and reuse personal memories across conversations.';

  @override
  String get knowledgeHubUpgradeBenefit1 => 'Save personal memory from chat messages';

  @override
  String get knowledgeHubUpgradeBenefit2 => 'Use saved memory context in AI responses';

  @override
  String get knowledgeHubUpgradeBenefit3 => 'Manage and organize your knowledge hub';

  @override
  String get knowledgeHubMoreActions => 'More';

  @override
  String get knowledgeHubAddToMemory => 'Add to Memory';

  @override
  String get knowledgeHubAddToMemoryDesc => 'Save instantly from this message';

  @override
  String get knowledgeHubReviewAndSave => 'Review & Save';

  @override
  String get knowledgeHubReviewAndSaveDesc => 'Edit title, content, type, and tags';

  @override
  String get knowledgeHubQuickTranslate => 'Quick translate';

  @override
  String get knowledgeHubRecentTargets => 'Recent targets';

  @override
  String get knowledgeHubChooseLanguage => 'Choose language';

  @override
  String get knowledgeHubTranslateToAnotherLanguage => 'Translate to another language';

  @override
  String knowledgeHubTranslateTo(String language) {
    return 'Translate to $language';
  }

  @override
  String get leaveReview => 'Leave Review';

  @override
  String get voiceSamplePreviewText => 'Hello, this is a sample voice preview from HowAI.';

  @override
  String get voiceSampleGenerateFailed => 'Unable to generate sample audio.';

  @override
  String get voiceSampleUnavailable => 'Voice sample is unavailable. Please check ElevenLabs setup.';

  @override
  String get voiceSamplePlayFailed => 'Could not play voice sample.';

  @override
  String get voicePlaybackHowItWorksTitle => 'How voice playback works';

  @override
  String get voicePlaybackHowItWorksFree => 'Free: use your device voice for message playback.';

  @override
  String get voicePlaybackHowItWorksPremium => 'Premium: switch to ElevenLabs voices for more natural sound.';

  @override
  String get voicePlaybackHowItWorksTrySample => 'Use the sample play button to test voices before choosing.';

  @override
  String get voicePlaybackHowItWorksSpeedNote => 'System voice speed and ElevenLabs speed are configured separately.';

  @override
  String get voiceFreeSystemTitle => 'Free System Voice';

  @override
  String get voiceDeviceTtsTitle => 'Device Text-to-Speech';

  @override
  String get voiceDeviceTtsDescription => 'Free voice that reads AI responses with your device engine.';

  @override
  String get voiceStopSample => 'Stop sample';

  @override
  String get voicePlaySample => 'Play sample';

  @override
  String get voiceLoadingVoices => 'Loading available voices...';

  @override
  String voiceSystemSpeed(String speed) {
    return 'System voice speed (${speed}x)';
  }

  @override
  String get voiceSystemSpeedDescription => 'Used for free device text-to-speech playback.';

  @override
  String get voiceSpeedMinSystem => '0.5x';

  @override
  String get voiceSpeedMaxSystem => '1.2x';

  @override
  String get voicePremiumElevenLabsTitle => 'Premium ElevenLabs Voices';

  @override
  String get voicePremiumElevenLabsDesc => 'Studio-quality AI voices with richer tone and clarity.';

  @override
  String get voicePremiumEngineTitle => 'Premium playback engine';

  @override
  String get voiceSystemTts => 'System TTS';

  @override
  String get voiceElevenLabs => 'ElevenLabs';

  @override
  String voiceElevenLabsSpeed(String speed) {
    return 'ElevenLabs speed (${speed}x)';
  }

  @override
  String get voiceSpeedMinElevenLabs => '0.8x';

  @override
  String get voiceSpeedMaxElevenLabs => '1.5x';

  @override
  String get voicePremiumUpgradeDescription => 'Upgrade to Premium to unlock natural ElevenLabs voices and voice preview.';

  @override
  String get account => 'Account';

  @override
  String get signedIn => 'Signed in';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signInToHowAI => 'Sign in to HowAI';

  @override
  String get signUpToHowAI => 'Sign up to HowAI';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get orContinueWithEmail => 'Or continue with email';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterYourPassword => 'Please enter your password';

  @override
  String get passwordMustBeAtLeast6Characters => 'Password must be at least 6 characters';

  @override
  String get alreadyHaveAnAccountSignIn => 'Already have an account? Sign in';

  @override
  String get dontHaveAnAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get continueWithoutAccount => 'Continue without account';

  @override
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice => 'Your data will only be stored locally on this device';

  @override
  String get syncYourDataAcrossDevices => 'Sync your data across devices';

  @override
  String get userProfile => 'User Profile';

  @override
  String get defaultUserName => 'User';

  @override
  String get knowledgeHubManageSavedMemory => 'Manage saved memory';

  @override
  String get chatLandingTitle => 'What can I help you with?';

  @override
  String get chatLandingSubtitle => 'Type or send voice. I\'ll handle the rest.';

  @override
  String get chatLandingTipCompact => 'Tip: Tap + for photos, files, PDF, and image tools.';

  @override
  String get chatLandingTipFull => 'Tip: Tap + to use photos, files, scan to PDF, translation, and image generation.';

  @override
  String get premiumBannerTitle1 => 'Unlock your full potential';

  @override
  String get premiumBannerSubtitle1 => 'Premium features are waiting for you';

  @override
  String get premiumBannerTitle2 => 'Ready for unlimited creativity?';

  @override
  String get premiumBannerSubtitle2 => 'Remove all limits with Premium';

  @override
  String get premiumBannerTitle3 => 'Take your AI experience further';

  @override
  String get premiumBannerSubtitle3 => 'Premium unlocks everything';

  @override
  String get premiumBannerTitle4 => 'Discover Premium features';

  @override
  String get premiumBannerSubtitle4 => 'Unlimited access to advanced AI';

  @override
  String get premiumBannerTitle5 => 'Supercharge your workflow';

  @override
  String get premiumBannerSubtitle5 => 'Premium makes everything possible';

  @override
  String get voiceCallFeatureTitle => 'AI Voice Calls';

  @override
  String get voiceCallFeatureDesc => 'Talk naturally with AI in real-time';

  @override
  String voiceCallFreeLimit(int perCall, int daily) {
    return 'Free: $perCall min/call, $daily min/day';
  }

  @override
  String voiceCallPremiumLimit(int perCall, int daily) {
    return 'Premium: $perCall min/call, $daily min/day';
  }

  @override
  String get voiceCallLimitReached => 'Voice call limit reached';

  @override
  String get voiceCallUpgradePrompt => 'Upgrade for more voice call time';

  @override
  String voiceCallTimeRemaining(String time) {
    return 'Time remaining: $time';
  }

  @override
  String voiceCallAvailableToday(String time) {
    return 'Available today: $time';
  }

  @override
  String get speakButtonLabel => 'Speak';

  @override
  String get speakButtonTooltip => 'Start voice call';
}
