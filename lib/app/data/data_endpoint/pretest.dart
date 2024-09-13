class Pretest {
  int? code;
  String? status;
  String? message;
  List<Data>? data;

  Pretest({this.code, this.status, this.message, this.data});

  Pretest.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? quizId;
  String? question;
  List<String>? choices;

  Data({this.id, this.quizId, this.question, this.choices});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    quizId = json['quiz_id'];
    question = json['question'];
    choices = json['choices'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['quiz_id'] = this.quizId;
    data['question'] = this.question;
    data['choices'] = this.choices;
    return data;
  }
}
