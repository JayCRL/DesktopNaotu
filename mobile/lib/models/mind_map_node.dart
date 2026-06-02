import 'flashcard.dart';
import 'quiz.dart';

class MindMapNode {
  final String id;
  final String text;
  final String? notes;
  final List<MindMapNode> children;
  final List<Flashcard> flashcards;
  final List<Quiz> quizzes;
  int level; // Dynamic tree depth indicator

  MindMapNode({
    required this.id,
    required this.text,
    this.notes,
    required this.children,
    required this.flashcards,
    required this.quizzes,
    this.level = 0,
  });

  factory MindMapNode.fromJson(Map<String, dynamic> json, [int currentLevel = 0]) {
    // KityMinder stores node data in a sub-property called 'data'
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final rawChildren = json['children'] as List<dynamic>? ?? [];

    final childrenList = rawChildren
        .map((child) => MindMapNode.fromJson(child as Map<String, dynamic>, currentLevel + 1))
        .toList();

    final flashcardsList = (data['flashcards'] as List<dynamic>?)
            ?.map((fc) => Flashcard.fromJson(fc as Map<String, dynamic>))
            .toList() ??
        [];

    final quizzesList = (data['quizzes'] as List<dynamic>?)
            ?.map((qz) => Quiz.fromJson(qz as Map<String, dynamic>))
            .toList() ??
        [];

    return MindMapNode(
      id: data['id'] as String? ?? '',
      text: data['text'] as String? ?? '',
      notes: data['notes'] as String?,
      children: childrenList,
      flashcards: flashcardsList,
      quizzes: quizzesList,
      level: currentLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'id': id,
        'text': text,
        'notes': notes,
        'flashcards': flashcards.map((fc) => fc.toJson()).toList(),
        'quizzes': quizzes.map((qz) => qz.toJson()).toList(),
      },
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}
