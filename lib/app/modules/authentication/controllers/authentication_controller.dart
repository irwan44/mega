import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/localstorage.dart';

class AuthenticationController extends GetxController {
  // Stepper state

  var currentStep = 0.obs;
  var selectedDate = Rx<DateTime?>(null);
  RxBool isLoading = false.obs;
  // Form keys
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();

  // Personal information controllers
  final emailloginController = TextEditingController();
  final passwordloginController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final PicController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final birthController = TextEditingController();
  var selectedSalutation = Rx<String?>(null);
  var selectedGender = Rx<String?>(null);
  var selectedCurency = Rx<String?>(null);
  var selectedBankName = Rx<String?>(null);
  var selectedCity = Rx<String?>(null);
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final zipCodeController = TextEditingController();
  final licenseController = TextEditingController();
  final nikController = TextEditingController();
  final npwpController = TextEditingController();
  final bankAccountController = TextEditingController();
  final bankAccountHolderController = TextEditingController();
  var selectedType = Rx<String?>(null);
  final placeOfBirthController = TextEditingController();

  final emailController = TextEditingController();

  var obscurePassword = true.obs;
  var obscureConfirmationPassword = true.obs;

  // Address information controllers
  var selectedArea = Rx<String?>(null);
  var selectedProvince = Rx<String?>(null);
  final licenseNumberController = TextEditingController();
  final civilIdController = TextEditingController();
  final taxIdController = TextEditingController();
  final OTPController = TextEditingController();
  // Bank information controllers
  var selectedBank = Rx<String?>(null);
  final bankAccountNumberController = TextEditingController();
  final bankAccountNameController = TextEditingController();

  // File uploads
  var civilIdCard = Rx<File?>(null);
  var taxIdCard = Rx<File?>(null);
  var licenseAaui = Rx<File?>(null);
  var savingBook = Rx<File?>(null);
  var siup = Rx<File?>(null);
  var profilePicture = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    requestGalleryPermission();
    loadStoredEmail();
    loadStoredExternalId();
  }
  Future<void> loadStoredExternalId() async {
    final prefs = await SharedPreferences.getInstance();
    String? externalId = prefs.getString('external_id');
    if (externalId != null) {
      emailloginController.text = externalId;
    }
  }

  // Add a method to save `external_id` (if needed)
  Future<void> saveExternalId(String externalId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('external_id', externalId);
  }

  Future<void> loadStoredEmail() async {
    String storedEmail = LocalStorages.getEmail;
    if (storedEmail.isNotEmpty) {
      emailController.text = storedEmail;
    }
  }

  Future<void> saveEmail() async {
    await LocalStorages.setEmail(emailController.text);
  }

  Future<void> requestGalleryPermission() async {
    var status = await Permission.photos.status;

    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Please allow gallery access to use this feature.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> selectDate(DateTime initialDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate.value) {
      selectedDate.value = pickedDate;
      birthController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> showImageSourceDialog(String field) async {
    // Show dialog to choose between camera and gallery
    await Get.dialog(
      AlertDialog(
        title: Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Photo'),
              onTap: () {
                Navigator.of(Get.context!).pop();
                pickImage(ImageSource.camera, field);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Pick from Gallery'),
              onTap: () {
                Navigator.of(Get.context!).pop();
                pickImage(ImageSource.gallery, field);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source, String field) async {
    final permissionStatus = await Permission.photos.status;

    if (permissionStatus.isDenied) {
      // Request permission
      final newStatus = await Permission.photos.request();
      if (!newStatus.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Please grant gallery access in your device settings.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      Get.snackbar(
        'Permission Permanently Denied',
        'Please enable gallery access in your device settings.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Proceed with picking the image
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        switch (field) {
          case 'profilePicture':
            profilePicture.value = file;
            break;
          case 'civilIdCard':
            civilIdCard.value = file;
            break;
          case 'taxIdCard':
            taxIdCard.value = file;
            break;
          case 'licenseAaui':
            licenseAaui.value = file;
            break;
          case 'savingBook':
            savingBook.value = file;
            break;
          case 'siup':
            siup.value = file;
            break;
          default:
            Get.snackbar(
              'Invalid Field',
              'The specified field is not valid for image upload.',
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
            break;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while picking the image: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void nextStep() {
    if ((currentStep.value == 0 && formKey1.currentState?.validate() == true) ||
        (currentStep.value == 1 && formKey2.currentState?.validate() == true) ||
        (currentStep.value == 2 && formKey3.currentState?.validate() == true)) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
