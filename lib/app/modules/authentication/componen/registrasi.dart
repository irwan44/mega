import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/data_endpoint/Salutations.dart';
import '../../../data/data_endpoint/area.dart';
import '../../../data/data_endpoint/bank.dart';
import '../../../data/data_endpoint/curency.dart';
import '../../../data/data_endpoint/provinsi.dart';
import '../../../data/data_endpoint/registrasi.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';
import '../controllers/authentication_controller.dart';

class RegistrationStepper extends StatefulWidget {
  const RegistrationStepper({super.key});

  @override
  State<RegistrationStepper> createState() => _RegistrationStepperState();
}

class _RegistrationStepperState extends State<RegistrationStepper> {

  @override
  void initState() {
    super.initState();
  }
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
                  'Keluar Dari Registrasi?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Apakah Anda yakin ingin keluar dari Registrasi?'),
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
    return shouldExit ?? false;
  }
  @override
  void dispose() {
    super.dispose();
    LocalStorage.clearValue('selectedSalutation');
    LocalStorage.clearValue('selectedCurrency');
    LocalStorage.clearValue('selectedProvince');
    LocalStorage.clearValue('selectedCity');
    LocalStorage.clearValue('selectedBank');
    LocalStorage.clearValue('selectedCurrency');
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationController controller = Get.put(AuthenticationController());

    return WillPopScope(
        onWillPop: () async {
          _onWillPop();
      return true;
    },
    child: Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text('Registration', style: GoogleFonts.nunito()),
      ),
      body: Obx(() {
        return Column(
          children: [
            SizedBox(height: 10,),
            _buildStepperHeader(controller),
            Expanded(
              child: IndexedStack(
                index: controller.currentStep.value,
                children: [
                  _buildStep1Form(controller),
                  _buildStep2Form(controller),
                  _buildStep3Form(controller),
                ].whereType<Widget>().toList(),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: Row(
          children: [
            if (controller.currentStep.value > 0)
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  controller.previousStep();
                },
              ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.currentStep.value < 2 ? Colors.blue : Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
                onPressed: () async {
                  if (controller.currentStep.value < 2) {
                    controller.nextStep();
                  } else {
                    HapticFeedback.lightImpact();

                    // Check if all forms are valid
                    if (controller.formKey1.currentState?.validate() == true &&
                        controller.formKey2.currentState?.validate() == true &&
                        controller.formKey3.currentState?.validate() == true) {
                      try {
                        // Check for any empty required fields
                        List<String> emptyFields = [];

                        // Validate fields
                        if (controller.nameController.text.isEmpty) emptyFields.add('Name');
                        if (controller.addressController.text.isEmpty) emptyFields.add('Address');
                        if (controller.selectedDate.value == null) emptyFields.add('Date of Birth');
                        if (controller.placeOfBirthController.text.isEmpty) emptyFields.add('Place of Birth');
                        if (controller.emailController.text.isEmpty) emptyFields.add('Email');
                        if (controller.civilIdCard.value == null) emptyFields.add('Civil ID Card');
                        if (controller.taxIdCard.value == null) emptyFields.add('Tax ID Card');
                        if (controller.licenseAaui.value == null) emptyFields.add('License AAUI');
                        if (controller.savingBook.value == null) emptyFields.add('Saving Book');
                        if (controller.profilePicture.value == null) emptyFields.add('Profile Picture');

                        // If there are empty fields, show an error message
                        if (emptyFields.isNotEmpty) {
                          Get.snackbar(
                            'Gagal Registrasi',
                            'Semua bidang harus diisi: ${emptyFields.join(', ')}',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return; // Exit the function if there are empty fields
                        }

                        // Cek jika siup masih null, gunakan file default
                        if (controller.siup.value == null) {
                          await controller.loadDefaultSiup(); // Panggil fungsi untuk memuat file default
                        }

                        // Prepare data for API request
                        String dateOfBirth = DateFormat('yyyy-MM-dd').format(controller.selectedDate.value ?? DateTime.now());

                        // Print values being sent to the API
                        Map<String, dynamic> requestBody = {
                          'name': controller.nameController.text,
                          'address': controller.addressController.text,
                          'place_of_birth': controller.placeOfBirthController.text,
                          'date_of_birth': dateOfBirth,
                          'phone_number': controller.phoneNumberController.text,
                          'email': controller.emailController.text,
                          'bank_account_name': controller.bankAccountNameController.text,
                          'bank_account_number': controller.bankAccountNumberController.text,
                          'bank_code': controller.selectedBank.value ?? '',
                          'bank_name': controller.selectedBankName.value ?? '',
                          'bank_currency': controller.selectedCurency.value ?? '',
                          'civil_id': controller.civilIdController.text,
                          'tax_id': controller.taxIdController.text,
                          'corporate': controller.selectedType.value ?? '',
                          'salutation': controller.selectedSalutation.value ?? '',
                          'zip_code': controller.zipCodeController.text,
                          'province': controller.selectedProvince.value ?? '',
                          'city': controller.selectedCity.value ?? '',
                          'pic': controller.PicController.text,
                          'gender': controller.selectedGender.value ?? '',
                          'license_number': controller.licenseNumberController.text,
                          'password': controller.passwordController.text,
                          'password_confirmation': controller.passwordConfirmationController.text,

                        };

                        print('Sending the following request body to the API:');
                        print(jsonEncode(requestBody));

                        controller.isLoading.value = true;

                        // Call the API
                        Registrasi? registrationResponse = await API.RegisterID(
                          name: controller.nameController.text,
                          address: controller.addressController.text,
                          place_of_birth: controller.placeOfBirthController.text,
                          date_of_birth: dateOfBirth,
                          phone_number: controller.phoneNumberController.text,
                          email: controller.emailController.text,
                          bank_account_name: controller.bankAccountNameController.text,
                          bank_account_number: controller.bankAccountNumberController.text,
                          bank_code: controller.selectedBank.value ?? '',
                          bank_name: controller.selectedBankName.value ?? '',
                          bank_currency: controller.selectedCurency.value ?? '',
                          civil_id: controller.civilIdController.text,
                          tax_id: controller.taxIdController.text,
                          corporate: controller.selectedType.value ?? '',
                          salutation: controller.selectedSalutation.value ?? '',
                          zip_code: controller.zipCodeController.text,
                          province: controller.selectedProvince.value ?? '',
                          city: controller.selectedCity.value ?? '',
                          pic: controller.PicController.text,
                          gender: controller.selectedGender.value ?? '',
                          license_number: controller.licenseNumberController.text,
                          password: controller.passwordController.text,
                          password_confirmation: controller.passwordConfirmationController.text,
                          civil_id_card: controller.civilIdCard.value,
                          tax_id_card: controller.taxIdCard.value,
                          license_aaui: controller.licenseAaui.value,
                          saving_book: controller.savingBook.value,
                          siup: controller.siup.value,
                          profile_picture: controller.profilePicture.value,
                        );

                        // Handle response
                        if (registrationResponse != null && registrationResponse.data != null) {
                          String token = registrationResponse.data!.token ?? '';
                          print("Registration successful, received token: $token");
                          Get.offAllNamed(Routes.AUTHENTICATION);
                        } else {
                          // Get.snackbar(
                          //   'Registration Failed',
                          //   'An unexpected error occurred. Please try again.',
                          //   backgroundColor: Colors.redAccent,
                          //   colorText: Colors.white,
                          // );
                        }
                      } catch (e) {
                        print('Error during registration: $e');
                        Get.snackbar(
                          'Form Error',
                          '$e',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      } finally {
                        controller.isLoading.value = false;
                      }
                    } else {
                      // Get.snackbar(
                      //   'Form Error',
                      //   'Please fill all the required forms correctly.',
                      //   backgroundColor: Colors.redAccent,
                      //   colorText: Colors.white,
                      // );
                    }
                  }
                },
                child: Obx(() {
                if (controller.isLoading.value) {
                  return LoadingAnimationWidget.newtonCradle(
                    color: Colors.white,
                    size: 100,
                  );
                } else {
                  return Text(
                    controller.currentStep.value < 2 ? 'Next' : 'Submit',
                    style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }
              }),
            ),
          ],
        ),
      )
    ),
    ),
    );
  }

  Widget _buildStepperHeader(AuthenticationController controller) {
    List<String> stepTitles = ['Personal', 'Address', 'Bank'];

    return Container(
      height: 60,
      width: 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(stepTitles.length, (index) {
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: controller.currentStep.value == index ? Colors.orange : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                stepTitles[index],
                style: GoogleFonts.nunito(
                  color: controller.currentStep.value == index ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1Form(AuthenticationController controller) {
    return Form(
      key: controller.formKey1,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.nameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Full Name',
                labelStyle: GoogleFonts.nunito(),
                alignLabelWithHint: true, // Menyelaraskan label dengan hint
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0), // Atur padding agar pesan sejajar dengan hint
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name'; // Pesan kesalahan
                }
                return null;
              },
            ),
          ),

          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.passwordController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.password_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Password',
                labelStyle: GoogleFonts.nunito(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    controller.obscurePassword.value = !controller.obscurePassword.value;
                  },
                ),
              ),
              obscureText: controller.obscurePassword.value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: controller.passwordConfirmationController,
              style: GoogleFonts.nunito(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.password_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Confirmation Password',
                labelStyle: GoogleFonts.nunito(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureConfirmationPassword.value ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    controller.obscureConfirmationPassword.value = !controller.obscureConfirmationPassword.value;
                  },
                ),
              ),
              obscureText: controller.obscureConfirmationPassword.value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Confirmation Password';
                }
                if (value != controller.passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.birthController,
              readOnly: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.calendar_month_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Date of Birth',
                labelStyle: GoogleFonts.nunito(),
                hintStyle: GoogleFonts.nunito(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                hintText: controller.selectedDate.value == null
                    ? 'Select Date of Birth'
                    : DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!),
              ),
              onTap: () => controller.selectDate(DateTime.now()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Date of Birth';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.placeOfBirthController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.maps_home_work_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: ' Place of birth',
                labelStyle: GoogleFonts.nunito(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Place of birth';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 20, bottom: 10, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.orange),
                    SizedBox(width: 15), // Spacing between icon and dropdown
                    Expanded(
                      child: FutureBuilder<Salutations>(
                        future: API.SalutationsID(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: LoadingAnimationWidget.newtonCradle(
                                color: Colors.orange,
                                size: 100,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.data == null ||
                              snapshot.data!.data!.isEmpty) {
                            return Center(child: Text('No data available'));
                          } else {
                            // Safely extract the data
                            List<String> salutationList = snapshot.data!.data!;
                            print("Salutation List: $salutationList");

                            // Load the saved value from local storage
                            return FutureBuilder<String?>(
                              future: LocalStorage.getSelectedSalutation(),
                              builder: (context, savedSnapshot) {
                                String? savedValue = savedSnapshot.data;

                                return DropdownButtonFormField<String>(
                                  value: savedValue,
                                  hint: Text('Select Salutation',
                                      style: GoogleFonts.nunito()),
                                  items: salutationList.map((salutation) {
                                    return DropdownMenuItem<String>(
                                      value: salutation,
                                      child: Text(salutation,
                                          style: GoogleFonts.nunito()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.selectedSalutation.value = value;
                                      LocalStorage.saveSelectedSalutation(
                                          value); // Save the selected value
                                      print(
                                          "Selected Salutation: ${controller.selectedSalutation.value}");
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return ''; // Pesan kesalahan ditampilkan secara manual
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // Remove the default border
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  // Menampilkan pesan error jika validasi gagal
                  return controller.selectedSalutation.value == null
                      ? Padding(
                    padding: const EdgeInsets.only(left: 1.0), // Sejajarkan dengan ikon
                    child: Text(
                      'Please select a Salutation',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  )
                      : SizedBox.shrink();
                }),
              ],
            ),
          ),

          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 20, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gender', style: GoogleFonts.nunito()),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('Male', style: GoogleFonts.nunito()),
                        leading: Radio<String>(
                          value: 'Male',
                          groupValue: controller.selectedGender.value,
                          onChanged: (value) {
                            controller.selectedGender.value = value;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('Female', style: GoogleFonts.nunito()),
                        leading: Radio<String>(
                          value: 'Female',
                          groupValue: controller.selectedGender.value,
                          onChanged: (value) {
                            controller.selectedGender.value = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  // Menampilkan pesan error jika tidak ada gender yang dipilih
                  return controller.selectedGender.value == null
                      ? Text(
                    'Please select a Gender',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )
                      : SizedBox.shrink();
                }),
              ],
            ),
          ),

    SizedBox(
        height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.alternate_email_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Email',
                labelStyle: GoogleFonts.nunito(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Phone Number';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.phoneNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone_android_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Phone Number',
                labelStyle: GoogleFonts.nunito(),
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Phone Number';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 20, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Type', style: GoogleFonts.nunito()),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('Individual', style: GoogleFonts.nunito()),
                        leading: Radio<String>(
                          value: '0', // Send 0 for Individual
                          groupValue: controller.selectedType.value,
                          onChanged: (value) {
                            controller.selectedType.value = value ?? '0'; // Default to '0'
                            print("Individual : ${controller.selectedType.value}");
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('Corporate', style: GoogleFonts.nunito()),
                        leading: Radio<String>(
                          value: '1',
                          groupValue: controller.selectedType.value,
                          onChanged: (value) {
                            controller.selectedType.value = value ?? '1';
                            print("Corporate : ${controller.selectedType.value}");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  // Menampilkan pesan error jika tidak ada gender yang dipilih
                  return controller.selectedType.value == null
                      ? Text(
                    'Please select an Account Type',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )
                      : SizedBox.shrink();
                }),
                Obx(() {
                  return Visibility(
                    visible: controller.selectedType.value == '1',
                    child: TextField(
                      controller: controller.PicController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.orange),
                        border: InputBorder.none,
                        labelText: 'PIC',
                        labelStyle: GoogleFonts.nunito(),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

    ],
      ),
    );
  }

  Widget _buildStep2Form(AuthenticationController controller) {
    return Form(
      key: controller.formKey2,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            padding: EdgeInsets.only(left: 14, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.addressController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.map_sharp, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Address',
                labelStyle: GoogleFonts.nunito(),
                alignLabelWithHint: true, // Menyelaraskan label dengan hint
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0), // Atur padding agar pesan sejajar dengan hint
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Address'; // Pesan kesalahan
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 20, bottom: 10, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_city_rounded, color: Colors.orange),
                    SizedBox(width: 15),
                    Expanded(
                      child: FutureBuilder<Provinsi>(
                        future: API.Provincesid(), // Fetch province data
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: LoadingAnimationWidget.newtonCradle(
                                color: Colors.orange,
                                size: 100,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.data == null ||
                              snapshot.data!.data!.isEmpty) {
                            return Center(child: Text('No data available'));
                          } else {
                            // Extract the province data from the dictionary
                            Map<String, String> provinceMap = snapshot.data!.data!;
                            List<MapEntry<String, String>> provinceEntries = provinceMap.entries.toList();

                            // Print to debug
                            print("Province Map: $provinceMap");

                            return FutureBuilder<String?>(
                              future: LocalStorage.getSelectedCity(), // Fetch saved province code
                              builder: (context, savedSnapshot) {
                                String? savedValue = savedSnapshot.data;

                                // Print to debug
                                print("Saved Province Code: $savedValue");

                                // Check if savedValue is in provinceMap.keys
                                if (savedValue != null &&
                                    !provinceMap.containsKey(savedValue)) {
                                  print("Warning: Saved Province Code not found in provinceMap");
                                  savedValue = null; // Reset if not found
                                }

                                return DropdownButtonFormField<String>(
                                  value: savedValue, // Set the selected value
                                  hint: Text('Select Province', style: GoogleFonts.nunito()),
                                  items: provinceEntries.map((entry) {
                                    // Print each entry to debug
                                    print("Dropdown Item: ${entry.key} - ${entry.value}");

                                    return DropdownMenuItem<String>(
                                      value: entry.key, // Use province code as the value
                                      child: Text(
                                        entry.value, // Display the full province name
                                        style: GoogleFonts.nunito(),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.selectedProvince.value = value;
                                      LocalStorage.saveSelectedCity(value); // Save the selected province code
                                      print(
                                          "Selected Province Code: ${controller.selectedProvince.value}");
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return ''; // Return an empty string since we're handling validation manually
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // Remove default border
                                  ),
                                  isExpanded: true, // Make dropdown take full width
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  return controller.selectedProvince.value == null
                      ? Padding(
                    padding: const EdgeInsets.only(left: 1.0), // Align with the icon
                    child: Text(
                      'Please select a Province',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  )
                      : SizedBox.shrink();
                }),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 20, bottom: 10, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_city_rounded, color: Colors.orange),
                    SizedBox(width: 15),
                    Expanded(
                      child: FutureBuilder<Area>(
                        future: API.AreasID(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: LoadingAnimationWidget.newtonCradle(
                                color: Colors.orange,
                                size: 100,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.data == null || snapshot.data!.data!.isEmpty) {
                            return Center(child: Text('No data available'));
                          } else {
                            // Extract the area data from the dictionary
                            Map<String, String> areaMap = snapshot.data!.data!;
                            List<String> areaIDs = areaMap.keys.toList();

                            return FutureBuilder<String?>(
                              future: LocalStorage.getSelectedProvince(),
                              builder: (context, savedSnapshot) {
                                String? savedID = savedSnapshot.data;

                                return DropdownButtonFormField<String>(
                                  value: savedID,
                                  hint: Text('Select City', style: GoogleFonts.nunito()),
                                  items: areaIDs.map((id) {
                                    return DropdownMenuItem<String>(
                                      value: id,
                                      child: Text(areaMap[id]!, style: GoogleFonts.nunito()), // Display the name
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.selectedCity.value = value;
                                      LocalStorage.saveSelectedProvince(value); // Save the selected ID
                                      print("Selected City ID: ${controller.selectedCity.value}");
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return ''; // Return empty string to handle validation manually
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // Remove the default border
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  return controller.selectedCity.value == null
                      ? Padding(
                    padding: const EdgeInsets.only(left: 1.0), // Align with the icon
                    child: Text(
                      'Please select a City',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  )
                      : SizedBox.shrink();
                }),
              ],
            ),
          ),

          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 14, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.zipCodeController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.map_sharp, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Zip Code',
                labelStyle: GoogleFonts.nunito(),
                alignLabelWithHint: true, // Menyelaraskan label dengan hint
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0), // Atur padding agar pesan sejajar dengan hint
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid Zip Code'; // Pesan kesalahan
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 14, bottom: 10, top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.licenseNumberController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.map_sharp, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'License Number',
                labelStyle: GoogleFonts.nunito(),
                alignLabelWithHint: true, // Menyelaraskan label dengan hint
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0), // Atur padding agar pesan sejajar dengan hint
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid License Number'; // Pesan kesalahan
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 14, bottom: 10, top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.civilIdController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.credit_card_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'NIK / Civil ID',
                labelStyle: GoogleFonts.nunito(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
              keyboardType: TextInputType.number,
              maxLength: 16, // Limits the input to 16 characters
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allows only digits
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid NIK / Civil ID';
                }
                if (value.length != 16) {
                  return 'NIK / Civil ID must be 16 characters long';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 14, bottom: 10, top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.taxIdController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.credit_card_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'NPWP / TaxID',
                labelStyle: GoogleFonts.nunito(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
              keyboardType: TextInputType.number,
              maxLength: 16, // Limits the input to 16 characters
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allows only digits
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid NPWP / TaxID';
                }
                if (value.length != 16) {
                  return 'NPWP / TaxID must be 16 characters long';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Form(AuthenticationController controller) {
    return Form(
      key: controller.formKey3,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, bottom: 10, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on_outlined, color: Colors.orange),
                SizedBox(width: 15),
                Expanded(
                  child: FutureBuilder<Currency>(
                    future: API.CurrencyID(), // Fetch currency data
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: LoadingAnimationWidget.newtonCradle(
                            color: Colors.orange,
                            size: 100,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.data == null || snapshot.data!.data!.isEmpty) {
                        return Center(child: Text('No data available'));
                      } else {

                        Map<String, String> currencyMap = snapshot.data!.data!;
                        List<MapEntry<String, String>> currencyEntries = currencyMap.entries.toList();

                        print("Currency Map: $currencyMap");

                        return FutureBuilder<String?>(
                          future: LocalStorage.getSelectedCurrency(),
                          builder: (context, savedSnapshot) {
                            String? savedValue = savedSnapshot.data;

                            print("Saved Currency Code: $savedValue");


                            if (savedValue != null && !currencyMap.containsKey(savedValue)) {
                              print("Warning: Saved Currency Code not found in currencyMap");
                              savedValue = null;
                            }

                            return DropdownButtonFormField<String>(
                              value: savedValue,
                              hint: Text('Select Currency', style: GoogleFonts.nunito()),
                              items: currencyEntries.map((entry) {
                                // Print each entry to debug
                                print("Dropdown Item: ${entry.key} - ${entry.value}");

                                return DropdownMenuItem<String>(
                                  value: entry.key, // Use currency code as the value
                                  child: Text(
                                    entry.value, // Display the full currency name
                                    style: GoogleFonts.nunito(),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedCurency.value = value;
                                  LocalStorage.saveSelectedCurrency(value); // Save the selected currency code
                                  print("Selected Currency Code: ${controller.selectedCurency.value}");
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a Currency';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none, // Remove default border
                              ),
                              isExpanded: true, // Make dropdown take full width
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 20, bottom: 10, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: Colors.orange),
                SizedBox(width: 15),
                Expanded(
                  child: FutureBuilder<Bank>(
                    future: API.BankID(), // Fetch bank data
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: LoadingAnimationWidget.newtonCradle(
                            color: Colors.orange,
                            size: 100,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.data == null || snapshot.data!.data!.isEmpty) {
                        return Center(child: Text('No data available'));
                      } else {
                        // Extract the bank data from the dictionary
                        Map<String, String> bankMap = snapshot.data!.data!;
                        List<MapEntry<String, String>> bankEntries = bankMap.entries.toList();

                        // Print to debug
                        print("Bank Map: $bankMap");

                        return FutureBuilder<String?>(
                          future: LocalStorage.getSelectedBank(), // Fetch saved bank ID
                          builder: (context, savedSnapshot) {
                            String? savedID2 = savedSnapshot.data;

                            // Print to debug
                            print("Saved Bank ID: $savedID2");

                            // Check if savedID2 is in bankMap.keys
                            if (savedID2 != null && !bankMap.containsKey(savedID2)) {
                              print("Warning: Saved Bank ID not found in bankMap");
                              savedID2 = null; // Reset if not found
                            }

                            return DropdownButtonFormField<String>(
                              value: savedID2, // Set the selected value
                              hint: Text('Select Bank', style: GoogleFonts.nunito()),
                              items: bankEntries.map((entry) {
                                // Print each entry to debug
                                print("Dropdown Item: ${entry.key} - ${entry.value}");

                                return DropdownMenuItem<String>(
                                  value: entry.key, // Use bank ID as the value
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7, // Limit width
                                    ),
                                    child: Text(
                                      entry.value, // Display bank name
                                      style: GoogleFonts.nunito(),
                                      overflow: TextOverflow.ellipsis, // Handle long text
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  // Find the bank name corresponding to the selected ID
                                  String? selectedBankName = bankMap[value];
                                  controller.selectedBank.value = value; // Save selected bank ID
                                  controller.selectedBankName.value = selectedBankName ?? ''; // Save selected bank name
                                  LocalStorage.saveSelectedBank(value); // Save the selected bank ID
                                  print("Selected Bank ID: ${controller.selectedBank.value}");
                                  print("Selected Bank Name: ${controller.selectedBankName.value}");
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a Bank';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none, // Remove default border
                              ),
                              isExpanded: true, // Make dropdown take full width
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 14, bottom: 10, top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.bankAccountNumberController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.comment_bank_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Bank Account',
                labelStyle: GoogleFonts.nunito(),
                alignLabelWithHint: true, // Menyelaraskan label dengan hint
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0), // Atur padding agar pesan sejajar dengan hint
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid Bank Account'; // Pesan kesalahan
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 14, bottom: 10, top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.bankAccountNameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.comment_bank_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Bank Account Holder',
                labelStyle: GoogleFonts.nunito(),
                alignLabelWithHint: true, // Menyelaraskan label dengan hint
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0), // Atur padding agar pesan sejajar dengan hint
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid Bank Account Holder'; // Pesan kesalahan
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          _buildImageUploadSection(controller),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(AuthenticationController controller) {
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageUploadField(
            controller: controller,
            fieldName: 'civilIdCard',
            label: 'Photo KTP / Civil ID',
            imageFile: controller.civilIdCard,
          ),
          _buildImageUploadField(
            controller: controller,
            fieldName: 'taxIdCard',
            label: 'Photo NPWP / Tax ID',
            imageFile: controller.taxIdCard,
          ),
          _buildImageUploadField(
            controller: controller,
            fieldName: 'savingBook',
            label: 'Photo Buku / Saving Book',
            imageFile: controller.savingBook,
          ),
          _buildImageUploadField(
            controller: controller,
            fieldName: 'licenseAaui',
            label: 'Photo License / License Certificate',
            imageFile: controller.licenseAaui,
          ),
          if (controller.selectedType.value == '1')
            _buildImageUploadField(
              controller: controller,
              fieldName: 'siup',
              label: 'Upload Business Permit',
              imageFile: controller.siup,
            ),
          _buildImageUploadField(
            controller: controller,
            fieldName: 'profilePicture',
            label: 'Profile Picture',
            imageFile: controller.profilePicture,
          ),
        ],
      );
    });
  }

  Widget _buildImageUploadField({
    required AuthenticationController controller,
    required String fieldName,
    required String label,
    required Rx<File?> imageFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(),
        ),
        GestureDetector(
          onTap: () {
            if (fieldName == 'profilePicture') {
              // Directly open the camera for profile picture
              controller.pickImage(ImageSource.camera, fieldName);
            } else {
              // Show the file source dialog for other fields
              controller.showImageSourceDialog(fieldName);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Obx(() {
                    if (imageFile.value != null) {
                      return _buildFilePreview(imageFile.value!, controller);
                    } else {
                      return Icon(
                        Icons.camera_alt,
                        size: 100,
                        color: Colors.grey,
                      );
                    }
                  }),
                  const SizedBox(height: 8),
                  Text(
                    imageFile.value != null ? 'Change File' : 'Upload File',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }


  Widget _buildFilePreview(File file, AuthenticationController controller) {
    if (file.path.endsWith('.pdf')) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 100,
            color: Colors.red,
          ),
          SizedBox(height: 10),
          Text(
            'PDF File Selected',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else {
      // Display the image preview for non-PDF files
      return Image.file(
        file,
        width: 300,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  Future<PdfPageImage?> renderPdfPage(File file) async {
    try {
      final pdfDocument = await PdfDocument.openFile(file.path);
      final page = await pdfDocument.getPage(1);

      final pageImage = await page.render(
        width: page.width.toInt(),
        height: page.height.toInt(),
      );

      return pageImage;
    } catch (e) {
      print('Error rendering PDF page: $e');
      return null;
    }
  }
}

class LocalStorage {
  static Future<void> saveValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> saveSelectedBank(String bank) async {
    await saveValue('selectedBank', bank);
  }

  static Future<String?> getSelectedBank() async {
    return getValue('selectedBank');
  }

  static Future<void> saveSelectedCurrency(String currency) async {
    await saveValue('selectedCurrency', currency);
  }

  static Future<String?> getSelectedCurrency() async {
    return getValue('selectedCurrency');
  }

  static Future<void> saveSelectedProvince(String province) async {
    await saveValue('selectedProvince', province);
  }

  static Future<String?> getSelectedProvince() async {
    return getValue('selectedProvince');
  }

  static Future<void> saveSelectedCity(String city) async {
    await saveValue('selectedCity', city);
  }

  static Future<String?> getSelectedCity() async {
    return getValue('selectedCity');
  }

  static Future<void> saveSelectedSalutation(String salutation) async {
    await saveValue('selectedSalutation', salutation);
  }

  static Future<String?> getSelectedSalutation() async {
    return getValue('selectedSalutation');
  }

  // Method to clear a specific value
  static Future<void> clearValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
