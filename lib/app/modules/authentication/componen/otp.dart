import 'package:bank_mega/app/modules/authentication/componen/widget/common.dart';
import 'package:bank_mega/app/modules/authentication/componen/widget/custom.dart';
import 'package:bank_mega/app/modules/authentication/componen/widget/fedeanimasi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';
import '../controllers/authentication_controller.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final AuthenticationController controller = Get.find();
  Future<bool> _onWillPop() async {
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white
          ),
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.orange),
                title: Text(
                  'Keluar Dari OTP?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Apakah Anda yakin ingin keluar dari OTP?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Jangan keluar
                    child: Text(
                      'Tidak',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(Routes.AUTHENTICATION);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('Ya', style: TextStyle( color: Colors.white),),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return shouldExit ?? false; // Mengembalikan false jika pengguna menekan di luar BottomSheet
  }
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return WillPopScope(
        onWillPop: () async {
      _onWillPop();
      return true;
    },
    child:
      Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInAnimation(
                      delay: 1.3,
                      child: Text(
                        "OTP Verification",
                        style: Common().titelTheme,
                      ),
                    ),
                    FadeInAnimation(
                      delay: 1.6,
                      child: Text(
                        "Masukkan kode verifikasi yang baru saja kami kirimkan ke alamat email Anda.",
                        style: Common().mediumThemeblack,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInAnimation(
                        delay: 1.9,
                        child: Pinput(
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          validator: (s) {
                            return s == '222222' ? null : 'Pin is incorrect';
                          },
                          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                          controller: controller.OTPController,
                          showCursor: true,
                          onCompleted: (pin) async {
                            await _verifyOtp(pin);
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeInAnimation(
                        delay: 2.1,
                        child: CustomElevatedButton(
                          message: "Verify OTP",
                          function: () async {
                            if (controller.OTPController.text.isNotEmpty) {
                              await _verifyOtp(controller.OTPController.text);
                            } else {
                              Get.snackbar(
                                'Gagal OTP',
                                'Kode OTP Anda salah atau sudah kadaluarsa',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          },
                          color: Colors.orange,
                        ),
                      ),
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

  Future<void> _verifyOtp(String otp) async {
    try {
      String? email = controller.emailController.text;
      final otpResponse = await API.OtpID(email: email, otp: otp);

      print('OTP Response message: ${otpResponse.message}');

      if (otpResponse.message == 'OTP verified successfully') {
        // Perform VerifikasiID call regardless of OTP response
        try {
          final verifikasi = await API.VerifikasiID();

          print('VerifikasiID Response data: ${verifikasi.data}');
          print('VerifikasiID Response message: ${verifikasi.message}');

          if (verifikasi.message == 'Invalid token: Expired') {
            Get.snackbar(
              'Error',
              'Token expired. Please log in again.',
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
          } else {
            if (verifikasi.data != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('external_id', verifikasi.data!.externalId ?? '');

              // Navigate to AuthenticationView with external_id as argument
              Get.offAllNamed(
                Routes.AUTHENTICATION,
                arguments: {'external_id': verifikasi.data!.externalId ?? ''},
              );
            } else {
              Get.snackbar(
                'Failed',
                'Failed to verify OTP',
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
              );
            }
          }
        } catch (e) {
          print('Error during VerifikasiID: $e');
          Get.snackbar(
            'Error',
            'Terjadi kesalahan saat memverifikasi ID',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else if (otpResponse.message == 'Invalid OTP') {
        Get.snackbar(
          'Gagal OTP',
          'Kode OTP Anda salah atau sudah kadaluarsa',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'OTP Berhasil',
          'Anda akan mendapatkan Profile ID untuk login kedalam Aplikasi',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error during OTP verification: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memverifikasi OTP',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
