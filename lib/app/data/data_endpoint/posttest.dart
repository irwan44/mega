class TestQuestion {
  final int id; // ID pertanyaan
  final int quizId; // ID kuis
  final String question;
  final List<String> options;
  final String correctAnswer;

  TestQuestion({
    required this.id,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory TestQuestion.fromApi(Map<String, dynamic> data) {
    return TestQuestion(
      id: data['id'],
      quizId: data['quiz_id'],
      question: data['question'],
      options: List<String>.from(data['choices'].map((choice) => choice['answer_text'])),
      correctAnswer: data['choices'][0]['answer_text'],
    );
  }
}
