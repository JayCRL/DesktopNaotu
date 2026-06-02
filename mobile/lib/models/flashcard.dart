class ReviewHistory {
  double ease;
  int interval; // Review interval in days
  int repetition; // Number of consecutive successful reviews
  DateTime nextReviewDate;

  ReviewHistory({
    this.ease = 2.5,
    this.interval = 0,
    this.repetition = 0,
    required this.nextReviewDate,
  });

  factory ReviewHistory.fromJson(Map<String, dynamic> json) {
    return ReviewHistory(
      ease: (json['ease'] as num?)?.toDouble() ?? 2.5,
      interval: json['interval'] as int? ?? 0,
      repetition: json['repetition'] as int? ?? 0,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ease': ease,
      'interval': interval,
      'repetition': repetition,
      'nextReviewDate': nextReviewDate.toIso8601String(),
    };
  }
}

class Flashcard {
  final String id;
  final String front; // Question or concept prompt
  final String back; // Answer or explanation
  final String type; // 'qa' (Q&A) or 'cloze' (Fill in the blank)
  ReviewHistory history;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.type = 'qa',
    required this.history,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String? ?? '',
      front: json['front'] as String? ?? '',
      back: json['back'] as String? ?? '',
      type: json['type'] as String? ?? 'qa',
      history: json['history'] != null
          ? ReviewHistory.fromJson(json['history'] as Map<String, dynamic>)
          : ReviewHistory(nextReviewDate: DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'type': type,
      'history': history.toJson(),
    };
  }
}
