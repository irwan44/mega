class DetailLearning {
  int? code;
  String? status;
  String? message;
  Data? data;

  DetailLearning({this.code, this.status, this.message, this.data});

  DetailLearning.fromJson(Map<String, dynamic> json) {
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
  String? title;
  String? content;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  String? fileUpload;

  Data(
      {this.id,
        this.title,
        this.content,
        this.createdBy,
        this.createdAt,
        this.updatedAt,
        this.fileUpload});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fileUpload = json['file_upload'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['file_upload'] = this.fileUpload;
    return data;
  }
}
