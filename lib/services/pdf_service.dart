import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<List<int>> generatePdfFromImages(List<XFile> images) async {
    final pdf = pw.Document();

    for (final xfile in images) {
      final imageBytes = await xfile.readAsBytes();
      final image = pw.MemoryImage(imageBytes);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static Future<List<int>?> generateStyledMessagePdf(String message) async {
    try {
      String cleanText = message;

      cleanText = cleanText.replaceAll(RegExp(r'!\\[.*?\\]\\(.*?\\)'), '');
      cleanText = cleanText.replaceAll(''', "'");
      cleanText = cleanText.replaceAll(''', "'");
      cleanText = cleanText.replaceAll('"', '"');
      cleanText = cleanText.replaceAll('"', '"');
      cleanText = cleanText.replaceAll('—', '-');
      cleanText = cleanText.replaceAll('–', '-');

      pw.Font? unicodeFont;
      try {
        final fontData =
            await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
        unicodeFont = pw.Font.ttf(fontData);
      } catch (_) {
        unicodeFont = null;
      }

      if (unicodeFont == null) {
        cleanText = cleanText.replaceAll('•', '- ');
        cleanText = cleanText.replaceAll('…', '...');
        cleanText = cleanText.replaceAll('°', ' degrees');
        cleanText = cleanText.replaceAll('©', '(c)');
        cleanText = cleanText.replaceAll('®', '(R)');
        cleanText = cleanText.replaceAll('™', '(TM)');

        cleanText = cleanText.replaceAllMapped(RegExp(r'[^\\x00-\\x7F]'), (_) {
          return ' ';
        });
      }

      final pdf = pw.Document();

      final lines = cleanText.split('\n');
      final List<pw.Widget> contentWidgets = [];

      for (String line in lines) {
        line = line.trim();

        if (line.isEmpty) {
          contentWidgets.add(pw.SizedBox(height: 8));
          continue;
        }

        final isHeader = line.length < 50 &&
            (line.toUpperCase() == line ||
                line.endsWith(':') ||
                line.startsWith('---'));

        if (isHeader) {
          contentWidgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 12, bottom: 6),
              child: pw.Text(
                line.replaceAll('---', '').trim(),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  font: unicodeFont,
                ),
              ),
            ),
          );
        } else if (line.startsWith('• ') || line.startsWith('- ')) {
          contentWidgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(left: 16, bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 16,
                    child: pw.Text(
                      '•',
                      style: pw.TextStyle(fontSize: 12, font: unicodeFont),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      line.substring(2).trim(),
                      style: pw.TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        font: unicodeFont,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          contentWidgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                line,
                style:
                    pw.TextStyle(fontSize: 12, height: 1.4, font: unicodeFont),
              ),
            ),
          );
        }
      }

      final List<pw.Widget> buildContent = [];
      buildContent.add(pw.SizedBox(height: 30));
      buildContent.addAll(contentWidgets);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(30),
          build: (pw.Context context) => buildContent,
        ),
      );

      return pdf.save();
    } catch (_) {
      return null;
    }
  }
}
