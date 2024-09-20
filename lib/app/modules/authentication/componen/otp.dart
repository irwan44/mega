import 'dart:async'; // Tambahkan ini untuk menggunakan Timer
import 'package:bank_mega/app/modules/authentication/componen/widget/custom.dart';
import 'package:bank_mega/app/modules/authentication/componen/widget/fedeanimasi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/data_endpoint/verifikasi.dart';
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
  bool isButtonDisabled = false;
  int remainingSeconds = 0;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      isButtonDisabled = true;
      remainingSeconds = 60;
    });

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
      });

      if (remainingSeconds == 0) {
        setState(() {
          isButtonDisabled = false;
        });
        timer.cancel();
      }
    });
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
    Future<bool> _onWillPop() async {
      final shouldExit = await showModalBottomSheet<bool>(
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            padding: EdgeInsets.all(16),
            child: Wrap(
              children: [
                const ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.orange),
                  title: Text(
                    'Keluar Dari OTP?',
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Apakah Anda yakin ingin keluar dari OTP?'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      // Jangan keluar
                      child: const Text(
                        'Tidak',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        SystemNavigator.pop(); // Keluar dari aplikasi
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text('Ya', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
      return shouldExit ??
          false; // Mengembalikan false jika pengguna menekan di luar BottomSheet
    }
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return true;
      },
      child:
      Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _onWillPop();
            },
          ),
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
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "OTP Verification",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Masukkan kode verifikasi yang baru saja kami kirimkan ke alamat email Anda.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
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
                        Pinput(
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          validator: (s) {
                            return s?.isNotEmpty == true
                                ? null
                                : 'Kode OTP tidak boleh kosong';
                          },
                          pinputAutovalidateMode: PinputAutovalidateMode
                              .onSubmit,
                          controller: controller.OTPController,
                          showCursor: true,
                          onCompleted: (pin) async {
                            await _verifyOtp(pin);
                          },
                        ),
                        const SizedBox(height: 30),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Jika tidak menerima OTP'),
                                  SizedBox(width: 10,),
                                  FadeInAnimation(
                                    delay: 2.1,
                                    child: SizedBox(
                                      width: 170,
                                      height: 45,
                                      child:
                                      ElevatedButton(
                                        onPressed: isButtonDisabled
                                            ? null
                                            : () async {
                                          await _sendOtp();
                                          _startTimer();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isButtonDisabled
                                              ? Colors.grey
                                              : Colors.blue,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 15),
                                          textStyle: TextStyle(fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        child: Text(isButtonDisabled
                                            ? 'Tunggu $remainingSeconds detik'
                                            : "Send OTP",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10),),

                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        FadeInAnimation(
                          delay: 2.1,
                          child: SizedBox(
                            width: double.infinity,
                            child:
                            ElevatedButton(
                              onPressed: () async {
                                final otp = controller.OTPController.text;
                                if (otp.isNotEmpty) {
                                  await _verifyOtp(otp);
                                } else {
                                  Get.snackbar(
                                    'Gagal OTP',
                                    'Kode OTP Anda salah atau sudah kadaluarsa',
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              child: Text("Verify OTP",
                                style: GoogleFonts.nunito(color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10),),
                            ),
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

  Future<void> _sendOtp() async {
    try {
      final String email = controller.emailController.text;
      final verifikasi = await API.VerifikasiregisID();
      if (verifikasi.data != null && verifikasi.data!.userId != null) {
        final otpResponse = await API.sendOtpID(
          email: email,
          app: 'Agency Room',
          userid: verifikasi.data!.userId.toString(),
          createdby: 'system',
        );
        print('${email}');
        print('${verifikasi.data!.userId.toString()}');
        print('OTP Response message: ${otpResponse.message}');
      } else {
        print('Error: User ID tidak ditemukan dalam respons verifikasi.');
      }
    } catch (e) {
      print('Error saat mengirim OTP: $e');
    }
  }

  Future<void> _verifyOtp(String otp) async {
    try {
      final String email = controller.emailController.text;
      final otpResponse = await API.OtpID(email: email, otp: otp);
        print('${email}');
        print('${otp}');
      if (otpResponse.message == 'OTP verified successfully') {
        Get.snackbar(
          'OTP Berhasil',
          'Verifikasi berhasil. Anda akan diarahkan ke halaman berikutnya.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.toNamed(Routes.AUTHENTICATION);
        await _handleVerifikasiResponse();
      } else {
        Get.snackbar(
          'Gagal OTP',
          otpResponse.message ?? 'Pesan tidak tersedia',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Tangani kesalahan yang tidak terduga
      print('Error during OTP verification: $e');
      print(controller.emailloginController.text);
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memverifikasi OTP',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }


  Future<void> _handleVerifikasiResponse() async {
    try {
      final verifikasi = await API.VerifikasiregisID();

      if (verifikasi.message == 'Invalid token: Expired') {
        Get.snackbar(
          'Error',
          'Token expired. Please log in again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } else if (verifikasi.data != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('external_id', verifikasi.data!.externalId ?? '');

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
    } catch (e) {
      print('Error during VerifikasiID: $e');
      print(controller.emailloginController.text);
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memverifikasi ID',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}