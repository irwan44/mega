import 'dart:async';

import 'package:get/get.dart';
import '../componen/quiz_provider.dart';

class QuizController extends GetxController {
  var currentQuestionIndex = 0.obs;
  var score = 0.obs;
  var remainingTime = 60.obs;
  var isQuizOver = false.obs;
  late final Timer _timer;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        remainingTime--;
      } else {
        _timer.cancel();
        isQuizOver.value = true;
      }
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
    } else {
      isQuizOver.value = true;
    }
  }

  void answerQuestion(String answer) {
    if (answer == questions[currentQuestionIndex.value].correctAnswer) {
      score++;
    }
    nextQuestion();
  }
}
