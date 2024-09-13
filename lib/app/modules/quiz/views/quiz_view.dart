import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

import '../../home/views/home_view.dart';
import '../../home/views/view.dart';
import '../componen/quiz_provider.dart';

class QuizView extends StatefulWidget {
  const QuizView({Key? key}) : super(key: key);

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int currentQuestionIndex = 0;
  int score = 0;
  Timer? _timer;
  int _remainingTime = 60;
  bool isQuizOver = false;
  int answeredQuestions = 0;
  String? selectedAnswer; // To track the selected answer

  @override
  void initState() {
    super.initState();
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _moveToNextQuestion();
      }
    });
  }

  void _moveToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        answeredQuestions++;
        selectedAnswer = null; // Reset selected answer for next question
      });
      _startQuestionTimer();
    } else {
      setState(() {
        isQuizOver = true;
      });
      _timer?.cancel();
      _saveQuizScore(); // Save score locally
      _showQuizResultDialog(); // Show result dialog after quiz completion
    }
  }

  Future<void> _saveQuizScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_score', score); // Save score with key 'quiz_score'
  }

  void _showQuizResultDialog() {
    Get.defaultDialog(
      title: 'Quiz Result',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You answered $answeredQuestions questions.\n'
                'Your score is $score.\n'
                'Correct answers: $score out of ${questions.length}',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextButton(
            child: Text('Go to Home'),
            onPressed: () {
              Get.back(); // Close the dialog
              _navigateToHome();
            },
          ),
        ],
      ),
      barrierDismissible: true,
      backgroundColor: Colors.white,
    );
  }

  void _navigateToHome() {
    Get.off(() => HomeView(
    ));
  }

  void answerQuestion() {
    if (selectedAnswer == questions[currentQuestionIndex].correctAnswer) {
      setState(() {
        score++;
      });
    }
    _moveToNextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];
    final progress = (answeredQuestions / questions.length) * 100;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Agency Pre-Test',
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.orange[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1}/${questions.length}',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 20,),
                  Text(
                    question.question,
                    style: const TextStyle(
                        fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: (_remainingTime / 60),
                    backgroundColor: Colors.grey[300],
                    color: Colors.orange,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '00:${_remainingTime.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ..._buildAnswerOptions(question.options),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  child: Icon(Icons.check, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  child: Icon(Icons.people, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  child: Icon(Icons.add_alarm, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: selectedAnswer == null ? null : answerQuestion,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  child: Icon(Icons.skip_next, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnswerOptions(List<String> options) {
    const labels = ['A', 'B', 'C', 'D'];
    return options.asMap().entries.map((entry) {
      int index = entry.key;
      String option = entry.value;
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedAnswer = option;
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selectedAnswer == option ? Colors.green.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedAnswer == option ? Colors.green : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selectedAnswer == option ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedAnswer == option ? Colors.green : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedAnswer == option ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 18,
                    color: selectedAnswer == option ? Colors.black : Colors.black,
                  ),
                ),
              ),
              if (selectedAnswer == option)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.check_circle, color: Colors.green),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
