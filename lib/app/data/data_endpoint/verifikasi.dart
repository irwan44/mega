class Verifikasi {
  int? code;
  String? status;
  String? message;
  Data? data;

  Verifikasi({this.code, this.status, this.message, this.data});

  Verifikasi.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  int? accountStatus;
  String? createdAt;
  String? updatedAt;
  bool? postTest;
  bool? preTest;
  String? idNumber;
  int? userId;
  String? address;
  String? placeOfBirth;
  String? dateOfBirth;
  String? phoneNumber;
  String? bankName;
  String? bankAccountNumber;
  String? civilId;
  String? taxId;
  String? licenseNumber;
  String? gender;
  String? pic;
  String? city;
  String? province;
  String? zipCode;
  String? salutation;
  bool? corporate;
  String? bankCurrency;
  String? bankAccountName;
  String? bankCode;
  String? externalId;
  String? token;
  String? attCivilid;
  String? attTaxid;
  String? attLicense;
  String? attSaving;
  String? attSiup;
  String? attProfile;
  String? rejectionNote;

  Data(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.accountStatus,
        this.createdAt,
        this.updatedAt,
        this.postTest,
        this.preTest,
        this.idNumber,
        this.userId,
        this.address,
        this.placeOfBirth,
        this.dateOfBirth,
        this.phoneNumber,
        this.bankName,
        this.bankAccountNumber,
        this.civilId,
        this.taxId,
        this.licenseNumber,
        this.gender,
        this.pic,
        this.city,
        this.province,
        this.zipCode,
        this.salutation,
        this.corporate,
        this.bankCurrency,
        this.bankAccountName,
        this.bankCode,
        this.externalId,
        this.token,
        this.attCivilid,
        this.attTaxid,
        this.attLicense,
        this.attSaving,
        this.attSiup,
        this.attProfile,
        this.rejectionNote});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    accountStatus = json['account_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    postTest = json['post_test'];
    preTest = json['pre_test'];
    idNumber = json['id_number'];
    userId = json['user_id'];
    address = json['address'];
    placeOfBirth = json['place_of_birth'];
    dateOfBirth = json['date_of_birth'];
    phoneNumber = json['phone_number'];
    bankName = json['bank_name'];
    bankAccountNumber = json['bank_account_number'];
    civilId = json['civil_id'];
    taxId = json['tax_id'];
    licenseNumber = json['license_number'];
    gender = json['gender'];
    pic = json['pic'];
    city = json['city'];
    province = json['province'];
    zipCode = json['zip_code'];
    salutation = json['salutation'];
    corporate = json['corporate'];
    bankCurrency = json['bank_currency'];
    bankAccountName = json['bank_account_name'];
    bankCode = json['bank_code'];
    externalId = json['external_id'];
    token = json['token'];
    attCivilid = json['att_civilid'];
    attTaxid = json['att_taxid'];
    attLicense = json['att_license'];
    attSaving = json['att_saving'];
    attSiup = json['att_siup'];
    attProfile = json['att_profile'];
    rejectionNote = json['rejection_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['account_status'] = this.accountStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['post_test'] = this.postTest;
    data['pre_test'] = this.preTest;
    data['id_number'] = this.idNumber;
    data['user_id'] = this.userId;
    data['address'] = this.address;
    data['place_of_birth'] = this.placeOfBirth;
    data['date_of_birth'] = this.dateOfBirth;
    data['phone_number'] = this.phoneNumber;
    data['bank_name'] = this.bankName;
    data['bank_account_number'] = this.bankAccountNumber;
    data['civil_id'] = this.civilId;
    data['tax_id'] = this.taxId;
    data['license_number'] = this.licenseNumber;
    data['gender'] = this.gender;
    data['pic'] = this.pic;
    data['city'] = this.city;
    data['province'] = this.province;
    data['zip_code'] = this.zipCode;
    data['salutation'] = this.salutation;
    data['corporate'] = this.corporate;
    data['bank_currency'] = this.bankCurrency;
    data['bank_account_name'] = this.bankAccountName;
    data['bank_code'] = this.bankCode;
    data['external_id'] = this.externalId;
    data['token'] = this.token;
    data['att_civilid'] = this.attCivilid;
    data['att_taxid'] = this.attTaxid;
    data['att_license'] = this.attLicense;
    data['att_saving'] = this.attSaving;
    data['att_siup'] = this.attSiup;
    data['att_profile'] = this.attProfile;
    data['rejection_note'] = this.rejectionNote;
    return data;
  }
}
