class Question {
  final int id; // ID pertanyaan
  final int quizId; // ID kuis
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.id,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  // Tambahkan metode factory untuk memuat data dari API
  factory Question.fromApi(Map<String, dynamic> data) {
    return Question(
      id: data['id'],
      quizId: data['quiz_id'],
      question: data['question'],
      options: List<String>.from(data['choices'].map((choice) => choice['answer_text'])),
      correctAnswer: data['choices'][0]['answer_text'], // Asumsi jawaban pertama sebagai jawaban yang benar
    );
  }
}
