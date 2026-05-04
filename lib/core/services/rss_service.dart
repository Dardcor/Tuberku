import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dart_rss/dart_rss.dart';
import '../../app/config/app_constants.dart';
import '../models/article_model.dart';

class RssService extends GetxService {
  late final Dio _dio;
  final _storage = GetStorage();

  Future<RssService> init() async {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    return this;
  }

  Future<List<ArticleModel>> fetchArticles() async {
    // Check cache
    final cached = _getCachedArticles();
    if (cached != null) return cached;

    try {
      final response = await _dio.get(AppConstants.rssFeedUrl);
      final feed = RssFeed.parse(response.data as String);

      final articles = feed.items?.map((item) {
            return ArticleModel(
              title: item.title ?? '',
              link: item.link ?? '',
              description: _stripHtml(item.description ?? ''),
              pubDate: _parseDate(item.pubDate),
              source: 'Kemenkes RI',
            );
          }).toList() ??
          [];

      // Cache the results
      _cacheArticles(articles);
      return articles;
    } on DioException {
      // Return cached data if available, otherwise empty
      return _getCachedArticles() ?? [];
    } catch (_) {
      return _getCachedArticles() ?? [];
    }
  }

  void _cacheArticles(List<ArticleModel> articles) {
    final jsonList = articles.map((a) => a.toJson()).toList();
    _storage.write(AppConstants.storageKeyRssCache, jsonEncode(jsonList));
    _storage.write(
      AppConstants.storageKeyRssCacheTime,
      DateTime.now().toIso8601String(),
    );
  }

  List<ArticleModel>? _getCachedArticles() {
    final cacheTimeStr =
        _storage.read<String>(AppConstants.storageKeyRssCacheTime);
    if (cacheTimeStr == null) return null;

    final cacheTime = DateTime.tryParse(cacheTimeStr);
    if (cacheTime == null) return null;

    final elapsed = DateTime.now().difference(cacheTime);
    if (elapsed.inHours >= AppConstants.rssCacheDurationHours) return null;

    final cachedJson = _storage.read<String>(AppConstants.storageKeyRssCache);
    if (cachedJson == null) return null;

    try {
      final list = jsonDecode(cachedJson) as List;
      return list
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return HttpDate.parse(dateStr);
    } catch (_) {
      return DateTime.tryParse(dateStr);
    }
  }
}
