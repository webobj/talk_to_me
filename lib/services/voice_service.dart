import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  double _confidence = 0.0;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
  String get recognizedText => _recognizedText;
  double get confidence => _confidence;

  VoiceService() {
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
      print('TTS Error: $msg');
    });
  }

  Future<bool> initializeSpeech() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: (error) {
        print('Speech recognition error: $error');
        _isListening = false;
        notifyListeners();
      },
      onStatus: (status) {
        print('Speech recognition status: $status');
        if (status == 'notListening') {
          _isListening = false;
          notifyListeners();
        }
      },
    );

    notifyListeners();
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
  }) async {
    if (!_isInitialized) {
      final initialized = await initializeSpeech();
      if (!initialized) {
        print('Failed to initialize speech recognition');
        return;
      }
    }

    _recognizedText = '';
    _isListening = true;
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        _confidence = result.confidence;
        notifyListeners();

        if (result.finalResult) {
          onResult(_recognizedText);
          stopListening();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    // Stop any ongoing speech
    await _tts.stop();

    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  void clearRecognizedText() {
    _recognizedText = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}
