import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../data/data_endpoint/verifikasi.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';
import '../componen/test_provider.dart';

class TestpageView extends StatefulWidget {
  const TestpageView({Key? key}) : super(key: key);

  @override
  _TestpageViewState createState() => _TestpageViewState();
}

class _TestpageViewState extends State<TestpageView> with WidgetsBindingObserver {
  late RefreshController _refreshController;
  Future<Verifikasi?>? _userProfileFuture;
  int? userId;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final testQuizProvider = Provider.of<TestProvider>(context, listen: false);
    if (state == AppLifecycleState.paused) {
      // Pause the timer if the app goes to background
      testQuizProvider.pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      // Resume the timer when returning to the page
      testQuizProvider.resumeTimer();
    }
  }

  @override
  void initState() {
    super.initState();
    final testQuizProvider = Provider.of<TestProvider>(context, listen: false);
    testQuizProvider.initializeQuiz(); // Initialize quiz
    testQuizProvider.resumeTimer(); // Resume timer
    _refreshController = RefreshController(initialRefresh: false);
    _userProfileFuture = _loadUserProfile();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final testQuizProvider = Provider.of<TestProvider>(context, listen: false);
      testQuizProvider.initializeQuiz();
    });
  }

  Future<Verifikasi?> _loadUserProfile() async {
    try {
      final verifikasi = await API.VerifikasiID();
      userId = verifikasi.data?.userId; // Simpan userId dari respons
      return verifikasi;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    final testQuizProvider = Provider.of<TestProvider>(context, listen: false);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final testQuizProvider = Provider.of<TestProvider>(context);

    if (testQuizProvider.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Agency Pre-Test'),
        ),
        body: Center(
          child: LoadingAnimationWidget.newtonCradle(
            color: Colors.orange,
            size: 100,
          ),
        ),
      );
    }

    final question = testQuizProvider.questions[testQuizProvider.currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async {
        Get.offNamed(Routes.HOME);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Agency Post-Test',
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Get.toNamed(Routes.HOME);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.black),
              onPressed: _onRefresh,
            ),
          ],
        ),
        body: FutureBuilder<Verifikasi?>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.newtonCradle(
                  color: Colors.orange,
                  size: 100,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error loading user profile'),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              userId = snapshot.data!.data?.userId;
              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                onRefresh: _onRefresh,
                header: const WaterDropHeader(),
                child: SingleChildScrollView(
                  child: Container(
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
                                'Question ${testQuizProvider.currentQuestionIndex + 1}/${testQuizProvider.questions.length}',
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
                                value: (testQuizProvider.remainingTime / 60),
                                backgroundColor: Colors.grey[300],
                                color: Colors.orange,
                              ),
                              SizedBox(height: 5),
                              Text(
                                '00:${testQuizProvider.remainingTime.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ..._buildAnswerOptions(testQuizProvider, question.options),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                final quizId = question.quizId ?? 0;
                                if (userId != null) {
                                  testQuizProvider.submitQuiz(quizId, userId!); // Use the fetched userId
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
                              onPressed: testQuizProvider.isQuizOver ? null : testQuizProvider.nextQuestion,
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
                ),
              );
            } else {
              return Center(
                child: Text('No user profile found'),
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildAnswerOptions(TestProvider quizProvider, List<String> options) {
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

