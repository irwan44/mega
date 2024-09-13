class Provinsi {
  int? code;
  String? status;
  String? message;
  Map<String, String>? data;

  Provinsi({this.code, this.status, this.message, this.data});

  factory Provinsi.fromJson(Map<String, dynamic> json) {
    return Provinsi(
      code: json['code'] as int?,
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? Map<String, String>.from(json['data'].map((k, v) => MapEntry(k as String, v as String)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status,
      'message': message,
      'data': data,
    };
  }
}
