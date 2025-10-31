import 'package:flutter/material.dart';
import 'package:flutter_speech/flutter_speech.dart';

class SpeechDemo extends StatefulWidget {
  const SpeechDemo({super.key});

  @override
  State<SpeechDemo> createState() => _SpeechDemoState();
}

class _SpeechDemoState extends State<SpeechDemo> with SingleTickerProviderStateMixin {
  late SpeechRecognition _speech;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isAvailable = false;
  bool _isListening = false;
  String _text = "";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _speech = SpeechRecognition();

    _speech.setAvailabilityHandler((bool result) {
      setState(() => _isAvailable = result);
    });

    _speech.setRecognitionStartedHandler(() {
      setState(() => _isListening = true);
      _controller.repeat(reverse: true);
    });

    _speech.setRecognitionResultHandler((String speech) {
      setState(() => _text = speech);
    });

    _speech.setRecognitionCompleteHandler((String _) {
      setState(() => _isListening = false);
      _controller.stop();
    });

    _speech.activate("es_CO").then((res) => setState(() => _isAvailable = res));
  }

  void _startListening() {
    if (_isAvailable && !_isListening) {
      setState(() => _isListening = true);
      _controller.repeat(reverse: true);
      _speech.listen().then((result) => print('Started: $result'));
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop().then((_) {
        setState(() => _isListening = false);
        _controller.stop();

        // 🔁 Reactivar el motor para permitir nueva escucha
        Future.delayed(const Duration(milliseconds: 300), () {
          _speech.activate("es_CO").then((res) {
            setState(() => _isAvailable = res);
          });
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reconocimiento de voz")),
      body: SizedBox.expand(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  _text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ScaleTransition(
              scale: _isListening ? _scaleAnimation : AlwaysStoppedAnimation(1.0),
              child: ElevatedButton.icon(
                onPressed: _isListening ? _stopListening : _startListening,
                icon: const Icon(Icons.mic, size: 28, color: Colors.white),
                label: Text(
                  _isListening ? "Detener" : "Escuchar",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  backgroundColor: Colors.deepPurple,
                  elevation: 4,
                ),
              ),
            ),
            if (!_isListening && _text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Buscar"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}