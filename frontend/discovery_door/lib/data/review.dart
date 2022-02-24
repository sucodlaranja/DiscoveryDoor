class Review {
  final String username;
  final String date;
  final double evaluation;
  final String text;

  Review({
    required this.username,
    required this.date,
    required this.evaluation,
    required this.text,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      username: json['username'],
      date: json['date'],
      evaluation: json['avaliacao'],
      text: json['texto'],
    );
  }
}
