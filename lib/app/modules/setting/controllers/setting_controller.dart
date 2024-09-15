import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/data_endpoint/Salutations.dart';
import '../../../data/data_endpoint/area.dart';
import '../../../data/data_endpoint/bank.dart';
import '../../../data/data_endpoint/curency.dart';
import '../../../data/data_endpoint/provinsi.dart';
import '../../../data/data_endpoint/verifikasi.dart';
import '../../../data/endpoint.dart';
import '../../../data/localstorage.dart';

class SettingController extends GetxController {

  var currentStep = 0.obs;
  var selectedDate = Rx<DateTime?>(null);
  RxBool isLoading = false.obs;


  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();

  Rx<Verifikasi?> userProfile = Rx<Verifikasi?>(null);

  // Reactive data for dropdowns
  RxList<String> salutations = <String>[].obs;
  RxMap<String, String> currencies = <String, String>{}.obs;
  RxMap<String, String> banks = <String, String>{}.obs;
  RxMap<String, String> cities = <String, String>{}.obs;
  RxMap<String, String> provinces = <String, String>{}.obs;


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
  final bankAccountHolderController = TextEditingController();
  var selectedType = Rx<String?>(null);
  final placeOfBirthController = TextEditingController();
  final emailController = TextEditingController();
  var obscurePassword = true.obs;
  var obscureConfirmationPassword = true.obs;
  var selectedArea = Rx<String?>(null);
  var selectedProvince = Rx<String?>(null);
  final licenseNumberController = TextEditingController();
  final civilIdController = TextEditingController();
  final taxIdController = TextEditingController();
  final OTPController = TextEditingController();
  var selectedBank = Rx<String?>(null);
  final bankAccountNumberController = TextEditingController();
  final bankAccountNameController = TextEditingController();
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
    loadUserProfile();
    fetchDropdownData();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final verifikasi = await API.VerifikasiID();
      if (verifikasi != null && verifikasi.data != null) {
        userProfile.value = verifikasi;
        _setDefaultValuesFromProfile(verifikasi.data!);
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _setDefaultValuesFromProfile(Data profile) {
    // Set default values from profile data
    emailController.text = profile.email ?? '';
    nameController.text = profile.name ?? '';
    phoneNumberController.text = profile.phoneNumber ?? '';
    addressController.text = profile.address ?? '';
    zipCodeController.text = profile.zipCode ?? '';
    licenseNumberController.text = profile.licenseNumber ?? '';
    civilIdController.text = profile.civilId ?? '';
    taxIdController.text = profile.taxId ?? '';
    bankAccountNumberController.text = profile.bankAccountNumber ?? '';
    bankAccountNameController.text = profile.bankAccountName ?? '';
    if (profile.dateOfBirth != null && profile.dateOfBirth!.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(profile.dateOfBirth!);
        selectedDate.value = parsedDate; // Update selectedDate
        birthController.text = DateFormat('dd-MM-yyyy').format(parsedDate); // Set formatted date text
      } catch (e) {
        print('Error parsing date: $e');
        selectedDate.value = null; // Set to null if parsing fails
        birthController.text = ''; // Clear the text if parsing fails
      }
    } else {
      selectedDate.value = null; // Set to null if no date provided
      birthController.text = ''; // Clear the text if no date provided
    }

    placeOfBirthController.text = profile.placeOfBirth ?? '';
    print("Profile Data Loaded:");
    print("Name: ${nameController.text}");
    print("Address: ${addressController.text}");
    print("Email: ${emailController.text}");
    print("Phone: ${phoneNumberController.text}");
    print("DOB: ${birthController.text}");
    print("civilId: ${civilIdController.text}");
    // Set dropdown default values based on user profile
    selectedSalutation.value = salutations.contains(profile.salutation) ? profile.salutation : null;
    selectedGender.value = profile.gender;
    selectedCurency.value = currencies.value.containsKey(profile.bankCurrency) ? profile.bankCurrency : null;
    selectedBank.value = banks.entries
        .firstWhere(
            (entry) => entry.value.toLowerCase() == profile.bankName?.toLowerCase(),
        orElse: () => MapEntry('', ''))
        .key;
    selectedCity.value = cities.value.containsKey(profile.city) ? profile.city : null;
    selectedProvince.value = provinces.value.containsKey(profile.province) ? profile.province : null;
    selectedType.value = profile.corporate == true ? '1' : '0';
  }


  Future<void> fetchDropdownData() async {
    try {
      // Fetch salutations
      final salutationResponse = await API.SalutationsID();
      if (salutationResponse != null && salutationResponse.data != null) {
        salutations.value = List<String>.from(salutationResponse.data!);
      }

      // Fetch currencies
      final currencyResponse = await API.CurrencyID();
      if (currencyResponse != null && currencyResponse.data != null) {
        currencies.value = Map<String, String>.from(currencyResponse.data!);
      }

      // Fetch bank names
      final bankResponse = await API.BankID();
      if (bankResponse != null && bankResponse.data != null) {
        banks.value = Map<String, String>.from(bankResponse.data!);
      }

      // Fetch cities
      final cityResponse = await API.AreasID();
      if (cityResponse != null && cityResponse.data != null) {
        cities.value = Map<String, String>.from(cityResponse.data!);
      }

      // Fetch provinces
      final provinceResponse = await API.Provincesid();
      if (provinceResponse != null && provinceResponse.data != null) {
        provinces.value = Map<String, String>.from(provinceResponse.data!);
      }

      // Once all dropdown data is fetched, load user profile
      await loadUserProfile();

    } catch (e) {
      print('Error fetching dropdown data: $e');
    }
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

