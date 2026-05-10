import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../app/config/app_constants.dart';

class GeminiService extends GetxService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  final List<String> _apiKeys = [];

  Future<GeminiService> init() async {
    final rawKeys = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (rawKeys.isEmpty) return this;

    _apiKeys.addAll(
      rawKeys.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
    );

    if (_apiKeys.isEmpty) return this;

    _initializeRandomModel();

    return this;
  }

  void _initializeRandomModel() {
    if (_apiKeys.isEmpty) return;

    final randomKey = _apiKeys[Random().nextInt(_apiKeys.length)];

    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: randomKey,
      systemInstruction: Content.system(AppConstants.geminiSystemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
      ),
    );

    _chatSession = _model!.startChat();
  }

  bool get isAvailable => _model != null;

  Future<void> _ensureInitialized() async {
    if (_model != null) return;
    
    final rawKeys = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (rawKeys.isNotEmpty && _apiKeys.isEmpty) {
      _apiKeys.addAll(
        rawKeys.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
      );
    }
    
    if (_apiKeys.isNotEmpty) {
      _initializeRandomModel();
    }
  }

  Future<String> sendMessage(String userMessage) async {
    await _ensureInitialized();
    
    if (!isAvailable) {
      return 'Maaf, Tuberku AI sedang ada kendala. '
          'Silahkan coba beberapa saat lagi.';
    }

    return await _executeWithRetry(userMessage);
  }

  Future<String> _executeWithRetry(String userMessage, {int retries = 1}) async {
    try {
      _chatSession ??= _model!.startChat();
      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );
      
      String responseText = response.text ??
          'Maaf, tidak ada respons dari AI. Coba beberapa saat lagi.';
          
      // Strip markdown characters (** and #) for clean text UI
      responseText = responseText.replaceAll('**', '').replaceAll('#', '');
      
      return responseText;
    } on GenerativeAIException catch (e) {
      if (e.message.contains('429') || e.message.contains('quota')) {
        if (retries > 0 && _apiKeys.length > 1) {
          _initializeRandomModel();
          return await _executeWithRetry(userMessage, retries: retries - 1);
        }
        return 'Maaf, kuota harian AI telah habis. Silakan coba lagi besok.';
      }
      
      if (e.message.contains('safety')) {
        return 'Maaf, pertanyaan tersebut tidak dapat dijawab karena alasan keamanan. '
            'Silakan ajukan pertanyaan lain seputar TBC.';
      }
      return 'Maaf, Tuberku AI sedang tidak tersedia (AI Error: ${e.message}). Coba beberapa saat lagi.';
    } catch (e) {
      return 'Maaf, terjadi kesalahan (System Error: ${e.toString().split('\n')[0]}). Periksa koneksi internet Anda dan coba lagi.';
    }
  }

  void resetChat() {
    _initializeRandomModel();
  }
}
