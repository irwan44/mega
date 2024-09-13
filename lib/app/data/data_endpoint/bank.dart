class Bank {
  int? code;
  String? status;
  String? message;
  Map<String, String>? data;

  Bank({this.code, this.status, this.message, this.data});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      code: json['code'],
      status: json['status'],
      message: json['message'],
      data: Map<String, String>.from(json['data']),
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
