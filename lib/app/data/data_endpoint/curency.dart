class Currency {
  int? code;
  String? status;
  String? message;
  Map<String, String>? data;

  Currency({this.code, this.status, this.message, this.data});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
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
