class DefectMedia {
  int id;
  String photo;
  String drawphoto;
  String projectname;
  String name;
  String detail;
  String location;
  String checker;
  String audio;

  DefectMedia({
    this.id,
    this.photo,
    this.drawphoto,
    this.projectname,
    this.name,
    this.detail,
    this.location,
    this.checker,
    this.audio
  });

  factory DefectMedia.fromMap(Map<String, dynamic> map) {
    return DefectMedia(
        id: map['id'],
        photo: map['photo'],
        drawphoto: map['drawphoto'],
        projectname: map['projectname'],
        name: map['name'],
        detail: map['detail'],
        location: map['location'],
        checker: map['checker'],
        audio: map['audio']
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'photo': photo,
      'drawphoto': drawphoto,
      'projectname': projectname,
      'name': name,
      'detail': detail,
      'location': location,
      'checker': checker,
      'audio': audio
    };
    return map;
  }
}