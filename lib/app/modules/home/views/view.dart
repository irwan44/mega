import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bank_mega/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/data_endpoint/verifikasi.dart';
import '../../../data/endpoint.dart';
import '../../testpage/views/testpage_view.dart'; // Import route file

class ViewHome extends StatefulWidget {
  const ViewHome({super.key});

  @override
  State<ViewHome> createState() => _ViewHomeState();
}

Future<Map<String, int>?> _loadQuizScore() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final correctAnswers = prefs.getInt('quiz_correct_answers') ?? 0;
    final totalQuestions = prefs.getInt('quiz_total_questions') ?? 1;

    if (totalQuestions > 0) {
      return {'score': correctAnswers, 'total': totalQuestions};
    } else {
      return null;
    }
  } catch (e) {
    print('Error loading quiz score: $e');
    return null;
  }
}

Future<Map<String, int>?> _loadTestQuizScore() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final correctAnswers = prefs.getInt('test_correct_answers') ?? 0;
    final totalQuestions = prefs.getInt('test_total_questions') ?? 1;

    if (totalQuestions > 0) {
      return {'score': correctAnswers, 'total': totalQuestions};
    } else {
      return null;
    }
  } catch (e) {
    print('Error loading quiz score: $e');
    return null;
  }
}

class _ViewHomeState extends State<ViewHome> {
  late RefreshController _refreshController;
  int _currentIndex = 0;
  Future<Verifikasi?>? _userProfileFuture;
  Future<Map<String, int>?>? _quizScoreFuture;

  final List<String> imgList = [
    'assets/gambar/product_health_ins.png',
    'assets/gambar/product_vehicle_ins.png',
    'assets/gambar/product_travel_ins.png',
    'assets/gambar/product_house_ins.png',
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _userProfileFuture = _loadUserProfile();
    _quizScoreFuture = _loadQuizScore();
  }

