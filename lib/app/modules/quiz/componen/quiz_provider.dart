import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizProvider extends ChangeNotifier {
  int currentQuestionIndex = 0;
  int score = 0;
  late Timer _timer;
  int _remainingTime = 60;
  bool isQuizOver = false;

  QuizProvider() {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _timer.cancel();
        isQuizOver = true;
        notifyListeners();
      }
    });
  }

  int get remainingTime => _remainingTime;

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
    } else {
      isQuizOver = true;
    }
    notifyListeners();
  }

  void answerQuestion(String answer) {
    if (answer == questions[currentQuestionIndex].correctAnswer) {
      score++;
    }
    nextQuestion();
  }
}

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

List<Question> questions = [
  Question(
    question: 'What is the capital of France?',
    options: ['Paris', 'London', 'Berlin', 'Madrid'],
    correctAnswer: 'Paris',
  ),
  Question(
    question: 'What is the largest ocean?',
    options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
    correctAnswer: 'Pacific',
  ),
  Question(
    question: 'What is the smallest planet in our solar system?',
    options: ['Mars', 'Mercury', 'Venus', 'Earth'],
    correctAnswer: 'Mercury',
  ),
  Question(
    question: 'Who wrote "To Kill a Mockingbird"?',
    options: ['Harper Lee', 'Mark Twain', 'Ernest Hemingway', 'J.K. Rowling'],
    correctAnswer: 'Harper Lee',
  ),
  Question(
    question: 'What is the chemical symbol for gold?',
    options: ['Au', 'Ag', 'Pb', 'Fe'],
    correctAnswer: 'Au',
  ),
];

class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final question = questions[quizProvider.currentQuestionIndex];
    final isQuizOver = quizProvider.isQuizOver;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
      ),
      body: isQuizOver
          ? Center(
        child: Text(
          'Quiz Over! Your score is ${quizProvider.score}',
          style: const TextStyle(fontSize: 24),
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Question ${quizProvider.currentQuestionIndex + 1} of ${questions.length}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              question.question,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          ...question.options.map((option) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  quizProvider.answerQuestion(option);
                },
                child: Text(option),
              ),
            );
          }).toList(),
          Spacer(),
          Center(
            child: Text(
              'Time remaining: ${quizProvider.remainingTime}s',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
