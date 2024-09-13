class Salutations {
  int? code;
  String? status;
  String? message;
  List<String>? data;

  Salutations({this.code, this.status, this.message, this.data});

  factory Salutations.fromJson(Map<String, dynamic> json) {
    return Salutations(
      code: json['code'],
      status: json['status'],
      message: json['message'],
      data: List<String>.from(json['data']),
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
