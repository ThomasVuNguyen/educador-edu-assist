import 'package:flutter/material.dart';
import 'package:educador_edu_assist/functions/file.dart';
// import 'package:educador_edu_assist/functions/gemini.dart';
import 'package:educador_edu_assist/screens/lesson_summary.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FilePicker extends StatefulWidget {
  const FilePicker({super.key});

  @override
  State<FilePicker> createState() => _FilePickerState();
}

class _FilePickerState extends State<FilePicker> {
  bool _isDragging = false;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  Future<String?> extract_pdf(Uint8List bytes) async {
    try {
      if (bytes != null) {
        // Load the PDF document from bytes
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        // Extract text from the document
        String text = PdfTextExtractor(document).extractText();
        print('PDF Content:');
        print(text);
        // Dispose the document
        document.dispose();
        print('PDF reading completed successfully!');
        return text;
      } else {
        print('No bytes available in the selected file');
      }
    } catch (e) {
      print('Error reading PDF: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo and Version
                Row(
                  children: [
                    Image.asset('assets/sinlapiz.png', height: 24,),
                    Gap(10),
                    Image.asset('assets/message.png', height:
                    22
                      ,),
                    const SizedBox(width: 8),
                    const Spacer(),

                    Image.asset('assets/thomas.png', width: 38,)
                  ],
                ),

                // Main Content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hello, there',
                          style: GoogleFonts.geologica(
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'What topic are you\nexploring today?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.geologica(
                            fontSize: 40,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Upload a PDF to get started',
                          style: GoogleFonts.geologica(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        const SizedBox(height: 24),

                        // PDF Upload Section with Drag & Drop
                        DropTarget(
                          onDragDone: (detail) async {
                            final file = detail.files.first;

                            // Verify it's a PDF
                            if (!file.name.toLowerCase().endsWith('.pdf')) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(
                                      'Please upload a PDF file',
                                    style: GoogleFonts.geologica(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500
                                    ),
                                  )),
                                );
                              }
                              return;
                            }

                            setState(() {
                              _isDragging = false;
                              _isUploading = true;
                              _uploadProgress = 0.0;
                            });

                            final bytes = await file.readAsBytes();

                            // Simulate upload progress while processing
                            for (var i = 0; i <= 100; i += 5) {
                              if (!mounted) return;
                              await Future.delayed(const Duration(milliseconds: 50));
                              setState(() => _uploadProgress = i / 100);
                            }

                            if (!mounted) return;

                            // Extract PDF content
                            final content = await extract_pdf(bytes);

                            if (content != null && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonSummary(
                                    lesson_content: content,
                                  ),
                                ),
                              );
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error processing PDF file')),
                                );
                              }
                            }

                            setState(() => _isUploading = false);
                          },
                          onDragEntered: (detail) {
                            setState(() => _isDragging = true);
                          },
                          onDragExited: (detail) {
                            setState(() => _isDragging = false);
                          },
                          child: Container(
                            width: 400,
                            height: 200,
                            decoration: BoxDecoration(
                              color: _isDragging
                                  ? Colors.blue.shade50.withOpacity(0.9)
                                  : Colors.transparent,
                              border: Border.all(
                                color: _isDragging ? Colors.blue[400]! : Colors.purple[200]!,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _isUploading
                                ? _buildUploadProgress()
                                : _buildUploadPrompt(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.blue.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          (_uploadProgress != 1) ? 'Processing your file...' : 'Extracting content',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          (_uploadProgress != 1)
              ? '${(_uploadProgress * 100).toInt()}%'
              : 'Please wait for a few more seconds',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPrompt() {
    return InkWell(
      onTap: () async {
        String? content = await pick_pdf_file();
        if (content != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonSummary(
                lesson_content: content,
              ),
            ),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 48,
            color: _isDragging ? Colors.blue[700] : Colors.blue[400],
          ),
          const SizedBox(height: 16),
          /*Text(
            'Add PDF file',
            style: GoogleFonts.geologica(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500
            ),
          ),*/
          const SizedBox(height: 8),
          Text(
            'or drag and drop your\nfile here',
            textAlign: TextAlign.center,
            style: GoogleFonts.geologica(
                fontSize: 16,
                color: _isDragging ? Colors.blue[700] : Colors.grey[600],
                fontWeight: FontWeight.w300
            ),

          ),
        ],
      ),
    );
  }
}