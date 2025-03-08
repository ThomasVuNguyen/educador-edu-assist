import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class LunaApiClient {
  final String baseUrl;

  LunaApiClient({required this.baseUrl});

  /// Sends a regular (non-streaming) chat request and returns the full response
  Future<String> chat(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] as String;
    } else {
      throw Exception('Failed to get response: ${response.statusCode} ${response.body}');
    }
  }

  /// Sends a streaming chat request and processes tokens as they arrive
  Future<String> chatStream(String prompt, {Function(String)? onToken}) async {
    final request = http.Request('POST', Uri.parse('$baseUrl/api/chat/stream'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'prompt': prompt
      });

    final response = await http.Client().send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to get stream: ${response.statusCode}');
    }

    final completeResponse = StringBuffer();

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      // Process Server-Sent Events format
      final lines = chunk.split('\n\n');

      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final token = line.substring(6);

          if (token == '[DONE]') {
            // Stream completed
            break;
          }

          if (onToken != null) {
            onToken(token);
          }

          completeResponse.write(token);
        }
      }
    }

    return completeResponse.toString();
  }

  /// Check API health status
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await http.get(Uri.parse('$baseUrl/api/health'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Health check failed: ${response.statusCode}');
    }
  }

  /// Generate a multiple choice question based on a subject
  Future<Map<String, dynamic>> generateMultipleChoiceQuestion(String subject) async {
    final prompt = '''
Generate a single multiple choice question about $subject.
Response must be in valid JSON format with these fields:
- "Question": the question text
- "A": option A
- "B": option B
- "C": option C
- "Answer": correct answer (A, B, or C)
Just return the JSON object with no additional text.
''';

    final response = await chat(prompt);

    try {
      // Try to parse the response as JSON
      return extractJsonFromResponse(response);
    } catch (e) {
      // If direct parsing fails, try to extract JSON from the text
      throw Exception('Failed to parse question response: $e\nResponse was: $response');
    }
  }

  /// Generate multiple choice questions for a given subject
  Future<List<Map<String, dynamic>>> generateMultipleChoiceQuestions(
      String subject,
      int count
      ) async {
    final List<Map<String, dynamic>> questions = [];

    for (int i = 0; i < count; i++) {
      try {
        final question = await generateMultipleChoiceQuestion(subject);
        questions.add(question);
      } catch (e) {
        print('Error generating question ${i+1}: $e');
      }
    }

    return questions;
  }

  /// Helper function to extract JSON from a string that might contain additional text
  Map<String, dynamic> extractJsonFromResponse(String response) {
    try {
      // First try to parse the response directly
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (_) {
      // If that fails, try to find JSON object in the text
      final regExp = RegExp(r'\{(?:[^{}]|(?:\{(?:[^{}]|(?:\{[^{}]*\}))*\}))*\}');
      final match = regExp.firstMatch(response);

      if (match != null) {
        final jsonStr = match.group(0);
        if (jsonStr != null) {
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
      }

      throw Exception('Could not extract valid JSON from response');
    }
  }
}

void main() async {
  // Create client with the specified IP
  final client = LunaApiClient(baseUrl: 'http://10.0.0.31:5000');

  try {
    // Check API health
    print('Checking API health...');
    final healthStatus = await client.checkHealth();
    print('API health: ${healthStatus['status']}');
    print('Model: ${healthStatus['model']}');

    // Generate a quiz on "Ancient Rome"
    final subject = "Ancient Rome";
    final questionCount = 3;

    print('\nGenerating $questionCount questions about $subject...\n');

    final questions = await client.generateMultipleChoiceQuestions(subject, questionCount);

    // Print the generated questions
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      print('Question ${i + 1}: ${q['Question']}');
      print('A: ${q['A']}');
      print('B: ${q['B']}');
      print('C: ${q['C']}');
      print('Answer: ${q['Answer']}\n');
    }

    // Save to JSON file
    final jsonStr = jsonEncode(questions);
    // In a real app, you would use dart:io to write to a file
    print('JSON output:');
    print(jsonStr);

  } catch (e) {
    print('Error: $e');
  }
}

// Example of how to use the streaming API
Future<void> demonstrateStreaming(LunaApiClient client) async {
  print('Demonstrating streaming API...');

  await client.chatStream(
      'Explain why Rome fell in three short sentences',
      onToken: (token) {
        // Print each token as it arrives (in a real app, you might update UI)
        stdout.write(token);
      }
  );

  print('\nStreaming complete.');
}