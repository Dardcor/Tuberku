class ArticleModel {
  final String title;
  final String link;
  final String description;
  final DateTime? pubDate;
  final String source;

  const ArticleModel({
    required this.title,
    required this.link,
    required this.description,
    this.pubDate,
    required this.source,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] as String? ?? '',
      link: json['link'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pubDate: json['pub_date'] != null
          ? DateTime.tryParse(json['pub_date'] as String)
          : null,
      source: json['source'] as String? ?? 'Kemenkes RI',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'description': description,
      'pub_date': pubDate?.toIso8601String(),
      'source': source,
    };
  }

  String get readingTime {
    final wordCount = description.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes menit baca';
  }
}
