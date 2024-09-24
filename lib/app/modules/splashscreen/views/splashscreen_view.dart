import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/endpoint.dart';
import '../../../data/localstorage.dart';
import '../../../routes/app_pages.dart';

class SplashscreenView extends StatefulWidget {
  const SplashscreenView({Key? key}) : super(key: key);

  @override
  _SplashscreenViewState createState() => _SplashscreenViewState();
}

class _SplashscreenViewState extends State<SplashscreenView> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastPage = prefs.getString('lastPage');

    if (lastPage == 'OTP') {
      Get.offAllNamed(Routes.OtpVerification); // Arahkan ke halaman OTP jika itu adalah halaman terakhir
    } else {
      // Implementasi logika pengecekan token yang sudah ada
      bool hasToken = await LocalStorages.hasToken();
      if (hasToken) {
        final verifikasi = await API.VerifikasiID();
        if (verifikasi.data?.preTest == true) {
          Get.offAllNamed(Routes.HOME); // Navigate to Home if preTest is true
        } else {
          Get.offAllNamed(Routes.QUIZ); // Navigate to Quiz if preTest is false
        }
      } else {
        Get.offAllNamed(Routes.AUTHENTICATION); // Navigate to Login if token does not exist
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        centerTitle: false,
        title: Text(''),
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: isDarkMode ? Colors.black : Colors.white,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo 1
                Image.asset(
                  'assets/logo/agencyroom.png',
                  height: 40,
                ),
                SizedBox(width: 20), // Space between logos
                // Logo 2
                Image.asset(
                  'assets/logo/mega_insurance.png',
                  height: 40,
                ),
              ],
            ),
            LoadingAnimationWidget.newtonCradle(
              color: isDarkMode ? Colors.white : Colors.orange,
              size: 100,
            ),
          ],
        ),
      ),
    );
  }
}
