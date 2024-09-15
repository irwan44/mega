import 'dart:async';
import 'package:bank_mega/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/data_endpoint/pretest.dart';
import '../../../data/endpoint.dart';
import 'package:get/get.dart'; // Import Get untuk snackbar atau notifikasi

class QuizProvider extends ChangeNotifier {
  int currentQuestionIndex = 0;
  int score = 0;
  late Timer _timer;
  int _remainingTime = 60;
  bool isQuizOver = false;
  List<Question> questions = [];
  String? selectedAnswer;
  List<Map<String, dynamic>> answers = [];

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
      final List<Question> pretest = await API.PretestID();
      return pretest;
    } catch (e) {
      print('Error loading questions from API: $e');
      return [];
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
      selectedAnswer = null;
    } else {
      isQuizOver = true;
    }
    notifyListeners();
  }

  void answerQuestion(String answer) {
    selectedAnswer = answer;
    answers.add({
      "id": questions[currentQuestionIndex].id,
      "answer": answer
    });

    if (answer == questions[currentQuestionIndex].correctAnswer) {
      score++;
    }
    nextQuestion();
  }

  Future<void> submitQuiz(int quizId, int userId) async {
    try {
      // Panggil metode submitQuiz dari kelas API dan tangkap responsnya
      final result = await API.submitQuiz(quizId, userId, answers);

      // Dapatkan skor jawaban benar dan total pertanyaan dari respons
      final correctAnswersFromApi = result.data?.correctAnswers ?? 0;
      final totalQuestionsFromApi = result.data?.totalQuestions ?? 0;

      // Ambil skor yang ada di lokal untuk dibandingkan
      final prefs = await SharedPreferences.getInstance();
      final localCorrectAnswers = prefs.getInt('quiz_correct_answers') ?? 0;
      final localTotalQuestions = prefs.getInt('quiz_total_questions') ?? 0;

      // Periksa apakah ada perubahan
      if (correctAnswersFromApi != localCorrectAnswers || totalQuestionsFromApi != localTotalQuestions) {
        // Jika ada perubahan, simpan nilai baru
        await prefs.setInt('quiz_correct_answers', correctAnswersFromApi);
        await prefs.setInt('quiz_total_questions', totalQuestionsFromApi);
      }

      // Tampilkan dialog hasil quiz
      Get.defaultDialog(
        title: "Quiz Result",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/anm_celebration.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text("Total Questions: ${totalQuestionsFromApi}"),
            Text("Answered Questions: ${result.data?.answeredQuestions ?? 0}"),
            Text("Unanswered Questions: ${result.data?.unansweredQuestions ?? 0}"),
            Text("Wrong Answers: ${result.data?.wrongAnswers ?? 0}"),
            Text("Correct Answers: ${correctAnswersFromApi}"),
            Text("Rank: ${result.data?.rank ?? 0}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(Routes.HOME); // Navigasi ke halaman Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text('Go to Home'),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void restartQuiz() {
    currentQuestionIndex = 0;
    score = 0;
    isQuizOver = false;
    selectedAnswer = null;
    answers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
