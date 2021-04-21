class Project {
  int id;
  String projectid;
  String name;
  String detail;

  Project({this.id, this.projectid, this.name, this.detail});

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      projectid: map['projectid'],
      name: map['name'],
      detail: map['detail']
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'projectid': projectid,
      'name': name,
      'detail':detail
    };
    return map;
  }

  factory Project.fromJson(Map<String, dynamic> json) => Project(
      id: json["id"],
      projectid: json["projectid"],
      name: json["name"],
      detail: json['detail']
  );
}
