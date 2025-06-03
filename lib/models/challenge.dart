class Challenge {
  final String id;
  final String title;
  final String description;
  final int durationDays;
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.createdAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      durationDays: json['duration_days'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}