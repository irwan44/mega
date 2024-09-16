import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart'; // Import provider
import '../../../data/data_endpoint/verifikasi.dart';
import '../../../data/endpoint.dart';
import '../componen/quiz_provider.dart';


  class QuizView extends StatefulWidget {
  const QuizView({Key? key}) : super(key: key);

  @override
  _QuizViewState createState() => _QuizViewState();
  }

  class _QuizViewState extends State<QuizView> with WidgetsBindingObserver {
    Future<Verifikasi?>? _userProfileFuture;
    @override
    void initState() {
      super.initState();
      _userProfileFuture = _loadUserProfile(); // Inisialisasi future untuk profil pengguna
    }
  int? userId;
  Future<Verifikasi?> _loadUserProfile() async {
    try {
      final verifikasi = await API.VerifikasiID();
      userId = verifikasi.data?.userId;
      return verifikasi;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    if (quizProvider.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Agency Pre-Test'),
        ),
        body: Center(
          child: LoadingAnimationWidget.newtonCradle(
            color:Colors.orange,
            size: 100,
          ),
        ),
      );
    }

    final question = quizProvider.questions[quizProvider.currentQuestionIndex];
    final progress = (quizProvider.currentQuestionIndex / quizProvider.questions.length) * 100;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Agency Pre-Test',
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
        centerTitle: true,
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
                    'Question ${quizProvider.currentQuestionIndex + 1}/${quizProvider.questions.length}',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 20),
                  Text(
                    question.question,
                    style: const TextStyle(
                        fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: (quizProvider.remainingTime / 60),
                    backgroundColor: Colors.grey[300],
                    color: Colors.orange,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '00:${quizProvider.remainingTime.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ..._buildAnswerOptions(quizProvider, question.options),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final quizId = question.quizId ?? 0;
                    if (userId != null) {
                      quizProvider.submitQuiz(quizId, userId!);
                    } else {
                      print('User ID not found');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  child: Icon(Icons.check, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: quizProvider.isQuizOver ? null : quizProvider.nextQuestion,
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

  List<Widget> _buildAnswerOptions(QuizProvider quizProvider, List<String> options) {
    const labels = ['A', 'B', 'C', 'D'];
    return options.asMap().entries.map((entry) {
      int index = entry.key;
      String option = entry.value;
      return GestureDetector(
        onTap: () {
          quizProvider.answerQuestion(option);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: quizProvider.selectedAnswer == option ? Colors.green.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: quizProvider.selectedAnswer == option ? Colors.green : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: quizProvider.selectedAnswer == option ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: quizProvider.selectedAnswer == option ? Colors.green : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 16,
                      color: quizProvider.selectedAnswer == option ? Colors.white : Colors.black,
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
                    color: quizProvider.selectedAnswer == option ? Colors.black : Colors.black,
                  ),
                ),
              ),
              if (quizProvider.selectedAnswer == option)
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
}
