<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/models/article_model.dart';
import '../../../core/widgets/app_button.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final article = Get.arguments as ArticleModel?;

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Artikel')),
        body: const Center(child: Text('Artikel tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final uri = Uri.tryParse(article.link);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.badgeGreenBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                article.source,
                style: const TextStyle(
                  color: AppColors.badgeGreenText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              article.title,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            // Date & read time
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  article.pubDate != null
                      ? DateFormat('dd MMMM yyyy').format(article.pubDate!)
                      : '-',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(article.readingTime, style: AppTextStyles.bodySmall),
              ],
            ),
            const Divider(height: 32),
            // Content
            Text(
              article.description,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.7),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AppButton(
          text: 'Tanya Tuberku AI →',
          icon: Icons.smart_toy,
          onPressed: () {
            Get.toNamed(
              AppRoutes.aiChat,
              arguments: 'Jelaskan tentang: ${article.title}',
            );
          },
        ),
      ),
    );
  }
}
=======
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/models/article_model.dart';
import '../../../core/widgets/app_button.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final article = Get.arguments as ArticleModel?;

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Artikel')),
        body: const Center(child: Text('Artikel tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final uri = Uri.tryParse(article.link);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                article.source,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              article.title,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            // Date & read time
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  article.pubDate != null
                      ? DateFormat('dd MMMM yyyy').format(article.pubDate!)
                      : '-',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(article.readingTime, style: AppTextStyles.bodySmall),
              ],
            ),
            const Divider(height: 32),
            // Content
            Text(
              article.description,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.7),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AppButton(
          text: 'Tanya Tuberku AI →',
          icon: Icons.smart_toy,
          onPressed: () {
            Get.toNamed(
              AppRoutes.aiChat,
              arguments: 'Jelaskan tentang: ${article.title}',
            );
          },
        ),
      ),
    );
  }
}
<<<<<<< HEAD
=======
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
