import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../app/config/app_constants.dart';

class GeminiService extends GetxService {
  GenerativeModel? _model;
  ChatSession? _chatSession;

  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  Future<GeminiService> init() async {
    if (_apiKey.isEmpty) return this;

    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: _apiKey,
      systemInstruction: Content.system(AppConstants.geminiSystemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 800,
      ),
    );

    _chatSession = _model!.startChat();
    return this;
  }

  bool get isAvailable => _model != null && _apiKey.isNotEmpty;

  Future<String> sendMessage(String userMessage) async {
    if (!isAvailable) {
      return 'Maaf, Tuberku AI sedang tidak tersedia. '
          'Pastikan API key sudah dikonfigurasi.';
    }

    try {
      _chatSession ??= _model!.startChat();
      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );
      return response.text ??
          'Maaf, tidak ada respons dari AI. Coba beberapa saat lagi.';
    } on GenerativeAIException catch (e) {
      if (e.message.contains('safety')) {
        return 'Maaf, pertanyaan tersebut tidak dapat dijawab karena alasan keamanan. '
            'Silakan ajukan pertanyaan lain seputar TBC.';
      }
      return 'Maaf, Tuberku AI sedang tidak tersedia. Coba beberapa saat lagi.';
    } catch (_) {
      return 'Maaf, terjadi kesalahan. Periksa koneksi internet Anda dan coba lagi.';
    }
  }

  void resetChat() {
    _chatSession = _model?.startChat();
  }
}
