import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import '../../../data/data_endpoint/posttest.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';

class TestProvider extends ChangeNotifier {
  int currentQuestionIndex = 0;
  int score = 0;
  Timer? _timer;
  int _remainingTime = 60; // Set waktu default per pertanyaan
  bool isQuizOver = false;
  List<TestQuestion> questions = [];
  String? selectedAnswer;
  List<Map<String, dynamic>> answers = [];
  bool isInitialized = false;
  bool isPaused = false; // Menambahkan flag untuk cek apakah timer dipause

  TestProvider() {
    initializeQuiz();
  }

  Future<void> initializeQuiz() async {
    if (!isInitialized) {
      print('Memulai inisialisasi quiz...');
      await refreshQuestions(); // Memuat pertanyaan dari API
      _startTimer(); // Mulai timer setelah pertanyaan dimuat
      isInitialized = true; // Tandai sebagai sudah diinisialisasi
    }
  }

  Future<void> refreshQuestions() async {
    print('Memuat ulang pertanyaan dari API...');
    questions = await _loadQuestionsFromApi();
    print('Jumlah pertanyaan yang dimuat ulang: ${questions.length}');
    currentQuestionIndex = 0; // Reset ke pertanyaan pertama
    selectedAnswer = null;
    answers.clear(); // Kosongkan jawaban sebelumnya
    _resetTimer(); // Mulai ulang timer
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
    _remainingTime = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0 && !isPaused) {
        _remainingTime--;
        print('Sisa waktu untuk pertanyaan ${currentQuestionIndex + 1}: $_remainingTime detik');
        notifyListeners();
      } else if (_remainingTime <= 0) {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel(); // Hentikan timer sebelumnya jika ada
    _remainingTime = 60; // Setel ulang waktu untuk pertanyaan baru
    _startTimer(); // Mulai ulang timer
  }

  void pauseTimer() {
    isPaused = true;
    _timer?.cancel();
  }

  void resumeTimer() {
    if (isPaused) {
      isPaused = false;
      _startTimer(); // Mulai timer kembali saat halaman aktif lagi
    }
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
      _resetTimer(); // Mulai ulang timer untuk pertanyaan berikutnya
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
  bool areAllQuestionsAnswered() {
    return answers.length == questions.length;
  }

  Future<void> QuizRefresh(int quizId, int userId) async {
    await refreshQuestions();
  }

  Future<void> submitQuiz(int quizId, int userId) async {
    if (!areAllQuestionsAnswered()) {
      Get.dialog(
        AlertDialog(
          title: Text('Incomplete Quiz'),
          content: Text('Please answer all the questions before submitting the quiz.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Menutup dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    Get.toNamed(Routes.HOME);
    // Pause the timer when submitting the quiz
    pauseTimer();

    // Jika semua pertanyaan sudah dijawab, lanjutkan dengan submit
    try {
      print('Mengirim hasil kuis...');
      final result = await API.submitTest(quizId, userId, answers);

      // Ambil data dari response API
      final totalQuestionsFromApi = result.data?.totalQuestions ?? 0;
      final answeredQuestionsFromApi = result.data?.answeredQuestions ?? 0;
      final unansweredQuestionsFromApi = result.data?.unansweredQuestions ?? 0;
      final wrongAnswersFromApi = result.data?.wrongAnswers ?? 0;
      final correctAnswersFromApi = result.data?.correctAnswers ?? 0;
      final rankFromApi = result.data?.rank ?? 0;
      await refreshQuestions();
      // Tampilkan hasil dalam bottom sheet
      await Get.bottomSheet(
        isDismissible: false, // Disable dismissing the bottom sheet
        enableDrag: false, // Disable dragging down to close
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/anm_celebration.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              Column(
                children: [
                  Text("Total Questions: $totalQuestionsFromApi", style: GoogleFonts.nunito()),
                  Text("Answered Questions: $answeredQuestionsFromApi", style: GoogleFonts.nunito()),
                  Text("Unanswered Questions: $unansweredQuestionsFromApi", style: GoogleFonts.nunito()),
                  Text("Wrong Answers: $wrongAnswersFromApi", style: GoogleFonts.nunito()),
                  Text("Correct Answers: $correctAnswersFromApi", style: GoogleFonts.nunito()),
                  Text("Rank: $rankFromApi", style: GoogleFonts.nunito()),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text('Back', style: GoogleFonts.nunito(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );

      // Refresh questions after the bottom sheet is closed


      print("Hasil kuis berhasil dikirim: ${result.data}");

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
    answers.clear(); // Kosongkan jawaban
    _resetTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
