import 'package:educador_edu_assist/variables.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

String GeminiAPI = GEMINI_API_KEY;
final model = GenerativeModel(
  model: 'gemini-1.5-pro',
  apiKey: GeminiAPI,
);
Future<String?> prompt_gemini(String prompt) async{
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  print(response.text);
  return response.text;
}


Future<List<Map<String, String>>> generate_multiple_choice_question(String lesson) async{
  final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: GeminiAPI,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'));

  final prompt = 'Given this lesson: $lesson. From the given lesson, create 5 multiple-choice questions to test students knowledge on the topic. Question should be generated using this format: \n\n'
  'Format = {"Question": string, "A": string, "B": string, "C": string, "Answer": string}\n'
  'Return: Array<Recipe>';
  final response = await model.generateContent([Content.text(prompt)]);
  return convertStringToListOfMaps(response.text!);

}




List<Map<String, String>> convertStringToListOfMaps(String jsonString) {
  try {
    // Decode the JSON string
    List<dynamic> decodedJson = jsonDecode(jsonString);

    // Convert each item to Map<String, String>
    return decodedJson.map((item) {
      Map<String, dynamic> dynamicMap = Map<String, dynamic>.from(item);
      // Convert all values to String
      return dynamicMap.map((key, value) => MapEntry(key, value.toString()));
    }).toList();
  } catch (e) {
    throw FormatException('Invalid JSON format: $e');
  }
}
