
import 'dart:convert';

import 'package:bank_mega/app/data/data_endpoint/verifikasi.dart';
import 'package:bank_mega/app/data/public.dart';
import 'package:dio/dio.dart' as dio; // Use alias for dio package
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../routes/app_pages.dart';
import 'data_endpoint/Salutations.dart';
import 'data_endpoint/area.dart';
import 'data_endpoint/bank.dart';

import 'data_endpoint/curency.dart';
import 'data_endpoint/otp.dart';
import 'data_endpoint/pretest.dart';
import 'data_endpoint/provinsi.dart';
import 'data_endpoint/registrasi.dart';
import 'localstorage.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';

class API {
  static const _urlbe = 'https://agencyapps.megainsurance.co.id';
  static const _baseUrl = '$_urlbe/api';
  static const _PostLogin = '$_baseUrl/login';
  static const _PostRegistrasi = '$_baseUrl/register';
  static const _PostSalutations = '$_baseUrl/extra/salutations';
  static const _Postareas = '$_baseUrl/extra/areas';
  static const _Postbanks = '$_baseUrl/extra/banks';
  static const _Postprovinces = '$_baseUrl/extra/provinces';
  static const _PostScurrencies = '$_baseUrl/extra/currencies';
  static const _PostOTP = '$_baseUrl/verify-otp';
  static const _Postpretes = '$_baseUrl/pre-test/quizzes/latest/questions';
  static const _Postme = '$_baseUrl/me';

