import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
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
  final SendOTPController = TextEditingController();

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

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
    loadStoredEmail();
    loadStoredExternalId();
    loadDefaultSiup();
  }

  Future<void> loadDefaultSiup() async {
    try {
      // Load the file from assets
      final ByteData data = await rootBundle.load('assets/gambar/default.jpg');
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/default.jpg');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);

      // Set the default file to the siup variable
      siup.value = file;
    } catch (e) {
      print('Error loading default SIUP file: $e');
    }
  }

  Future<void> loadStoredExternalId() async {
    final prefs = await SharedPreferences.getInstance();
    String? externalId = prefs.getString('external_id');
    if (externalId != null) {
      emailloginController.text = externalId;
    }
  }

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

  Future<void> requestPermissions() async {
    var statusStorage = await Permission.storage.status;
    var statusPhotos = await Permission.photos.status;

    if (!statusStorage.isGranted || !statusPhotos.isGranted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.photos,
      ].request();

      if (statuses[Permission.storage] != PermissionStatus.granted ||
          statuses[Permission.photos] != PermissionStatus.granted) {
        return;
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

  Future<void> showImageSourceDialog(String field) async {
    // Dialog to choose image source or PDF
    await Get.dialog(
      AlertDialog(
        title: Text('Choose File Source'),
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
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Pick PDF'),
              onTap: () {
                Navigator.of(Get.context!).pop();
                pickAndUploadPdf(field);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source, String field) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        assignFileToField(file, field);
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

  Future<void> pickAndUploadPdf(String field) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File pdfFile = File(result.files.single.path!);

        assignFileToField(pdfFile, field);

        print('PDF has been successfully selected: ${pdfFile.path}');
      } else {
        print('No PDF file was selected.');
      }
    } catch (e) {
      print('An error occurred while picking the PDF: $e');
    }
  }

  void assignFileToField(File file, String field) {
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
          'The specified field is not valid for file upload.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        break;
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
