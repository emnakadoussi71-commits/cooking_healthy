class Advice {
  final String id;
  final String content;
  final String nutritionistId;
  final List<String> tags;
  final DateTime publishedAt;

  const Advice({
    required this.id,
    required this.content,
    required this.nutritionistId,
    required this.tags,
    required this.publishedAt,
  });

  factory Advice.fromMap(String id, Map<String, dynamic> map) => Advice(
        id: id,
        content: map['content'] ?? '',
        nutritionistId: map['nutritionistId'] ?? '',
        tags: List<String>.from(map['tags'] ?? []),
        publishedAt: (map['publishedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'content': content,
        'nutritionistId': nutritionistId,
        'tags': tags,
        'publishedAt': publishedAt,
      };
}
