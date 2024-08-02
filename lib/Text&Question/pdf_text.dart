import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class PDFTextExtractor {
  static Future<String> extractText(String pdfPath) async {
    PdfDocument document;
    try {
      document = PdfDocument(inputBytes: File(pdfPath).readAsBytesSync());
      String extractedText = PdfTextExtractor(document).extractText();
      print("Extracted text length: ${extractedText.length}");
      print("Extracted text preview: ${extractedText.substring(0, 100)}"); // Preview the first 100 characters

      // Check for Turkish characters and log a warning
      if (containsTurkishCharacters(extractedText)) {
        print('Warning: The PDF contains Turkish characters which may result in inaccurate questions.');
      }

      if (_isTextLengthExceeded(extractedText)) {
        return 'The PDF file contains too much text. Please upload a smaller PDF.';
      }

      return extractedText;
    } catch (e) {
      print("Error reading PDF: $e");
      return 'Error processing PDF file.';
    }
  }

  static bool containsTurkishCharacters(String text) { // Made public
    const String turkishChars = 'çğıöşüÇĞİÖŞÜ';
    bool found = false;
    for (int i = 0; i < text.length; i++) {
      if (turkishChars.contains(text[i])) {
        print('Turkish character found: ${text[i]} at position $i');
        found = true;
      }
    }
    return found;
  }

  static bool _isTextLengthExceeded(String text) {
    const int maxLength = 1000000; // Define a reasonable limit for text length
    return text.length > maxLength;
  }
}
