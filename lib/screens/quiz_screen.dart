import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final List<Map<String, String>> questions;

  const QuizScreen({Key? key, required this.questions}) : super(key: key);

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
  }

  void nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        hasAnswered = false;
      });
    }
  }

  Color getOptionColor(String option) {
    if (!hasAnswered) return Colors.white;

    if (option == widget.questions[currentQuestionIndex]['Answer']) {
      return Colors.green.shade100;
    }
    if (option == selectedAnswer && selectedAnswer != widget.questions[currentQuestionIndex]['Answer']) {
      return Colors.red.shade100;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz (${currentQuestionIndex + 1}/${widget.questions.length})'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: $score',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentQuestion['Question'] ?? '',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...['A', 'B', 'C'].map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: getOptionColor(option),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () => checkAnswer(option),
                child: Text(
                  currentQuestion[option] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )),
            const SizedBox(height: 20),
            if (hasAnswered && currentQuestionIndex < widget.questions.length - 1)
              ElevatedButton(
                onPressed: nextQuestion,
                child: const Text('Next Question'),
              ),
            if (hasAnswered && currentQuestionIndex == widget.questions.length - 1)
              Center(
                child: Text(
                  'Quiz Complete! Final Score: $score/${widget.questions.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
