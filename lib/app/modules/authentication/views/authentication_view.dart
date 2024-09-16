import 'package:bank_mega/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/data_endpoint/verifikasi.dart';
import '../../../data/endpoint.dart';
import '../../../data/localstorage.dart';

class AuthenticationView extends StatefulWidget {
  const AuthenticationView({super.key});

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  Future<String?>? _externalIdFuture;
  bool _isLoading = false; // Menambahkan state untuk mengelola loading

  @override
  void initState() {
    super.initState();
    // Initialize Future to fetch external ID from local storage or API
    _externalIdFuture = _fetchExternalId();
  }

  Future<String?> _fetchExternalId() async {
    final storage = GetStorage();
    try {
      final verifikasi = await API.VerifikasiID();
      String? externalId = verifikasi.data?.externalId;

      if (externalId != null) {
        storage.write('externalId', externalId);
        return externalId;
      } else {
        externalId = storage.read('externalId');
        print('Using saved local external ID: ${externalId ?? 'empty'}');
        return externalId;
      }
    } catch (e) {
      print('Error fetching external ID: $e');
      return storage.read('externalId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 326,
            child: Image.asset(
              'assets/gambar/town_background_cutout.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(900),
              border: Border.all(color: Colors.orange),
              image: DecorationImage(
                image: AssetImage('assets/gambar/mega.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 400),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 475),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                child: FadeInAnimation(
                                  child: widget,
                                ),
                              ),
                              children: [
                                SizedBox(height: 20),
                                FutureBuilder<String?>(
                                  future: _externalIdFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error loading external ID');
                                    } else {
                                      _emailController.text = snapshot.data ?? '';

                                      return TextFormField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.orange, width: 2.0),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 1, color: Colors.grey)),
                                          labelText: 'Profile Id',
                                          filled: true,
                                          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                          labelStyle: GoogleFonts.nunito(color: isDarkMode ? Colors.white70 : Colors.black54),
                                        ),
                                        keyboardType: TextInputType.text,
                                        style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Colors.black),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                            return 'Enter a valid email';
                                          }
                                          return null;
                                        },
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.orange, width: 2.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
                                    ),
                                    labelText: 'Password',
                                    hintStyle: GoogleFonts.nunito(),
                                    filled: true,
                                    fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                    labelStyle: GoogleFonts.nunito(color: isDarkMode ? Colors.white70 : Colors.black54),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),
                                  style: GoogleFonts.nunito(color: isDarkMode ? Colors.white : Colors.black),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Forgot Password',
                                      style: GoogleFonts.nunito(color: isDarkMode ? Colors.blueAccent : Colors.blue),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : () async {
                                      setState(() {
                                        _isLoading = true; // Menunjukkan status loading
                                      });
                                      HapticFeedback.lightImpact();
                                      if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                                        try {
                                          print("Sending API request with:");
                                          print("Email: ${_emailController.text}");
                                          print("Password: ${_passwordController.text}");

                                          String? token = await API.login(
                                            password: _passwordController.text,
                                            idnumber: _emailController.text,
                                          );

                                          if (token != null) {
                                            final verifikasi = await API.VerifikasiID();

                                            if (verifikasi.data?.preTest == true) {
                                              Get.offAllNamed(Routes.HOME);
                                            } else {
                                              Get.offAllNamed(Routes.QUIZ);
                                            }

                                            print("Login successful, received token: $token");
                                          } else {
                                            Get.snackbar('Error', 'Terjadi kesalahan saat login',
                                                backgroundColor: Colors.redAccent,
                                                colorText: Colors.white);
                                          }
                                        } catch (e) {
                                          print('Error during login: $e');
                                          Get.snackbar('Gagal Login', 'Terjadi kesalahan saat login',
                                              backgroundColor: Colors.redAccent, colorText: Colors.white);
                                        } finally {
                                          setState(() {
                                            _isLoading = false; // Menghentikan loading setelah proses selesai
                                          });
                                        }
                                      } else {
                                        Get.snackbar('Gagal Login', 'Username dan Password harus diisi',
                                            backgroundColor: Colors.redAccent, colorText: Colors.white);
                                        setState(() {
                                          _isLoading = false; // Menghentikan loading jika validasi gagal
                                        });
                                      }
                                    },
                                    child: _isLoading
                                        ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                        : Text(
                                      'Login',
                                      style: GoogleFonts.nunito(fontSize: 18, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDarkMode ? Colors.orangeAccent : Colors.orange,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    'Don\'t have an account?',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Get.toNamed(Routes.RegistrationStepper),
                  child: Text(
                    'Register Now',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.blueAccent : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

