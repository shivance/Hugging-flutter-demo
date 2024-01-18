import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:huggingface_dart/huggingface_dart.dart';

Future main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HuggingFace Translate App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _inputController = TextEditingController();
  String _outputText = '';
  late HfInference _hfInference;

  @override
  void initState() {
    super.initState();
    _hfInference = HfInference(dotenv.env['HF_API_TOKEN']);
  }

  Future<void> _translateText() async {
    final inputText = _inputController.text;
    if (inputText.isNotEmpty) {
      try {
        final result = await _hfInference.translate(
          inputs: [inputText],
          model: 'Helsinki-NLP/opus-mt-ru-en',
          options: {
            'use_cache': true,
            'wait_for_model': true,
          },
        );

        setState(() {
          _outputText = result.isNotEmpty ? result[0]['translation_text'] : 'Translation not available';
        });
      } catch (error) {
        print('Translation error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🤗',
                  style: TextStyle(fontSize: 50.0),
                ),
                const SizedBox(width: 16),
                FlutterLogo(
                  size: 50, // Adjust the size as needed
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(labelText: 'Enter text to translate'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _translateText,
              child: const Text('Translate'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Translation:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_outputText),
          ],
        ),
      ),
    );
  }
}
