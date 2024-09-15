class SubmitPretest {
  int? code;
  String? status;
  String? message;
  Data? data;

  SubmitPretest({this.code, this.status, this.message, this.data});

  SubmitPretest.fromJson(Map<String, dynamic> json) {
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
  int? totalQuestions;
  int? answeredQuestions;
  int? unansweredQuestions;
  int? wrongAnswers;
  int? correctAnswers;
  int? rank;

  Data(
      {this.totalQuestions,
        this.answeredQuestions,
        this.unansweredQuestions,
        this.wrongAnswers,
        this.correctAnswers,
        this.rank});

  Data.fromJson(Map<String, dynamic> json) {
    totalQuestions = json['total_questions'];
    answeredQuestions = json['answered_questions'];
    unansweredQuestions = json['unanswered_questions'];
    wrongAnswers = json['wrong_answers'];
    correctAnswers = json['correct_answers'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_questions'] = this.totalQuestions;
    data['answered_questions'] = this.answeredQuestions;
    data['unanswered_questions'] = this.unansweredQuestions;
    data['wrong_answers'] = this.wrongAnswers;
    data['correct_answers'] = this.correctAnswers;
    data['rank'] = this.rank;
    return data;
  }
}
