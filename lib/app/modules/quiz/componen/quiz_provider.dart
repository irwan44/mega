import 'dart:async';
import 'package:bank_mega/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/data_endpoint/pretest.dart';
import '../../../data/endpoint.dart';
import 'package:get/get.dart';

class QuizProvider extends ChangeNotifier {
  int currentQuestionIndex = 0;
  int score = 0;
  Timer? _timer;
  int _remainingTime = 60;
  bool isQuizOver = false;
  List<Question> questions = [];
  String? selectedAnswer;
  List<Map<String, dynamic>> answers = [];

  QuizProvider() {
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    questions = await _loadQuestionsFromApi();
    _startTimer(); // Mulai timer setelah pertanyaan dimuat
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
    _remainingTime = 60; // Setel ulang waktu setiap kali timer dimulai
    _timer?.cancel(); // Hentikan timer sebelumnya jika ada
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        print('Sisa waktu untuk pertanyaan ${currentQuestionIndex + 1}: $_remainingTime detik');
        notifyListeners();
      } else {
        _timer?.cancel();
        _handleTimeout(); // Panggil fungsi untuk menangani waktu habis
      }
    });
  }

  void _handleTimeout() {
    print('Waktu untuk pertanyaan habis, lanjutkan ke pertanyaan berikutnya.');
    nextQuestion();
  }

  int get remainingTime => _remainingTime;

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      selectedAnswer = null;
      _startTimer(); // Mulai timer lagi untuk pertanyaan berikutnya
    } else {
      isQuizOver = true;
      _timer?.cancel();
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
      final result = await API.submitQuiz(quizId, userId, answers);
      final correctAnswersFromApi = result.data?.correctAnswers ?? 0;
      final totalQuestionsFromApi = result.data?.totalQuestions ?? 0;
      final prefs = await SharedPreferences.getInstance();
      final localCorrectAnswers = prefs.getInt('quiz_correct_answers') ?? 0;
      final localTotalQuestions = prefs.getInt('quiz_total_questions') ?? 0;
      if (correctAnswersFromApi != localCorrectAnswers || totalQuestionsFromApi != localTotalQuestions) {
        await prefs.setInt('quiz_correct_answers', correctAnswersFromApi);
        await prefs.setInt('quiz_total_questions', totalQuestionsFromApi);
      }
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
            Text("Total Questions: ${totalQuestionsFromApi}", style: GoogleFonts.nunito(),),
            Text("Answered Questions: ${result.data?.answeredQuestions ?? 0}", style: GoogleFonts.nunito(),),
            Text("Unanswered Questions: ${result.data?.unansweredQuestions ?? 0}", style: GoogleFonts.nunito(),),
            Text("Wrong Answers: ${result.data?.wrongAnswers ?? 0}", style: GoogleFonts.nunito(),),
            Text("Correct Answers: ${correctAnswersFromApi}", style: GoogleFonts.nunito(),),
            Text("Rank: ${result.data?.rank ?? 0}", style: GoogleFonts.nunito(),),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(Routes.HOME); // Navigasi ke halaman Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text('Go to Home', style: GoogleFonts.nunito(color: Colors.white),),
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
    _startTimer(); // Mulai timer lagi ketika kuis diulang
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
