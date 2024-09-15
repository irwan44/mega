import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/data_endpoint/pretest.dart';
import '../../../data/endpoint.dart';

class QuizProvider extends ChangeNotifier {
  int currentQuestionIndex = 0;
  int score = 0;
  late Timer _timer;
  int _remainingTime = 60;
  bool isQuizOver = false;
  List<Question> questions = [];
  String? selectedAnswer; // To track the selected answer

  QuizProvider() {
    _initializeQuiz();
    _startTimer();
  }

  Future<void> _initializeQuiz() async {
    questions = await _loadQuestionsFromApi();
    notifyListeners();
  }

  Future<List<Question>> _loadQuestionsFromApi() async {
    try {
      final List<Question> pretest = await API.PretestID(); // Fetch questions from API
      return pretest; // Return the list of questions
    } catch (e) {
      print('Error loading questions from API: $e');
      return []; // Return an empty list if an error occurs
    }
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
      selectedAnswer = null; // Reset the selected answer for the next question
    } else {
      isQuizOver = true;
    }
    notifyListeners();
  }

  void answerQuestion(String answer) {
    selectedAnswer = answer; // Track the selected answer
    if (answer == questions[currentQuestionIndex].correctAnswer) {
      score++;
    }
    nextQuestion();
  }

  Future<void> refreshQuestions() async {
    questions = await _loadQuestionsFromApi();
    currentQuestionIndex = 0;
    score = 0;
    isQuizOver = false;
    selectedAnswer = null; // Reset selectedAnswer when refreshing questions
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
