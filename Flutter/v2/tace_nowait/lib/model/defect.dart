import 'dart:convert';

class Defect {
  int id;
  String projectname;
  String name;
  String detail;
  String location;
  String checker;
  bool uploaded;

  Defect({
      this.id,
      this.projectname,
      this.name,
      this.detail,
      this.location,
      this.checker,
      this.uploaded});

  factory Defect.fromJson(Map<String, dynamic> json) => Defect(
      id: json["id"],
      projectname: json["projectname"],
      name: json["name"],
      detail: json["detail"],
      location: json["location"],
      checker: json["checker"],
      uploaded: json["uploaded"] == 1
  );

  Map<String, dynamic> toJson() => {
        "id": id,
        "projectname": projectname,
        "name": name,
        "detail": detail,
        "location": location,
        "checker": checker,
        "uploaded": uploaded ? 1 : 0
      };

  List<Defect> defectFromJson(String str) =>
      List<Defect>.from(json.decode(str).map((x) => Defect.fromJson(x)));

  String defectToJson(List<Defect> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}
