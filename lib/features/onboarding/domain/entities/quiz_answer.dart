import 'package:equatable/equatable.dart';

/// Pure domain entity representing an answer to an onboarding question.
///
/// Contains zero framework dependencies strictly adhering to
/// Clean Architecture Article 1.
class QuizAnswer extends Equatable {
  /// Creates a [QuizAnswer] instance.
  const QuizAnswer({
    required this.questionIndex,
    required this.answer,
  });

  /// The zero-based index of the question (0 to 5 for the 6 questions).
  final int questionIndex;

  /// The selected answer identifier or text.
  final String answer;

  @override
  List<Object?> get props => [questionIndex, answer];
}
