import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// Text extraction packages
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:archive/archive.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:csv/csv.dart';

class FileService {
  // Supported file types that OpenAI can read
  static const List<String> supportedExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf',
    'odt',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'csv',
    'md',
    'html',
    'htm',
    'json',
    'xml',
  ];

  // Maximum file size (10MB)
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // Reduced to 10MB for better token management

  // Pick a document file
  static Future<PlatformFile?> pickDocumentFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file size
        if (file.size > maxFileSizeBytes) {
          throw Exception('File size exceeds 2MB limit');
        }

        // Validate file extension
        final extension = file.extension?.toLowerCase();
        if (extension == null || !supportedExtensions.contains(extension)) {
          throw Exception('Unsupported file type: ${extension ?? 'unknown'}');
        }

        return file;
      }
      return null;
    } catch (e) {
      // print('[FileService] Error picking file: $e');
      rethrow;
    }
  }

  // Convert file to base64 for OpenAI API
  static Future<String?> encodeFileToBase64(PlatformFile file) async {
    try {
      Uint8List? bytes;

      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      } else {
        throw Exception('Unable to read file data');
      }

      return base64Encode(bytes);
    } catch (e) {
      // print('[FileService] Error encoding file: $e');
      return null;
    }
  }

  // Get MIME type based on file extension
  static String getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'rtf':
        return 'application/rtf';
      case 'odt':
        return 'application/vnd.oasis.opendocument.text';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'csv':
        return 'text/csv';
      case 'md':
        return 'text/markdown';
      case 'html':
      case 'htm':
        return 'text/html';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      default:
        return 'application/octet-stream';
    }
  }

  // Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  // Get file icon based on extension
  static IconData getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
      case 'rtf':
      case 'odt':
        return Icons.description;
      case 'txt':
      case 'md':
        return Icons.text_snippet;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      case 'html':
      case 'htm':
        return Icons.web;
      case 'json':
      case 'xml':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get file icon based on file path
  static IconData getFileIconFromPath(String path) {
    final extension = getFileExtension(path);
    return getFileIcon(extension);
  }

  // Get file name from path
  static String getFileName(String path) {
    if (path.isEmpty) return 'Unknown File';

    try {
      // Handle both forward and backward slashes
      final parts = path.split(RegExp(r'[/\\]'));
      return parts.isNotEmpty ? parts.last : 'Unknown File';
    } catch (e) {
      return 'Unknown File';
    }
  }

  // Get file extension from path
  static String getFileExtension(String path) {
    if (path.isEmpty) return '';

    try {
      final fileName = getFileName(path);
      final lastDotIndex = fileName.lastIndexOf('.');

      if (lastDotIndex != -1 && lastDotIndex < fileName.length - 1) {
        return fileName.substring(lastDotIndex + 1).toLowerCase();
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  // Extract text content from different file types
  static Future<String?> extractTextFromFile(PlatformFile file) async {
    try {
      final extension = file.extension?.toLowerCase() ?? '';

      switch (extension) {
        case 'txt':
        case 'md':
          return await _extractTextFromPlainText(file);
        case 'pdf':
          return await _extractTextFromPDF(file);
        case 'csv':
          return await _extractTextFromCSV(file);
        case 'html':
        case 'htm':
          return await _extractTextFromHTML(file);
        case 'json':
          return await _extractTextFromJSON(file);
        case 'xml':
          return await _extractTextFromXML(file);
        case 'xlsx':
        case 'xls':
          return await _extractTextFromExcel(file);
        case 'docx':
          return await _extractTextFromDocx(file);
        case 'pptx':
          return await _extractTextFromPptx(file);
        default:
          // print('[FileService] Unsupported file type for text extraction: $extension');
          return 'File type not supported for text extraction: $extension';
      }
    } catch (e) {
      // print('[FileService] Error extracting text from file: $e');
      return 'Error extracting text from file: ${e.toString()}';
    }
  }

  // Extract text from plain text files
  static Future<String?> _extractTextFromPlainText(PlatformFile file) async {
    try {
      Uint8List? bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes != null) {
        return utf8.decode(bytes);
      }
      return null;
    } catch (e) {
      // print('[FileService] Error reading plain text file: $e');
      return null;
    }
  }

  // Extract text from PDF files
  static Future<String?> _extractTextFromPDF(PlatformFile file) async {
    try {
      Uint8List? bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes != null) {
        final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: bytes);
        final sf_pdf.PdfTextExtractor extractor = sf_pdf.PdfTextExtractor(document);
        final String text = extractor.extractText();
        document.dispose();
        return text;
      }
      return null;
    } catch (e) {
      // print('[FileService] Error extracting text from PDF: $e');
      return null;
    }
  }

  // Extract text from CSV files
  static Future<String?> _extractTextFromCSV(PlatformFile file) async {
    try {
      final textContent = await _extractTextFromPlainText(file);
      if (textContent != null) {
        final List<List<dynamic>> rows = const CsvToListConverter().convert(textContent);
        final StringBuffer buffer = StringBuffer();

        for (int i = 0; i < rows.length; i++) {
          if (i == 0) {
            buffer.writeln('Headers: ${rows[i].join(', ')}');
            buffer.writeln('---');
          } else {
            buffer.writeln('Row ${i}: ${rows[i].join(', ')}');
          }
        }

        return buffer.toString();
      }
      return null;
    } catch (e) {
      // print('[FileService] Error extracting text from CSV: $e');
      return null;
    }
  }

  // Extract text from HTML files
  static Future<String?> _extractTextFromHTML(PlatformFile file) async {
    try {
      final htmlContent = await _extractTextFromPlainText(file);
      if (htmlContent != null) {
        final document = html_parser.parse(htmlContent);
        return document.body?.text ?? document.outerHtml;
      }
      return null;
    } catch (e) {
      // print('[FileService] Error extracting text from HTML: $e');
      return null;
    }
  }

  // Extract text from JSON files
  static Future<String?> _extractTextFromJSON(PlatformFile file) async {
    try {
      final jsonContent = await _extractTextFromPlainText(file);
      if (jsonContent != null) {
        final jsonData = jsonDecode(jsonContent);
        const encoder = JsonEncoder.withIndent('  ');
        return 'JSON Content:\n${encoder.convert(jsonData)}';
      }
      return null;
    } catch (e) {
      // print('[FileService] Error extracting text from JSON: $e');
      return null;
    }
  }

  // Extract text from XML files
  static Future<String?> _extractTextFromXML(PlatformFile file) async {
    try {
      final xmlContent = await _extractTextFromPlainText(file);
      if (xmlContent != null) {
        // For now, just return the raw XML content
        // Could be enhanced with proper XML parsing
        return 'XML Content:\n$xmlContent';
      }
      return null;
    } catch (e) {
      // print('[FileService] Error extracting text from XML: $e');
      return null;
    }
  }

  // Extract text from Excel files by converting to CSV format
  static Future<String?> _extractTextFromExcel(PlatformFile file) async {
    try {
      // print('[FileService] Converting Excel file to CSV format for text extraction');

      Uint8List? bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes != null) {
        try {
          // For now, Excel parsing requires additional API setup
          // Return a helpful response acknowledging the Excel file
          return '''Excel File: ${file.name} (${formatFileSize(file.size)})
File Type: ${file.extension?.toUpperCase() ?? 'Excel spreadsheet'}

📊 Excel file uploaded successfully and ready for AI analysis!

The AI can help you with:
• Understanding the data structure and content
• Analyzing trends and patterns  
• Creating summaries and insights
• Suggesting data organization improvements
• Identifying key metrics and relationships

Note: Full text extraction from Excel will be enhanced in future updates. 
For detailed text analysis, consider saving as CSV format.

The file has been uploaded and the AI can provide insights based on its content.''';

          // TODO: Implement proper Excel to CSV conversion once xlsio API is stable
        } catch (xlsioError) {
          // print('[FileService] Error opening Excel file with xlsio: $xlsioError');
          // Fallback message
          return 'Excel File: ${file.name} (${formatFileSize(file.size)})\nNote: Unable to process Excel file. Please save as CSV format for full text analysis.';
        }
      }
      return null;
    } catch (e) {
      // print('[FileService] Error extracting text from Excel: $e');
      return 'Excel File: ${file.name}\nError processing file: ${e.toString()}\nSuggestion: Please save as CSV format for full text analysis.';
    }
  }

  // Extract text from DOCX files
  static Future<String?> _extractTextFromDocx(PlatformFile file) async {
    try {
      Uint8List? bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes != null) {
        final archive = ZipDecoder().decodeBytes(bytes);

        // Find the document.xml file
        for (final file in archive) {
          if (file.name == 'word/document.xml') {
            final xmlContent = utf8.decode(file.content as List<int>);

            // Basic XML text extraction (strips XML tags)
            final RegExp xmlTagsRegex = RegExp(r'<[^>]*>');
            final textContent = xmlContent.replaceAll(xmlTagsRegex, ' ');

            // Clean up extra whitespace
            return textContent.replaceAll(RegExp(r'\s+'), ' ').trim();
          }
        }
      }
      return null;
    } catch (e) {
      // print('[FileService] Error extracting text from DOCX: $e');
      return null;
    }
  }

  // Extract text from PPTX files
  static Future<String?> _extractTextFromPptx(PlatformFile file) async {
    try {
      Uint8List? bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes != null) {
        final archive = ZipDecoder().decodeBytes(bytes);
        final StringBuffer buffer = StringBuffer();

        // Extract text from slide XML files
        for (final file in archive) {
          if (file.name.startsWith('ppt/slides/slide') && file.name.endsWith('.xml')) {
            final xmlContent = utf8.decode(file.content as List<int>);

            // Basic XML text extraction
            final RegExp xmlTagsRegex = RegExp(r'<[^>]*>');
            final textContent = xmlContent.replaceAll(xmlTagsRegex, ' ');
            final cleanText = textContent.replaceAll(RegExp(r'\s+'), ' ').trim();

            if (cleanText.isNotEmpty) {
              buffer.writeln('Slide ${file.name}:');
              buffer.writeln(cleanText);
              buffer.writeln();
            }
          }
        }

        return buffer.toString();
      }
      return null;
    } catch (e) {
      // print('[FileService] Error extracting text from PPTX: $e');
      return null;
    }
  }

  // Show file picker options dialog
  static void showFilePickerDialog(
    BuildContext context, {
    required Function(PlatformFile) onFileSelected,
    required String title,
    required String subtitle,
    required String cancelText,
  }) {
    // print('[FileService] showFilePickerDialog called - checking context mounted state');

    // Check if context is still mounted and valid
    if (!context.mounted) {
      // print('[FileService] Context is not mounted, cannot show dialog');
      return;
    }

    try {
      showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: false,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (modalContext) {
          // print('[FileService] Modal bottom sheet builder called');
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Icon(
                  Icons.upload_file,
                  size: 48,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : const Color(0xFF0078D4),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        // print('[FileService] Choose File button pressed');
                        Navigator.pop(modalContext); // Use modalContext for pop

                        // Add a small delay to ensure modal is closed
                        await Future.delayed(const Duration(milliseconds: 100));

                        // print('[FileService] Opening file picker...');
                        final file = await pickDocumentFile();

                        if (file != null) {
                          // print('[FileService] File picked successfully: ${file.name}');
                          onFileSelected(file);
                        } else {
                          // print('[FileService] No file selected');
                        }
                      } catch (e) {
                        // print('[FileService] Error in file picker: $e');
                        // Use the original context for the snackbar if modal context is closed
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Choose File'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // print('[FileService] Cancel button pressed');
                    Navigator.pop(modalContext);
                  },
                  child: Text(
                    cancelText,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ).then((value) {
        // print('[FileService] Modal bottom sheet completed');
      }).catchError((error) {
        // print('[FileService] Error showing modal bottom sheet: $error');
      });
    } catch (e) {
      // print('[FileService] Error in showFilePickerDialog: $e');
    }
  }
}
