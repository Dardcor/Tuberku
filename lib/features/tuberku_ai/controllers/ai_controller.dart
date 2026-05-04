import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/gemini_service.dart';
import '../../../app/config/app_constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? source;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.source,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'source': source,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
        source: json['source'] as String?,
      );
}

class AiController extends GetxController {
  final _gemini = Get.find<GeminiService>();
  final _storage = GetStorage();

  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _loadChatHistory();

    // Handle pre-filled question from article
    final preFilledQuestion = Get.arguments as String?;
    if (preFilledQuestion != null && preFilledQuestion.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sendMessage(preFilledQuestion);
      });
    }

    // Add welcome message if no history
    if (messages.isEmpty) {
      messages.add(ChatMessage(
        text: 'Halo! Saya Tuberku AI, asisten kesehatan Anda untuk informasi '
            'seputar Tuberkulosis (TBC). Saya bisa membantu menjawab pertanyaan '
            'tentang gejala, pengobatan, pencegahan, dan lainnya.\n\n'
            'Silakan ajukan pertanyaan Anda! 😊',
        isUser: false,
        timestamp: DateTime.now(),
        source: 'Kemenkes RI',
      ));
    }
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> sendMessage([String? overrideText]) async {
    final text = overrideText ?? textController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    textController.clear();
    _scrollToBottom();

    // Show typing indicator
    isTyping.value = true;

    // Get AI response
    final response = await _gemini.sendMessage(text);

    isTyping.value = false;

    // Determine source from response content
    String? source;
    if (response.toLowerCase().contains('kemenkes') ||
        response.toLowerCase().contains('who') ||
        response.toLowerCase().contains('dots')) {
      source = 'Sumber: Kemenkes RI';
    }

    messages.add(ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
      source: source,
    ));

    _scrollToBottom();
    _saveChatHistory();
  }

  void sendQuickQuestion(String question) {
    sendMessage(question);
  }

  void clearChat() {
    messages.clear();
    _gemini.resetChat();
    _storage.remove(AppConstants.storageKeyChatHistory);

    messages.add(ChatMessage(
      text: 'Chat telah direset. Silakan ajukan pertanyaan baru!',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _saveChatHistory() {
    final jsonList = messages.map((m) => m.toJson()).toList();
    _storage.write(AppConstants.storageKeyChatHistory, jsonEncode(jsonList));
  }

  void _loadChatHistory() {
    final cached =
        _storage.read<String>(AppConstants.storageKeyChatHistory);
    if (cached == null) return;

    try {
      final list = jsonDecode(cached) as List;
      final loaded = list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      messages.assignAll(loaded);
    } catch (_) {
      // Ignore corrupted cache
    }
  }
}
