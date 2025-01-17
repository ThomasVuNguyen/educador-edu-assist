import 'package:educador_edu_assist/functions/file.dart';
import 'package:educador_edu_assist/functions/gemini.dart';
import 'package:educador_edu_assist/screens/lesson_summary.dart';
import 'package:flutter/material.dart';

class FilePicker extends StatelessWidget {
  const FilePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(onPressed: () async{
              String? content = await pick_pdf_file();
              //List<Map<String, String>> qa = await generate_multiple_choice_question(content!);
              //print(qa);
              Navigator.push(context, MaterialPageRoute(builder: (context) => LessonSummary(lesson_content: content!)));

            }, child: Text('Pick PDF file'))
          ],
        ),
      ),
    );
  }
}
