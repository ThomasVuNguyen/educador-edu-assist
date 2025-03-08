import 'dart:convert';
import 'package:http/http.dart' as http;

// Luna API base URL - update this to your actual server address
const String lunaBaseUrl = 'http://10.0.0.31:5000';

// Basic prompt function to get a response from Luna
Future<String> prompt_luna(String prompt) async {
  try {
    final response = await http.post(
      Uri.parse('$lunaBaseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt
      }),
    ).timeout(const Duration(seconds: 60)); // Add timeout to prevent hanging

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] as String;
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      return 'Error: Failed to get response from AI. Please try again.';
    }
  } catch (e) {
    print('Error in prompt_luna: $e');
    return 'Error: $e';
  }
}

// Generate multiple choice questions using Luna
Future<List<Map<String, String>>> generate_multiple_choice_question(String lesson) async {
  try {
    // Create a more focused prompt for the Luna model
    final prompt = '''
Given this lesson: $lesson
From this lesson content, create 5 multiple-choice questions in English to test students' knowledge.
Each question must follow this exact JSON format:
{
  "Question": "Question text here",
  "A": "Option A text",
  "B": "Option B text", 
  "C": "Option C text",
  "Answer": "A, B, or C"
}
Return only a valid JSON array of these 5 questions.
''';

    final response = await http.post(
      Uri.parse('$lunaBaseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt
      }),
    ).timeout(const Duration(seconds: 120)); // Longer timeout for quiz generation

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final responseText = data['response'] as String;

      return convertStringToListOfMaps(responseText);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to generate questions');
    }
  } catch (e) {
    print('Error in generate_multiple_choice_question: $e');
    throw Exception('Failed to generate questions: $e');
  }
}

// Helper function to convert JSON string to List of Maps
List<Map<String, String>> convertStringToListOfMaps(String jsonString) {
  try {
    // First, try to clean up any non-JSON content
    String cleanedString = jsonString;

    // Try to extract JSON content if it's embedded in other text
    final jsonArrayPattern = RegExp(r'\[\s*\{.*?\}\s*\]', dotAll: true);
    final match = jsonArrayPattern.firstMatch(jsonString);
    if (match != null) {
      cleanedString = match.group(0)!;
    }

    // Decode the JSON string
    List<dynamic> decodedJson = jsonDecode(cleanedString);

    // Check if we have at least one question
    if (decodedJson.isEmpty) {
      throw FormatException('No questions found in response');
    }

    // Convert each item to Map<String, String>
    return decodedJson.map((item) {
      Map<String, dynamic> dynamicMap = Map<String, dynamic>.from(item);
      // Ensure all required keys are present
      if (!dynamicMap.containsKey('Question') ||
          !dynamicMap.containsKey('A') ||
          !dynamicMap.containsKey('B') ||
          !dynamicMap.containsKey('C') ||
          !dynamicMap.containsKey('Answer')) {
        throw FormatException('Question format is incorrect: missing required keys');
      }
      // Convert all values to String
      return dynamicMap.map((key, value) => MapEntry(key, value.toString()));
    }).toList();
  } catch (e) {
    print('Error parsing JSON: $e');
    print('Original response: $jsonString');

    // Fallback: try to manually create questions if JSON parsing fails
    try {
      // This is a fallback for when the API doesn't return proper JSON
      // Create a simple default question set
      return [
        {
          "Question": "Pregunta de ejemplo 1 (Error en la generación de preguntas)",
          "A": "Opción A",
          "B": "Opción B",
          "C": "Opción C",
          "Answer": "A"
        },
        {
          "Question": "Pregunta de ejemplo 2 (Error en la generación de preguntas)",
          "A": "Opción A",
          "B": "Opción B",
          "C": "Opción C",
          "Answer": "B"
        },
      ];
    } catch (fallbackError) {
      throw FormatException('Could not generate quiz questions: $e');
    }
  }
}

// Evaluate test results using Luna
Future<String> evaluateTestResult(List<Map<String, String>> questions, String content) async {
  try {
    String evaluation = await prompt_luna('''
You are reading test results from a student on a given content. 
Please give a summary of the result and feedback on what the students should focus on. 
Write in English.

Here is the content:
$content

Here is the test result:
${jsonEncode(questions)}
''');

    return evaluation;
  } catch (e) {
    print('Error in evaluateTestResult: $e');
    return 'Error al evaluar los resultados: $e';
  }
}