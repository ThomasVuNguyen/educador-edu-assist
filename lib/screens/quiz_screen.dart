import 'package:educador_edu_assist/screens/test_result.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class QuizScreen extends StatefulWidget {
  final List<Map<String, String>> questions;
  final String lesson_content;
  const QuizScreen({Key? key, required this.questions, required this.lesson_content}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  int score = 0;
  bool hasAnswered = false;

  void checkAnswer(String choice) {
    if (hasAnswered) return;

    setState(() {
      selectedAnswer = choice;
      hasAnswered = true;
      if (choice == widget.questions[currentQuestionIndex]['Answer']) {
        score++;
      }
    });

    // Wait a moment to show the selection before moving to next question
    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted && currentQuestionIndex < widget.questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          hasAnswered = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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

              const SizedBox(height: 32),

              // Question Counter and Review Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*TextButton.icon(
                    onPressed: () {
                      // Handle review
                    },
                    icon: const Icon(Icons.article_outlined),
                    label: const Text('Review Summary'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),*/
                  Text(
                    'Question ${currentQuestionIndex + 1}/${widget.questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Question
              Text(
                currentQuestion['Question'] ?? '',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Choose the best answer to continue.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 32),

              // Answer Options
              Column(
                children: ['A', 'B', 'C'].map((option) {
                  final isSelected = selectedAnswer == option;
                  final isCorrect = hasAnswered &&
                      option == widget.questions[currentQuestionIndex]['Answer'];
                  final isWrong = hasAnswered &&
                      isSelected &&
                      option != widget.questions[currentQuestionIndex]['Answer'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: hasAnswered ? null : () => checkAnswer(option),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? Colors.green[50]
                              : isWrong
                              ? Colors.red[50]
                              : isSelected
                              ? Colors.blue[50]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCorrect
                                ? Colors.green[400]!
                                : isWrong
                                ? Colors.red[400]!
                                : isSelected
                                ? Colors.blue[400]!
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCorrect
                                      ? Colors.green[400]!
                                      : isWrong
                                      ? Colors.red[400]!
                                      : isSelected
                                      ? Colors.blue[400]!
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                                color: isSelected ? Colors.blue[400] : Colors.white,
                              ),
                              child: isSelected
                                  ? Icon(
                                isCorrect ? Icons.check : Icons.close,
                                size: 16,
                                color: Colors.white,
                              )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                currentQuestion[option] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? Colors.blue[900] : Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Quiz Complete Message or Score
              if (currentQuestionIndex == widget.questions.length - 1 && hasAnswered)
                FutureBuilder(
                  future: Future.delayed(
                    const Duration(milliseconds: 750),
                        () {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DisplayResult(
                              totalQuestions: widget.questions.length,
                              correctAnswers: score,
                              score: (score / widget.questions.length * 100).toInt(),
                              questions: widget.questions,
                              content: widget.lesson_content,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  builder: (context, snapshot) {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            'Quiz Complete!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Final Score: ${(score / widget.questions.length * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(),
                        ],
                      ),
                    );
                  },
                )
              else
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                      children: [
                        const TextSpan(text: 'Ongoing score '),
                        TextSpan(
                          text: '${(score / widget.questions.length * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}