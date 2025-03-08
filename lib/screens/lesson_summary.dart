// import 'package:educador_edu_assist/functions/gemini.dart';
import 'package:educador_edu_assist/screens/file_picker.dart';
import 'package:educador_edu_assist/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../functions/luna_client.dart';

class LessonSummary extends StatefulWidget {
  const LessonSummary({super.key, required this.lesson_content});
  final String lesson_content;
  @override
  State<LessonSummary> createState() => _LessonSummaryState();
}

class _LessonSummaryState extends State<LessonSummary> {
  bool isGeneratingQuiz = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Image.asset('assets/sinlapiz.png', height: 24,),
                    const SizedBox(width: 8),
                    const Spacer(),

                    Image.asset('assets/thomas.png', width: 38,)
                  ],
                ),
              ),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Here's what we've summarized from your document:",
                    style: GoogleFonts.geologica(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Main Content
              Expanded(
                child: FutureBuilder(
                  future: prompt_luna(
                      'Please summarize this lesson content in Spanish language, and provide any extra readings recommended based on this lesson. Here is the lesson: ${widget.lesson_content}'
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Markdown(
                          data: snapshot.data!,
                          styleSheet: MarkdownStyleSheet(
                            h1: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                            h2: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              height: 2,
                            ),
                            p: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                            listBullet: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey[400],
                        ),
                      );
                    }
                  },
                ),
              ),

              // Bottom Buttons
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*TextButton.icon(
                      onPressed: () {
                        // Add complement summary functionality here
                      },
                      icon: const Icon(Icons.edit_note_outlined),
                      label: const Text('Complement summary'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.blue[100],
                        foregroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),*/
                    TextButton.icon(
                      onPressed: isGeneratingQuiz ? null : () async {
                        setState(() {
                          isGeneratingQuiz = true;
                        });

                        // Show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                width: 300,

                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Generating Quiz',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Please wait while we create personalized questions based on your content...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        try {
                          List<Map<String, String>> quiz =
                          await generate_multiple_choice_question(
                              widget.lesson_content);

                          if (context.mounted) {
                            // Close loading dialog
                            Navigator.pop(context);

                            // Navigate to quiz screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QuizScreen(questions: quiz, lesson_content: widget.lesson_content),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            // Close loading dialog
                            Navigator.pop(context);

                            // Show error dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Failed to generate quiz. Please try again.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              isGeneratingQuiz = false;
                            });
                          }
                        }
                      },
                      icon: Image.asset('assets/generate_icon.png', width: 20,),
                      //const Icon(Icons.quiz_outlined, color: Colors.white,),
                      label: Text('Start quiz',
                        style: GoogleFonts.geologica(
                          fontSize: 16,
                          color: Colors.white,
                      ),),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Color(0xff8586C2),
                        foregroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}