  Future<Verifikasi?> _loadUserProfile() async {
    try {
      final verifikasi = await API.VerifikasiID();
      return verifikasi;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              const ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.orange),
                title: Text(
                  'Keluar Aplikasi?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(false), // Jangan keluar
                    child: const Text(
                      'Tidak',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true), // Keluar
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Ya',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          title: Image.asset(
            'assets/logo/mega_insurance.png',
            height: 30,
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            InkWell(
              onTap: () {
                _showRanksUnderDevelopmentNotifikasi();
              },
              child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1000),
                border: Border.all(color: Colors.orange),
              ),
              child: const Icon(
                Icons.notification_important_sharp,
                color: Colors.orange,
                size: 18,
                ),
              ),
            ),
          ],
        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          header: const WaterDropHeader(),
          onLoading: _onLoading,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                _Slider(context),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 975),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        const SizedBox(
                          height: 170,
                        ),
                        Container(
                          width: double.infinity,
                          height: 150,
                          margin: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/gambar/town_background_cutout.png'), // Ganti dengan path gambar Anda
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Journey'),
                            const SizedBox(height: 13),
                            Wrap(
                              spacing: 16.0,
                              runSpacing: 16.0,
                              children: [
                                _buildMenuItem(context, 'Create', Icons.create),
                                _buildMenuItem(context, 'Renew', Icons.refresh),
                                _buildMenuItem(context, 'Ranks', Icons.star),
                                _buildMenuItem(context, 'Learning', Icons.school),
                                _buildMenuItem(context, 'Post-Test', Icons.assignment),
                                _buildMenuItem(
                                    context, 'Reminder', Icons.alarm), // Menu Reminder
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 250,
                  right: 0,
                  child: Lottie.asset(
                    'assets/lottie/anm_bird.json',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: 250,
                  right: 0,
                  child: Lottie.asset(
                    'assets/lottie/anm_splash.json',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: 230,
                  right: 0,
                  child: Lottie.asset(
                    'assets/lottie/anm_celebration.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: 250,
                  right: 0,
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/gambar/bg_quiz.png'),
                        fit: BoxFit.fill, // Adjust this as needed
                      ),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<Verifikasi?>(
                          future: _userProfileFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return LoadingAnimationWidget.newtonCradle(
                                color: Colors.white,
                                size: 70,
                              );
                            } else if (snapshot.hasData && snapshot.data != null) {
                              final userProfile = snapshot.data!.data;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${userProfile?.name ?? 'N/A'}',
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    userProfile?.corporate == true ? 'Corporate' : 'Individual',
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _showUnauthorizedBottomSheet(context);
                              });

                              return SizedBox.shrink();
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUnauthorizedBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unauthorized Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You are not authorized. Please log in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.offAllNamed(Routes.AUTHENTICATION);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Go to Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _Slider(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: true,
            aspectRatio: 2.7,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: imgList
              .map((item) => Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(item),
                fit: BoxFit.cover,
              ),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 10),
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.map((url) {
              int index = imgList.indexOf(url);
              return Container(
                width: 19.0,
                height: 5.0,
                margin:
                const EdgeInsets.symmetric(vertical: 7.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                  color: _currentIndex == index
                      ? Colors.orange
                      : Colors.grey.shade200,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.bodyText1?.color,
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return SizedBox(
      child: GestureDetector(
        onTap: () async {
          double scorePercentage = 0.0;
          String testType = '';

          final userProfile = await _loadUserProfile();
          final accountStatus = userProfile?.data?.accountStatus ?? -1;
          final postTestScore = double.tryParse(userProfile?.data?.postTestScore ?? "") ?? 0.0;

          if (title == 'Post-Test') {
            if (accountStatus == 2) {
              _showTestInstructions();
            } else {
              _showAccessDeniedForApproval();
            }
          } else if (title == 'Create' || title == 'Renew') {
            testType = 'Post-Test';
            print('Title: $title');
            print('Post-Test Score: ${postTestScore.toStringAsFixed(2)}%');

            if (postTestScore >= 80.0) {
              Get.toNamed(title == 'Create' ? Routes.WebView : Routes.RENEW);
            } else {
              _showAccessDenied(title, testType);
            }
          } else if (title == 'Ranks') {
            _showRanksUnderDevelopment();
          } else if (title == 'Reminder') {
            Get.toNamed(Routes.REMINDER);
          } else if (title == 'Learning') {
            Get.toNamed(Routes.LEARNING);
          }
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              width: 112,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyText1?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTestInstructions() {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      elevation: 0,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/gambar/login_failed.png',
                height: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                'Instruksi untuk Mengakses Menu Test',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Selamat! Status akun Anda telah disetujui, dan Anda sekarang dapat mengakses menu "Post-Test". Pastikan Anda siap untuk menjawab setiap pertanyaan dengan cermat dan teliti. Perhatikan baik-baik setiap instruksi yang diberikan, dan berusahalah sebaik mungkin untuk mencapai hasil terbaik.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Membuat tombol menjadi selebar mungkin
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.TESTPAGE);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccessDeniedForApproval() {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      elevation: 0,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/gambar/login_failed.png', // Update this with your asset path
                height: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                'Akses Ditolak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Anda tidak dapat mengakses menu ini karena status akun Anda belum disetujui.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Membuat tombol menjadi selebar mungkin
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void _showAccessDenied(String menuTitle, String testType) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      elevation: 0,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Akses Ditolak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Anda tidak dapat mengakses menu "$menuTitle" karena hasil $testType Anda di bawah 80%.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Membuat tombol menjadi selebar mungkin
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRanksUnderDevelopment() {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      elevation: 0,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Menu Dalam Pengembangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Menu "Ranks" sedang dalam pengembangan dan belum dapat diakses saat ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
  void _showRanksUnderDevelopmentNotifikasi() {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      elevation: 0,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Menu Dalam Pengembangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Menu "Notifikasi" sedang dalam pengembangan dan belum dapat diakses saat ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }
}
