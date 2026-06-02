import 'dart:convert';
import '../models/mind_map_node.dart';
import '../models/flashcard.dart';
import '../models/quiz.dart';

class MindMapParser {
  /// Parses KityMinder JSON string to build the root node tree
  static MindMapNode parseJson(String jsonString) {
    final Map<String, dynamic> rawJson = json.decode(jsonString);
    
    // In KityMinder, the main payload starts at rawJson['root']
    if (rawJson.containsKey('root')) {
      return MindMapNode.fromJson(rawJson['root'] as Map<String, dynamic>);
    } else if (rawJson.containsKey('data') && rawJson.containsKey('children')) {
      return MindMapNode.fromJson(rawJson);
    } else {
      throw FormatException("Invalid KityMinder file structure. 'root' node not found.");
    }
  }

  /// Traverses the tree and recursively collects all flashcards
  static List<Flashcard> extractAllFlashcards(MindMapNode node) {
    List<Flashcard> cards = List.from(node.flashcards);
    for (var child in node.children) {
      cards.addAll(extractAllFlashcards(child));
    }
    return cards;
  }

  /// Traverses the tree and recursively collects all quizzes
  static List<Quiz> extractAllQuizzes(MindMapNode node) {
    List<Quiz> quizzes = List.from(node.quizzes);
    for (var child in node.children) {
      quizzes.addAll(extractAllQuizzes(child));
    }
    return quizzes;
  }

  /// Filters flashcards that are due for review (nextReviewDate is today or past)
  static List<Flashcard> extractDueFlashcards(MindMapNode node) {
    final now = DateTime.now();
    return extractAllFlashcards(node)
        .where((card) => card.history.nextReviewDate.isBefore(now))
        .toList();
  }
}
