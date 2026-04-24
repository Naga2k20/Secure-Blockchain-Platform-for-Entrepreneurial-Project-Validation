




import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:translator/translator.dart'; // Import the translator package
import 'package:flutter_tts/flutter_tts.dart'; // Im.port the flutter_tts package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatBotScreen(),
    );
  }
}

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late Future<List<Intent>> intentsData;
  List<Intent> intents = [];
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  String _translatedResponse = ''; // Variable to hold the translated response
  final translator = GoogleTranslator(); // Create an instance of GoogleTranslator
  final FlutterTts flutterTts = FlutterTts(); // Create an instance of FlutterTts

  // Define the language options
  final Map<String, String> languages = {
    'Tamil': 'ta',
    'Hindi': 'hi',
  };
  String _selectedLanguage = 'ta'; // Default to Tamil

  @override
  void initState() {
    super.initState();
    intentsData = loadIntentsData();
    intentsData.then((data) {
      setState(() {
        intents = data;
      });
    });
  }

  Future<List<Intent>> loadIntentsData() async {
    final String response = await rootBundle.loadString('assets/images/intents.json');
    final Map<String, dynamic> data = json.decode(response);
    final List<dynamic> intents = data['intents'] ?? [];
    return intents.map((json) => Intent.fromJson(json)).toList();
  }

  void _getResponse(String question) async {
    for (var intent in intents) {
      if (intent.patterns.any((pattern) => pattern.toLowerCase() == question.toLowerCase())) {
        String response = intent.responses.isNotEmpty ? intent.responses[0] : 'No response available';

        setState(() {
          _response = response; // Update response with the original text
          _translatedResponse = ''; // Clear previous translation
        });
        return;
      }
    }
    setState(() {
      _response = 'Sorry, I don\'t understand that question.';
      _translatedResponse = ''; // Clear previous translation
    });
  }

  void _translateResponse(String targetLanguage) async {
    final translation = await translator.translate(_response, to: targetLanguage);
    setState(() {
      _translatedResponse = translation.text; // Update the translated response
    });
  }

  void _speakResponse(String text, String languageCode) async {
    await flutterTts.setLanguage(languageCode); // Set language to Tamil or Hindi
    await flutterTts.setPitch(1); // Adjust pitch if necessary
    await flutterTts.speak(text); // Speak the text
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chatbot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Ask a question',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedLanguage,
                items: languages.keys.map((String key) {
                  return DropdownMenuItem<String>(
                    value: languages[key]!,
                    child: Text(key),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _getResponse(_controller.text);
                },
                child: Text('Submit'),
              ),
              SizedBox(height: 20),
              if (_response.isNotEmpty) ...[
                Text('Response: $_response'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _translateResponse(_selectedLanguage);
                  },
                  child: Text('Translate to ${languages.keys.firstWhere((key) => languages[key] == _selectedLanguage)}'),
                ),
                SizedBox(height: 10),
                if (_translatedResponse.isNotEmpty) ...[
                  Text('Translated Response: $_translatedResponse'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _speakResponse(_translatedResponse, _selectedLanguage); // Speak in the selected language
                    },
                    child: Text('Read in ${languages.keys.firstWhere((key) => languages[key] == _selectedLanguage)}'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class Intent {
  final String tag;
  final List<String> patterns;
  final List<String> responses;
  final String contextSet;

  Intent({
    required this.tag,
    required this.patterns,
    required this.responses,
    required this.contextSet,
  });

  factory Intent.fromJson(Map<String, dynamic> json) {
    return Intent(
      tag: json['tag'] ?? '',
      patterns: List<String>.from(json['patterns'] ?? []),
      responses: List<String>.from(json['responses'] ?? []),
      contextSet: json['context_set'] ?? '',
    );
  }
}


