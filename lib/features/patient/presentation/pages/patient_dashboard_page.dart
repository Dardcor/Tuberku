import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/greeting_banner_widget.dart';
import '../widgets/ask_question_banner_widget.dart';
import '../widgets/article_card_widget.dart';

class PatientDashboardPage extends StatelessWidget {
  const PatientDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        title: const Text(
          'Tuberku',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                onPressed: () {},
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GreetingBannerWidget(),
              const SizedBox(height: 24),
              const AskQuestionBannerWidget(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Artikel Terbaru',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    ArticleCardWidget(
                      source: 'Kemenkes',
                      date: '12 Okt 2023',
                      title: 'Pentingnya Kepatuhan Minum Obat TBC Hingga Tuntas',
                    ),
                    ArticleCardWidget(
                      source: 'WHO',
                      date: '10 Okt 2023',
                      title: 'Mengenal Gejala Awal TBC dan Kapan Harus ke Dokter',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
