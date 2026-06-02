class Quiz {
  final String id;
  final String question;
  final String type; // 'single_choice', 'true_false', 'qa'
  final List<String> options; // List of choices e.g., ["A. ...", "B. ..."]
  final String answer; // Correct answer e.g., "C" or "A" or "True"
  final String explanation; // Explanation for why it is correct

  Quiz({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      type: json['type'] as String? ?? 'single_choice',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'answer': answer,
      'explanation': explanation,
    };
  }
}
