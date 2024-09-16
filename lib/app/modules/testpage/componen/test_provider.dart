import 'dart:async';
import 'package:bank_mega/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../../data/data_endpoint/posttest.dart';
import '../../../data/endpoint.dart';

class TestProvider extends ChangeNotifier {
  int currentQuestionIndex = 0;
  int score = 0;
  Timer? _timer;
  int _remainingTime = 60; // Set waktu default per pertanyaan
  bool isQuizOver = false;
  List<TestQuestion> questions = [];
  String? selectedAnswer;
  List<Map<String, dynamic>> answers = [];

  TestProvider() {
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    print('Memulai inisialisasi quiz...');
    questions = await _loadQuestionsFromApi();
    print('Jumlah pertanyaan yang dimuat: ${questions.length}');
    _startTimer(); // Mulai timer setelah pertanyaan dimuat
    notifyListeners();
  }

  Future<List<TestQuestion>> _loadQuestionsFromApi() async {
    try {
      final List<TestQuestion> pretest = await API.TestPretestID();
      print('Pertanyaan berhasil dimuat dari API: $pretest');
      return pretest;
    } catch (e) {
      print('Error loading questions from API: $e');
      return [];
    }
  }

  void _startTimer() {
    print('Memulai timer...');
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
      print('Mengirim hasil kuis...');
      final result = await API.submitTest(quizId, userId, answers);
      final correctAnswersFromApi = result.data?.correctAnswers ?? 0;
      final totalQuestionsFromApi = result.data?.totalQuestions ?? 0;
      final prefs = await SharedPreferences.getInstance();
      final localCorrectAnswers = prefs.getInt('test_correct_answers') ?? 0;
      final localTotalQuestions = prefs.getInt('test_total_questions') ?? 0;

      if (correctAnswersFromApi != localCorrectAnswers || totalQuestionsFromApi != localTotalQuestions) {
        await prefs.setInt('test_correct_answers', correctAnswersFromApi);
        await prefs.setInt('test_total_questions', totalQuestionsFromApi);
      }

      print('Hasil kuis berhasil dikirim: ${result.data}');
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
                Get.offAllNamed(Routes.HOME);
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
      print('Error saat mengirim hasil kuis: $e');
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
