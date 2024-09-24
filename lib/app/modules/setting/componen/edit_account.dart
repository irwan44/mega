import 'dart:ffi';
import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/data_endpoint/Salutations.dart';
import '../../../data/data_endpoint/area.dart';
import '../../../data/data_endpoint/bank.dart';
import '../../../data/data_endpoint/curency.dart';
import '../../../data/data_endpoint/provinsi.dart';
import '../../../data/data_endpoint/verifikasi.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';
import '../controllers/setting_controller.dart';

class EditAccount extends StatefulWidget {
  const EditAccount({super.key});

  @override
  State<EditAccount> createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {

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
            color: Colors.white,
          ),
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.orange),
                title: Text(
                  'Keluar Dari Edit Account?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'Apakah Anda yakin ingin keluar dari Edit Account?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    // Jangan keluar
                    child: Text(
                      'Tidak',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(Routes.HOME);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(
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
    return shouldExit ??
        false; // Mengembalikan false jika pengguna menekan di luar BottomSheet
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
    final SettingController controller = Get.put(SettingController());

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
          title: Text('Edit Account', style: GoogleFonts.nunito()),
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
        bottomNavigationBar: Obx(() =>
            BottomAppBar(
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
                      backgroundColor: controller.currentStep.value < 2 ? Colors
                          .blue : Colors.green,
                      padding: EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                    ),
                    onPressed: () async {
                      if (controller.currentStep.value < 2) {
                        controller.nextStep();
                      } else {
                        HapticFeedback.lightImpact();

                        // Perform all form validations before showing alert
                        if (controller.formKey1.currentState?.validate() ==
                            true &&
                            controller.formKey2.currentState?.validate() ==
                                true &&
                            controller.formKey3.currentState?.validate() ==
                                true) {
                          List<String> emptyFields = [];

                          // Check if text fields are empty
                          if (controller.nameController.text
                              .trim()
                              .isEmpty) emptyFields.add('Name');
                          if (controller.addressController.text
                              .trim()
                              .isEmpty) emptyFields.add('Address');
                          if (controller.selectedDate.value == null) emptyFields
                              .add('Date of Birth');
                          if (controller.placeOfBirthController.text
                              .trim()
                              .isEmpty) emptyFields.add('Place of Birth');
                          if (controller.emailController.text
                              .trim()
                              .isEmpty) emptyFields.add('Email');

                          // Check for file uploads; ensure both local files and network URLs are considered
                          if (controller.civilIdCard.value == null && controller
                              .userProfile.value?.data?.attCivilid == null) {
                            emptyFields.add('Civil ID Card');
                          }
                          if (controller.taxIdCard.value == null && controller
                              .userProfile.value?.data?.attTaxid == null) {
                            emptyFields.add('Tax ID Card');
                          }
                          if (controller.licenseAaui.value == null && controller
                              .userProfile.value?.data?.attLicense == null) {
                            emptyFields.add('License AAUI');
                          }
                          if (controller.savingBook.value == null && controller
                              .userProfile.value?.data?.attSaving == null) {
                            emptyFields.add('Saving Book');
                          }
                          if (controller.profilePicture.value == null &&
                              controller.userProfile.value?.data?.attProfile ==
                                  null) {
                            emptyFields.add('Profile Picture');
                          }

                          // If any fields are empty, show the error and return early
                          if (emptyFields.isNotEmpty) {
                            Get.snackbar(
                              'Gagal Registrasi',
                              'Semua bidang harus diisi: ${emptyFields.join(
                                  ', ')}',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          // If all fields are validated and filled, show the alert
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Perhatian Penting!',
                            text: 'Pastikan untuk memeriksa dan menyimpan data akun yang telah diubah sebelum meninggalkan halaman ini. Apakah Anda yakin ingin melanjutkan?',
                            confirmBtnText: 'Simpan Perubahan',
                            cancelBtnText: 'Keluar',
                            confirmBtnColor: Colors.green,
                            onConfirmBtnTap: () async {
                              try {
                                controller.isLoading.value = true;
                                String dateOfBirth = DateFormat('yyyy-MM-dd')
                                    .format(controller.selectedDate.value ??
                                    DateTime.now());

                                String? token = (await API.UpdateRegisterID(
                                  name: controller.nameController.text,
                                  address: controller.addressController.text,
                                  place_of_birth: controller
                                      .placeOfBirthController.text,
                                  date_of_birth: dateOfBirth,
                                  phone_number: controller.phoneNumberController
                                      .text,
                                  email: controller.emailController.text,
                                  bank_account_name: controller
                                      .bankAccountNameController.text ?? '',
                                  bank_account_number: controller
                                      .bankAccountNumberController.text,
                                  bank_code: controller.selectedBank.value ??
                                      '',
                                  bank_name: controller.selectedBankName
                                      .value ?? '',
                                  bank_currency: controller.selectedCurency
                                      .value ?? "",
                                  civil_id: controller.civilIdController.text,
                                  tax_id: controller.taxIdController.text,
                                  corporate: controller.selectedType.value ??
                                      '',
                                  salutation: controller.selectedSalutation
                                      .value ?? '',
                                  zip_code: controller.zipCodeController.text,
                                  province: controller.selectedProvince.value ??
                                      '',
                                  city: controller.selectedCity.value ?? '',
                                  pic: controller.PicController.text ?? '',
                                  gender: controller.selectedGender.value ?? '',
                                  license_number: controller
                                      .licenseNumberController.text,
                                  password: controller.passwordController.text,
                                  password_confirmation: controller
                                      .passwordConfirmationController.text,
                                  civil_id_card: controller.civilIdCard.value,
                                  tax_id_card: controller.taxIdCard.value,
                                  license_aaui: controller.licenseAaui.value,
                                  saving_book: controller.savingBook.value,
                                  siup: controller.siup.value,
                                  profile_picture: controller.profilePicture
                                      .value,
                                )) as String?;

                                // Handle response
                                if (token != null) {
                                  Get.offAllNamed(Routes.HOME);
                                  print(
                                      "Edit Account successful, received token: $token");
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Terjadi kesalahan saat Edit Account',
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                }
                              } catch (e) {
                                print('Error during Edit Account: $e');
                                if (e is dio.DioError) {
                                  print('Error response: ${e.response?.data}');
                                }
                              } finally {
                                controller.isLoading.value = false;
                              }
                            },
                          );
                        } else {
                          Get.snackbar(
                            'Gagal Edit Account',
                            'Semua bidang harus diisi',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
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
                          controller.currentStep.value < 2
                              ? 'Next'
                              : 'Save & Edit',
                          style: GoogleFonts.nunito(
                              color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildStepperHeader(SettingController controller) {
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
            child: GestureDetector(
              onTap: () {
                // Update the current step when a step is tapped
                controller.currentStep.value = index;
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: controller.currentStep.value == index
                      ? Colors.orange
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stepTitles[index],
                  style: GoogleFonts.nunito(
                    color: controller.currentStep.value == index
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildStep1Form(SettingController controller) {
    return Form(
      key: controller.formKey1,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(
                color: Colors.grey, // Set the text color to grey
              ),
              controller: controller.nameController,
              readOnly: true,
              enabled: false, // Disable the TextFormField to make it grey and read-only
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Full Name',
                labelStyle: GoogleFonts.nunito(
                  color: Colors.grey, // Set the label text color to grey
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(
                color: Colors.grey, // Set the text color to grey
              ),
              controller: controller.birthController,
              readOnly: true,
              enabled: false, // Disable the TextFormField to make it grey and read-only
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.orange, // Set the icon color to grey
                ),
                border: InputBorder.none,
                labelText: 'Date of Birth',
                labelStyle: GoogleFonts.nunito(
                  color: Colors.grey, // Set the label text color to grey
                ),
                hintStyle: GoogleFonts.nunito(
                  color: Colors.grey, // Set the hint text color to grey
                ),
                hintText: controller.selectedDate.value == null
                    ? 'Select Date of Birth'
                    : DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(
                color: Colors.grey, // Set the text color to grey
              ),
              controller: controller.placeOfBirthController,
              keyboardType: TextInputType.text,
              readOnly: true,
              decoration: InputDecoration(
                prefixIcon: Icon(
                    Icons.maps_home_work_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: ' Place of birth',
                labelStyle: GoogleFonts.nunito(
                  color: Colors.grey, // Set the label text color to grey
                ),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(Icons.school, color: Colors.orange),
                SizedBox(width: 15), // Spacing between icon and dropdown
                Expanded(
                  child: Obx(() {
                    // Check if the data is already loaded
                    if (controller.salutations.isEmpty) {
                      // Show loading indicator while data is being fetched
                      return Center(
                        child: LoadingAnimationWidget.newtonCradle(
                          color: Colors.orange,
                          size: 50, // Make the loading indicator smaller to fit the container better
                        ),
                      );
                    } else {
                      // Load the saved value from local storage or default
                      String? savedValue = controller.selectedSalutation.value;

                      return DropdownButtonFormField<String>(
                        value: savedValue,
                        hint: Text(
                          'Select Salutation',
                          style: GoogleFonts.nunito(
                            color: Colors.grey, // Set the hint text color to grey
                          ),
                        ),
                        isExpanded: true, // Ensures dropdown uses the full width
                        items: controller.salutations.map((salutation) {
                          return DropdownMenuItem<String>(
                            value: salutation,
                            child: Text(
                              salutation,
                              style: GoogleFonts.nunito(
                                color: Colors.grey, // Set the dropdown items text color to grey
                              ),
                              overflow: TextOverflow.ellipsis, // Handle text overflow
                              maxLines: 1, // Limit text to a single line
                            ),
                          );
                        }).toList(),
                        onChanged: null, // Set to null to make the dropdown read-only
                        decoration: InputDecoration(
                          border: InputBorder.none, // Remove the default border
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.transparent, // Set the border color to grey
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey, // Set the disabled border color to grey
                            ),
                          ),
                        ),
                      );

                    }
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
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
                          onChanged: null, // Set to null to make the radio button read-only
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('Female', style: GoogleFonts.nunito()),
                        leading: Radio<String>(
                          value: 'Female',
                          groupValue: controller.selectedGender.value,
                          onChanged: null, // Set to null to make the radio button read-only
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.nunito(
                  color: Colors.grey, // Set the text color to grey
                ),
                readOnly: true,
                enabled: false, // Disable the TextFormField to make it grey and read-only
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.alternate_email_rounded,
                    color: Colors.orange, // Set the icon color to grey
                  ),
                  border: InputBorder.none,
                  labelText: 'Email',
                  labelStyle: GoogleFonts.nunito(
                    color: Colors.grey, // Set the label text color to grey
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Email';
                  }
                  return null;
                },
              )
          ),
          SizedBox(height: 10),
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                style: GoogleFonts.nunito(
                  color: Colors.grey, // Set the text color to grey
                ),
                controller: controller.phoneNumberController,
                keyboardType: TextInputType.number,
                readOnly: true,
                enabled: false, // Disable the TextFormField to make it grey and read-only
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone_android_rounded,
                    color: Colors.orange, // Set the icon color to grey
                  ),
                  border: InputBorder.none,
                  labelText: 'Phone Number',
                  labelStyle: GoogleFonts.nunito(
                    color: Colors.grey, // Set the label text color to grey
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Phone Number';
                  }
                  return null;
                },
              )

          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Type', style: GoogleFonts.nunito(color: Colors.grey)),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('Individual', style: GoogleFonts.nunito(color: Colors.grey)),
                        leading: Radio<String>(
                          value: '0', // Use '0' for Individual
                          groupValue: controller.selectedType.value,
                          onChanged: null, // Make read-only by setting onChanged to null
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('Corporate', style: GoogleFonts.nunito(color: Colors.grey)),
                        leading: Radio<String>(
                          value: '1',
                          groupValue: controller.selectedType.value,
                          onChanged: null, // Make read-only by setting onChanged to null
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  return Visibility(
                    visible: controller.selectedType.value == '1',
                    child: TextField(
                      controller: controller.PicController,
                      readOnly: true, // Make the TextField read-only
                      enabled: false, // Disable the TextField to make it grey
                      style: GoogleFonts.nunito(color: Colors.grey), // Set text color to grey
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.grey), // Set icon color to grey
                        border: InputBorder.none,
                        labelText: 'Corporate Info',
                        labelStyle: GoogleFonts.nunito(color: Colors.grey), // Set label color to grey
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

  Widget _buildStep2Form(SettingController controller) {
    return Form(
      key: controller.formKey2,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
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
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Address';
                }
                return null;
              },
            ),
          ),


          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
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
                            size: 50, // Adjusted size to fit within the container
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else
                      if (!snapshot.hasData || snapshot.data!.data == null ||
                          snapshot.data!.data!.isEmpty) {
                        return Center(child: Text('No data available'));
                      } else {
                        // Extract the province data from the dictionary
                        Map<String, String> provinceMap = snapshot.data!.data!;
                        List<MapEntry<String,
                            String>> provinceEntries = provinceMap.entries
                            .toList();

                        return Obx(() {
                          // Access the saved value from the controller
                          String? savedValue = controller.selectedProvince
                              .value;

                          // Ensure the saved value is in the list of valid province keys
                          if (savedValue != null &&
                              !provinceMap.containsKey(savedValue)) {
                            savedValue = null; // Reset if not found
                          }

                          return DropdownButtonFormField<String>(
                            value: savedValue,
                            // Set the selected value
                            hint: Text(
                              'Select Province',
                              style: GoogleFonts.nunito(
                                color: Colors.grey, // Set hint text color to grey
                              ),
                            ),
                            items: provinceEntries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                // Use province code as the value
                                child: Text(
                                  entry.value, // Display the full province name
                                  style: GoogleFonts.nunito(
                                    color: Colors.grey, // Set the dropdown items text color to grey
                                  ),
                                  overflow: TextOverflow.ellipsis, // Handle overflow
                                  maxLines: 1, // Limit text to a single line
                                ),
                              );
                            }).toList(),
                            onChanged: null, // Set to null to make the dropdown read-only
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a Province';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none, // Remove default border
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey, // Set the disabled border color to grey
                                ),
                              ),
                            ),
                            isExpanded: true, // Make dropdown take full width
                          );
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(Icons.location_city_rounded, color: Colors.orange), // Set icon color to grey
                SizedBox(width: 15),
                Expanded(
                  child: Obx(() {
                    if (controller.cities.isEmpty) {
                      // Show loading indicator while data is being fetched
                      return Center(
                        child: LoadingAnimationWidget.newtonCradle(
                          color: Colors.orange,
                          size: 50, // Adjusted size to fit within the container
                        ),
                      );
                    } else {
                      // Access the saved value from the controller
                      String? savedValue = controller.selectedCity.value;

                      return DropdownButtonFormField<String>(
                        value: savedValue,
                        // Set the selected value
                        hint: Text(
                          'Select City',
                          style: GoogleFonts.nunito(
                            color: Colors.grey, // Set hint text color to grey
                          ),
                        ),
                        items: controller.cities.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key, // Use city ID as the value
                            child: Text(
                              entry.value, // Display the city name
                              style: GoogleFonts.nunito(
                                color: Colors.grey, // Set the dropdown items text color to grey
                              ),
                              overflow: TextOverflow.ellipsis,
                              // Handle overflow
                              maxLines: 1, // Limit text to a single line
                            ),
                          );
                        }).toList(),
                        onChanged: null, // Set to null to make the dropdown read-only
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a City';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none, // Remove the default border
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey, // Set the disabled border color to grey
                            ),
                          ),
                        ),
                        isExpanded: true, // Make dropdown take full width
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(
                color: Colors.grey, // Set the text color to grey
              ),
              controller: controller.zipCodeController,
              readOnly: true, // Make the TextFormField read-only
              enabled: false, // Disable the TextFormField to make it grey
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.location_city,
                  color: Colors.orange, // Set the icon color to grey
                ),
                border: InputBorder.none,
                labelText: 'Zip Code',
                labelStyle: GoogleFonts.nunito(
                  color: Colors.grey, // Set the label text color to grey
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid Zip Code';
                }
                return null;
              },
            ),
          ),
    SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child:TextFormField(
              style: GoogleFonts.nunito(
                color: Colors.grey, // Set the text color to grey
              ),
              controller: controller.licenseNumberController,
              readOnly: true, // Make the TextFormField read-only
              enabled: false, // Disable the TextFormField to make it grey
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.numbers,
                  color: Colors.orange, // Set the icon color to grey
                ),
                border: InputBorder.none,
                labelText: 'License Number',
                labelStyle: GoogleFonts.nunito(
                  color: Colors.grey, // Set the label text color to grey
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid License Number';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(
                color: Colors.grey, // Set the text color to grey
              ),
              controller: controller.civilIdController,
              readOnly: true, // Make the TextFormField read-only
              enabled: false, // Disable the TextFormField to make it grey
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.credit_card_rounded,
                  color: Colors.orange, // Set the icon color to grey
                ),
                border: InputBorder.none,
                labelText: 'NIK / Civil ID',
                labelStyle: GoogleFonts.nunito(
                  color: Colors.grey, // Set the label text color to grey
                ),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(
                color: Colors.grey, // Set the text color to grey
              ),
              controller: controller.taxIdController,
              readOnly: true, // Make the TextFormField read-only
              enabled: false, // Disable the TextFormField to make it grey
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.credit_card_rounded,
                  color: Colors.orange, // Set the icon color to grey
                ),
                border: InputBorder.none,
                labelText: 'NPWP / TaxID',
                labelStyle: GoogleFonts.nunito(
                  color: Colors.grey, // Set the label text color to grey
                ),
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

  Widget _buildStep3Form(SettingController controller) {
    return Form(
      key: controller.formKey3,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(Icons.monetization_on_outlined, color: Colors.orange),
                SizedBox(width: 15),
                Expanded(
                  child: Obx(() {
                    // Check if the data is already loaded
                    if (controller.currencies.isEmpty) {
                      // Show loading indicator while data is being fetched
                      return Center(
                        child: LoadingAnimationWidget.newtonCradle(
                          color: Colors.orange,
                          size: 50, // Adjusted size to fit within the container
                        ),
                      );
                    } else {
                      // Access the saved value from the controller
                      String? savedValue = controller.selectedCurency.value;

                      // Ensure the saved value is in the list of valid currency keys
                      if (savedValue != null &&
                          !controller.currencies.containsKey(savedValue)) {
                        savedValue = null; // Reset if not found
                      }

                      return DropdownButtonFormField<String>(
                        value: savedValue,
                        // Set the selected value
                        hint: Text('Select Currency', style: GoogleFonts
                            .nunito()),
                        items: controller.currencies.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key, // Use currency code as the value
                            child: Text(
                              entry.value, // Display the full currency name
                              style: GoogleFonts.nunito(),
                              overflow: TextOverflow.ellipsis,
                              // Handle overflow
                              maxLines: 1, // Limit text to a single line
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedCurency.value = value;
                            LocalStorage.saveSelectedCurrency(
                                value); // Save the selected currency code
                            print("Selected Currency Code: ${controller
                                .selectedCurency.value}");
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
                    }
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: Colors.orange),
                SizedBox(width: 15),
                Expanded(
                  child: Obx(() {
                    // Check if the data is already loaded
                    if (controller.banks.isEmpty) {
                      // Show loading indicator while data is being fetched
                      return Center(
                        child: LoadingAnimationWidget.newtonCradle(
                          color: Colors.orange,
                          size: 50, // Adjusted size to fit within the container
                        ),
                      );
                    } else {
                      // Access the saved value from the controller
                      String? savedID = controller.selectedBank.value;

                      // Ensure the saved value is in the list of valid bank keys
                      if (savedID != null &&
                          !controller.banks.containsKey(savedID)) {
                        savedID = null; // Reset if not found
                      }

                      return DropdownButtonFormField<String>(
                        value: savedID,
                        // Set the selected value
                        hint: Text('Select Bank', style: GoogleFonts.nunito()),
                        items: controller.banks.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key, // Use bank ID as the value
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.7, // Limit width
                              ),
                              child: Text(
                                entry.value, // Display bank name
                                style: GoogleFonts.nunito(),
                                overflow: TextOverflow
                                    .ellipsis, // Handle long text
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            String? selectedBankName = controller.banks[value];
                            controller.selectedBank.value =
                                value; // Save selected bank ID
                            controller.selectedBankName.value =
                                selectedBankName ??
                                    ''; // Save selected bank name
                            LocalStorage.saveSelectedBank(
                                value); // Save the selected bank ID
                            print("Selected Bank ID: ${controller.selectedBank
                                .value}");
                            print("Selected Bank Name: ${controller
                                .selectedBankName.value}");
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
                    }
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.bankAccountNumberController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                    Icons.comment_bank_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Bank Account',
                labelStyle: GoogleFonts.nunito(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid Bank Account';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: GoogleFonts.nunito(),
              controller: controller.bankAccountNameController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                    Icons.comment_bank_rounded, color: Colors.orange),
                border: InputBorder.none,
                labelText: 'Bank Account Holder',
                labelStyle: GoogleFonts.nunito(),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid Bank Account Holder';
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

  Widget _buildImageUploadSection(SettingController controller) {
    return FutureBuilder<Verifikasi?>(
      future: API.VerifikasiID(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data available'));
        } else {
          Verifikasi? userProfile = snapshot.data;
          Data? userData = userProfile?.data;

          String? profileImageUrl = userData?.attProfile != null
              ? 'https://agencyapps.megainsurance.co.id/storage/${userData!
              .attProfile}'
              : null;
          String? civilIdImageUrl = userData?.attCivilid != null
              ? 'https://agencyapps.megainsurance.co.id/storage/${userData!
              .attCivilid}'
              : null;
          String? taxIdImageUrl = userData?.attTaxid != null
              ? 'https://agencyapps.megainsurance.co.id/storage/${userData!
              .attTaxid}'
              : null;
          String? licenseImageUrl = userData?.attLicense != null
              ? 'https://agencyapps.megainsurance.co.id/storage/${userData!
              .attLicense}'
              : null;
          String? savingImageUrl = userData?.attSaving != null
              ? 'https://agencyapps.megainsurance.co.id/storage/${userData!
              .attSaving}'
              : null;
          String? siupImageUrl = userData?.attSiup != null
              ? 'https://agencyapps.megainsurance.co.id/storage/${userData!
              .attSiup}'
              : null;

          return Column(
            children: [
              _buildImageUploadField(
                controller: controller,
                fieldName: 'civilIdCard',
                label: 'Photo KTP / Civil ID',
                imageFile: controller.civilIdCard,
                imageUrl: civilIdImageUrl,
              ),
              _buildImageUploadField(
                controller: controller,
                fieldName: 'taxIdCard',
                label: 'Photo NPWP / Tax ID',
                imageFile: controller.taxIdCard,
                imageUrl: taxIdImageUrl,
              ),
              _buildImageUploadField(
                controller: controller,
                fieldName: 'savingBook',
                label: 'Photo Buku / Saving Book',
                imageFile: controller.savingBook,
                imageUrl: savingImageUrl,
              ),
              _buildImageUploadField(
                controller: controller,
                fieldName: 'licenseAaui',
                label: 'Photo License / License Certificate',
                imageFile: controller.licenseAaui,
                imageUrl: licenseImageUrl,
              ),
              if (controller.selectedType.value == '1')
                _buildImageUploadField(
                  controller: controller,
                  fieldName: 'siup',
                  label: 'Upload Business Permit',
                  imageFile: controller.siup,
                  imageUrl: siupImageUrl,
                ),
              _buildImageUploadField(
                controller: controller,
                fieldName: 'profilePicture',
                label: 'Profile Picture',
                imageFile: controller.profilePicture,
                imageUrl: profileImageUrl,
              ),
            ],
          );
        }
      },
    );
  }


  Widget _buildImageUploadField({
    required SettingController controller,
    required String fieldName,
    required String label,
    required Rx<File?> imageFile,
    String? imageUrl,
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
                    } else if (imageUrl != null) {
                      if (imageUrl.endsWith('.pdf')) {
                        return Row(
                          children: [
                            Icon(Icons.picture_as_pdf, size: 40,
                                color: Colors.red),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'PDF File: ${imageUrl
                                    .split('/')
                                    .last}',
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.download),
                              onPressed: () async {
                                await _downloadFile(imageUrl, fieldName);
                              },
                            ),
                          ],
                        );
                      } else {
                        return Image.network(
                          imageUrl,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.error, color: Colors.red),
                        );
                      }
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
}
Future<void> _downloadFile(String url, String fileName) async {
  try {
    // Request storage permission

    // Get the "Downloads" directory path
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      Get.snackbar(
        'Error',
        'Could not access the downloads directory.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Ensure the file name has the correct .pdf extension
    if (!fileName.endsWith('.pdf')) {
      fileName = '$fileName.pdf';
    }

    // Construct the full file path
    final filePath = '${directory.path}/$fileName';

    // Start the file download using Dio
    final dio = Dio();
    final response = await dio.download(url, filePath);

    if (response.statusCode == 200) {
      // Show Snackbar with an action button to open the file
      Get.snackbar(
        'Download Completed',
        'File downloaded successfully to $filePath',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Download Failed',
        'Failed to download the file.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    print('Error downloading file: $e');
    Get.snackbar(
      'Download Error',
      'An error occurred while downloading the file.',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}


Future<Directory?> getDownloadsDirectory() async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download'); // Common Downloads directory path for Android
  } else if (Platform.isIOS) {
    return await getApplicationDocumentsDirectory(); // iOS does not have a traditional "Downloads" folder
  }
  return null;
}




Widget _buildFilePreview(File file, SettingController controller) {
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
class LocalStorage {
  // General method to save a value
  static Future<void> saveValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // General method to get a value
  static Future<String?> getValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Specific methods for saving and retrieving values
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
