import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';

/// Function to generate text using the OpenRouter API.
Future<String> generateText(String prompt, String modelName, Dio dio) async {
  final payload = {
    "model": modelName,
    "messages": [
      {"role": "user", "content": prompt},
    ],
  };

  try {
    final response = await dio.post('', data: payload);
    return response.data['choices'][0]['message']['content'];
  } on DioException catch (e) {
    return 'Error communicating with AI: ${e.response?.data ?? e.message}';
  }
}

/// Main entry point for the application.
void main(List<String> args) async {
  // Check for command-line arguments FIRST
  if (args.isEmpty) {
    print('Error: Please provide a prompt.');
    print('Usage: dart run main.dart "Your prompt goes here"');
    return;
  }

  String userPrompt = args.join(' ');

  // Load environment variables
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKey = env['OPENROUTER_API_KEY'];
  final modelName = env['MODEL_NAME'];

  if (apiKey == null || modelName == null) {
    print('Error: Missing OPENROUTER_API_KEY or MODEL_NAME in .env file!');
    return;
  }

  // Initialize HTTP client with base configuration
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://openrouter.ai/api/v1/chat/completions',
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ),
  );

  print("Sending prompt to OpenRouter...\n");

  // Fetch AI response
  String aiResponse = await generateText(userPrompt, modelName, dio);

  print("--- AI Response ---");
  print(aiResponse);
  print("-------------------");
}
