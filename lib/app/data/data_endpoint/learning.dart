class Learning {
  int? id;
  String? title;
  String? content;
  String? fileUpload;
  String? createdBy;
  String? createdAt;
  String? updatedAt;

  Learning(
      {this.id,
        this.title,
        this.content,
        this.fileUpload,
        this.createdBy,
        this.createdAt,
        this.updatedAt});

  Learning.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    fileUpload = json['file_upload'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['file_upload'] = this.fileUpload;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
