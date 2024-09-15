class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromApi(Map<String, dynamic> data) {
    // Ambil jawaban yang benar, misalnya kita ambil jawaban pertama dari daftar
    String correctAnswer = data['choices'][0]['answer_text'];

    return Question(
      question: data['question'],
      options: List<String>.from(data['choices'].map((choice) => choice['answer_text'])),
      correctAnswer: correctAnswer,
    );
  }
}
