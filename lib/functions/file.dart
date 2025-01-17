import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<String?> pick_pdf_file() async {
  try {
    // Pick PDF file and get bytes directly
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      // Get bytes directly from the result
      final bytes = result.files.first.bytes;

      if (bytes != null) {
        // Load the PDF document from bytes
        final PdfDocument document = PdfDocument(inputBytes: bytes);

        // Extract text from the document
        String text = PdfTextExtractor(document).extractText();
        //print('PDF Content:');
        //print(text);

        // Dispose the document
        document.dispose();
        print('PDF reading completed successfully!');
        return text;
      } else {
        print('No bytes available in the selected file');
      }
    } else {
      print('No file selected');
    }
  } catch (e) {
    print('Error reading PDF: $e');
  }
}

Future<Uint8List?> pick_audio_file() async {
  try {
    // Pick PDF file and get bytes directly
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3','wav','m4a'],
    );

    if (result != null) {
      // Get bytes directly from the result
      final bytes = result.files.first.bytes;
      return bytes;
    } else {
      print('No file selected');
    }
  } catch (e) {
    print('Error reading PDF: $e');
  }
}