  static Future<String?> login({required String idnumber, required String password}) async {
    final data = {
      "id_number": idnumber,
      "password": password,
    };

    try {
      var response = await dio.Dio().post(
        _PostLogin,
        options: dio.Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData['status'] != 'authenticated') {
            Get.snackbar('Error', responseData['message'] ?? 'An unexpected error occurred',
                backgroundColor: const Color(0xffe5f3e7));
            return null;
          } else {
            String? token = responseData['data']?['token'];
            if (token != null) {
              LocalStorages.setToken(token);

              Get.snackbar('Selamat Datang', 'MEGA INCURANCE',
                  backgroundColor: Colors.green,
                  colorText: Colors.white);
              Get.offAllNamed(Routes.QUIZ);
              return token;
            } else {
              print('Token is null. Unable to proceed.');
              Get.snackbar('Error', 'Token is missing in the response.',
                  backgroundColor: Colors.redAccent, colorText: Colors.white);
              return null;
            }
          }
        } else {
          print('Unexpected response format: ${response.data}');
          Get.snackbar('Error', 'Unexpected response format from server.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return null;
        }
      } else if (response.statusCode == 422) {
        print('Validation error: ${response.data}');
        Get.snackbar('Validation Error', 'Please check your credentials and try again.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return null;
      } else {
        print('Failed to load data, status code: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to load data: ${response.statusCode}',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      Get.snackbar('Error', 'An error occurred during login. Please try again.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return null;
    }
  }

  static Future<Registrasi> RegisterID({
    required String name,
    required String address,
    required String place_of_birth,
    required String date_of_birth,
    required String phone_number,
    required String email,
    required String bank_account_name,
    required String bank_account_number,
    required String bank_code,
    required String bank_currency,
    required String civil_id,
    required String tax_id,
    required String corporate,
    required String salutation,
    required String zip_code,
    required String province,
    required String city,
    required String pic,
    required String gender,
    required String bank_name,
    required String license_number,
    required String password,
    required String password_confirmation,
    required File? civil_id_card,
    required File? tax_id_card,
    required File? license_aaui,
    required File? saving_book,
    required File? siup,
    required File? profile_picture,
  }) async {
    final formData = dio.FormData.fromMap({
      "name": name,
      "address": address,
      "place_of_birth": place_of_birth,
      "date_of_birth": date_of_birth,
      "phone_number": phone_number,
      "bank_name": bank_name,
      "email": email,
      "bank_account_name": bank_account_name,
      "bank_account_number": bank_account_number,
      "bank_code": bank_code,
      "bank_currency": bank_currency,
      "civil_id": civil_id,
      "tax_id": tax_id,
      "corporate": corporate,
      "salutation": salutation,
      "zip_code": zip_code,
      "province": province,
      "city": city,
      "pic": pic,
      "gender": gender,
      "license_number": license_number,
      "password": password,
      "password_confirmation": password_confirmation,
      "civil_id_card": civil_id_card != null
          ? await dio.MultipartFile.fromFile(
        civil_id_card.path,
        filename: civil_id_card.path.split('/').last,
      )
          : null,
      "tax_id_card": tax_id_card != null
          ? await dio.MultipartFile.fromFile(
        tax_id_card.path,
        filename: tax_id_card.path.split('/').last,
      )
          : null,
      "license_aaui": license_aaui != null
          ? await dio.MultipartFile.fromFile(
        license_aaui.path,
        filename: license_aaui.path.split('/').last,
      )
          : null,
      "saving_book": saving_book != null
          ? await dio.MultipartFile.fromFile(
        saving_book.path,
        filename: saving_book.path.split('/').last,
      )
          : null,
      "siup": siup != null
          ? await dio.MultipartFile.fromFile(
        siup.path,
        filename: siup.path.split('/').last,
      )
          : null,
      "profile_picture": profile_picture != null
          ? await dio.MultipartFile.fromFile(
        profile_picture.path,
        filename: profile_picture.path.split('/').last,
      )
          : null,
    });

    try {
      final token = Publics.controller.getTokenRegis.value ?? '';
      print('Token: $token');

      var response = await dio.Dio().post(
        _PostRegistrasi,
        data: formData,
        options: dio.Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $token",
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'registered') {
        String? token = response.data['data']?['token'];
        if (token != null) {
          // Save the token using LocalStorages
          await LocalStorages.setTokenRegis(token);

          Get.offAllNamed(Routes.OtpVerification);
          Get.snackbar(
            'Hore',
            'Registrasi Akun Anda Berhasil!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return Registrasi(id: response.data['data']['id'], token: token);
        } else {
          Get.snackbar(
            'Error',
            'Token tidak ditemukan dalam respons',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          throw Exception('Token tidak ditemukan dalam respons');
        }
      } else {
        Get.snackbar(
          'Error',
          'Terjadi kesalahan saat registrasi',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        throw Exception('Kesalahan saat registrasi');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar(
        'Gagal Registrasi',
        'Terjadi kesalahan saat registrasi: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      throw e;
    }
  }

//Beda
  static Future<Salutations> SalutationsID() async {
    try {
      final token = Publics.controller.getToken.value ?? '';
      var data = {"token": token};
      var response = await Dio().get(
        _PostSalutations,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        queryParameters: data,
      );

      if (response.statusCode == 404) {
        return Salutations(message: "Tidak ada data booking untuk karyawan ini.");
      }

      final obj = Salutations.fromJson(response.data);

      if (obj.message == 'Invalid token: Expired') {
        Get.offAllNamed(Routes.AUTHENTICATION);
        Get.snackbar(
          obj.message.toString(),
          obj.message.toString(),
        );
      }

      return obj;
    } catch (e) {
      throw e;
    }
  }
//Beda

//Beda
  static Future<Bank> BankID() async {
    try {
      final token = Publics.controller.getToken.value ?? '';
      var data = {"token": token};
      var response = await Dio().get(
        _Postbanks,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        queryParameters: data,
      );

      if (response.statusCode == 404) {
        return Bank(message: "Tidak ada data booking untuk karyawan ini.");
      }

      final obj = Bank.fromJson(response.data);

      if (obj.message == 'Invalid token: Expired') {
        Get.offAllNamed(Routes.AUTHENTICATION);
        Get.snackbar(
          obj.message.toString(),
          obj.message.toString(),
        );
      }

      return obj;
    } catch (e) {
      throw e;
    }
  }

  //Beda
  static Future<Area> AreasID() async {
    try {
      final token = Publics.controller.getToken.value ?? '';
      var data = {"token": token};
      var response = await Dio().get(
        _Postareas,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        queryParameters: data,
      );

      if (response.statusCode == 404) {
        return Area(message: "Tidak ada data booking untuk karyawan ini.");
      }

      final obj = Area.fromJson(response.data);

      if (obj.message == 'Invalid token: Expired') {
        Get.offAllNamed(Routes.AUTHENTICATION);
        Get.snackbar(
          obj.message.toString(),
          obj.message.toString(),
        );
      }

      return obj;
    } catch (e) {
      throw e;
    }
  }
  //Beda
  static Future<Provinsi> Provincesid() async {
    try {
      final token = Publics.controller.getToken.value ?? '';
      var data = {"token": token};
      var response = await Dio().get(
        _Postprovinces,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        queryParameters: data,
      );

      if (response.statusCode == 404) {
        return Provinsi(message: "Tidak ada data booking untuk karyawan ini.");
      }

      final obj = Provinsi.fromJson(response.data);

      if (obj.message == 'Invalid token: Expired') {
        Get.offAllNamed(Routes.AUTHENTICATION);
        Get.snackbar(
          obj.message.toString(),
          obj.message.toString(),
        );
      }

      return obj;
    } catch (e) {
      throw e;
    }
  }
  //Beda
  static Future<Currency> CurrencyID() async {
    try {
      final token = Publics.controller.getToken.value ?? '';
      var data = {"token": token};
      var response = await Dio().get(
        _PostScurrencies,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        queryParameters: data,
      );

      if (response.statusCode == 404) {
        return Currency(message: "Tidak ada data booking untuk karyawan ini.");
      }

      final obj = Currency.fromJson(response.data);

      if (obj.message == 'Invalid token: Expired') {
        Get.offAllNamed(Routes.AUTHENTICATION);
        Get.snackbar(
          obj.message.toString(),
          obj.message.toString(),
        );
      }
      return obj;
    } catch (e) {
      throw e;
    }
  }
  static Future<Salutations> ScurrenciesID({
    required String kodebooking,
  }) async {
    final data = {
      "kode_booking": kodebooking,
    };

    try {
      final token = Publics.controller.getToken.value ?? '';
      print('Token: $token');
      print('kode svc : $kodebooking');

      var response = await Dio().get(
        _PostScurrencies,
        data: data,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      print('Response: ${response.data}');

      final obj = Salutations.fromJson(response.data);

      if (obj.status == 'Invalid token: Expired') {
        Get.offAllNamed(Routes.HOME);
        Get.snackbar(
          obj.status.toString(),
          obj.status.toString(),
        );
      }
      return obj;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  //Beda
  static Future<OTP> OtpID({
    required String email,
    required String otp,
  }) async {
    final formData = dio.FormData.fromMap({
      "email": email,
      "otp": otp,
    });

    try {
      final token = Publics.controller.getToken.value ?? '';
      print('Token: $token');

      var response = await dio.Dio().post(
        _PostOTP,
        data: formData,
        options: dio.Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $token",
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        final message = responseData['message'] as String;

        if (message == 'OTP verified successfully') {
          // Successful OTP verification
          Get.offAllNamed(Routes.AUTHENTICATION);
          return OTP(message: 'Registrasi Berhasil');
        } else {
          // Handle specific error messages
          Get.snackbar(
            'Gagal OTP',
            'Kode OTP Anda salah atau sudah kadaluarsa',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return OTP(message: 'Gagal OTP');
        }
      } else {
        throw Exception('Response status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memverifikasi OTP',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return OTP(message: 'Gagal Registrasi');
    }
  }

  //Beda
    static Future<Verifikasi> VerifikasiID() async {
      // Retrieve token from local storage
      final token = await LocalStorages.getToken;

      if (token == null) {
        throw Exception('No token found');
      }

      try {
        // Make the API request
        final response = await Dio().get(
          _Postme,
          options: Options(
            headers: {
              "Authorization": "Bearer $token",
            },
          ),
        );

        // Log response status and data
        print('VerifikasiID Response status: ${response.statusCode}');
        print('VerifikasiID Response data: ${response.data}');

        if (response.statusCode == 200) {
          // Parse the response data
          final verifikasi = Verifikasi.fromJson(response.data);

          // Extract external ID and save to local storage
          String? externalId = verifikasi.data?.externalId;
          await LocalStorages.saveExternalId(externalId ?? '');

          print('Saved external ID: ${externalId ?? 'empty'}');
          return verifikasi;
        } else {
          throw Exception(
              'Failed to verify ID. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // Handle and log errors
        print('Error during VerifikasiID: $e');
        throw Exception('An error occurred during verification. Details: $e');
      }
    }



    ///bwda
  static Future<Pretest> PretestID() async {
    try {
      final token = await LocalStorages.getToken;

      final response = await Dio().get(
        _Postpretes,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token", // Include the token in the headers
          },
        ),
      );

      if (response.statusCode == 404) {
        return Pretest(message: "Tidak ada data booking untuk karyawan ini.");
      }

      final obj = Pretest.fromJson(response.data);

      if (obj.message == 'Invalid token: Expired') {
        Get.snackbar(
          obj.message.toString(),
          obj.message.toString(),
        );
      } else {
        // Handle other responses if needed
      }

      return obj;
    } catch (e) {
      throw e;
    }
  }

}
