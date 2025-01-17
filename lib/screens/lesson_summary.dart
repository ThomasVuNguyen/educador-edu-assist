import 'package:educador_edu_assist/functions/gemini.dart';
import 'package:educador_edu_assist/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LessonSummary extends StatefulWidget {
  const LessonSummary({super.key, required this.lesson_content});
  final String lesson_content;
  @override
  State<LessonSummary> createState() => _LessonSummaryState();
}

class _LessonSummaryState extends State<LessonSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: TextButton(onPressed: () async{
        List<Map<String, String>> quiz = await generate_multiple_choice_question(widget.lesson_content);
        Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(questions: quiz)));
      }, child: Text('Generate quiz')),
      body: FutureBuilder(future: prompt_gemini('Please summarize this lesson content, and provide any extra readings recommended based on this lesson. Here is the lesson: ${widget.lesson_content}')
          , builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return Center(child: Markdown(data: snapshot.data! ),);
        }
        else{
          return Center(child: Text('Loading'),);
        }
          }),
    );
  }
}
