import '../models/flashcard.dart';

class SM2Algorithm {
  /// Updates the review history of a flashcard based on the user's grading quality (0-5).
  ///
  /// Grade representation:
  /// - 0-2: Fail (Incorrect, requires immediate reschedule)
  /// - 3: Pass (Correct with significant effort, difficult)
  /// - 4: Pass (Correct after hesitation, good)
  /// - 5: Perfect (No hesitation, easy)
  static ReviewHistory calculateNextReview(ReviewHistory currentHistory, int grade) {
    assert(grade >= 0 && grade <= 5);

    double newEase = currentHistory.ease;
    int newInterval = currentHistory.interval;
    int newRepetition = currentHistory.repetition;

    if (grade >= 3) {
      // Correct response
      if (newRepetition == 0) {
        newInterval = 1;
      } else if (newRepetition == 1) {
        newInterval = 6;
      } else {
        newInterval = (newInterval * newEase).round();
      }
      newRepetition += 1;
    } else {
      // Incorrect response
      newRepetition = 0;
      newInterval = 1;
    }

    // Update Ease Factor (E-Factor) formula
    newEase = newEase + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
    if (newEase < 1.3) {
      newEase = 1.3; // Lower limit for E-factor
    }

    DateTime nextReviewDate = DateTime.now().add(Duration(days: newInterval));

    return ReviewHistory(
      ease: newEase,
      interval: newInterval,
      repetition: newRepetition,
      nextReviewDate: nextReviewDate,
    );
  }
}
