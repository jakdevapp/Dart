class Profile {
  int id;
  String photo;
  String drawphoto;
  String projectid;
  String projectname;
  String content;
  String audio;
  String datetimestamp;
  bool uploaded;

  Profile(
      {this.id,
      this.photo,
      this.drawphoto,
      this.projectid,
      this.projectname,
      this.content,
      this.audio,
      this.datetimestamp,
      this.uploaded});

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
        id: map['id'],
        photo: map['photo'],
        drawphoto: map['drawphoto'],
        projectid: map['projectid'],
        projectname: map['projectname'],
        content: map['content'],
        audio: map['audio'],
        datetimestamp: map['datetimestamp'],
        uploaded: map['uploaded'] == 1
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'photo': photo,
      'drawphoto': drawphoto,
      'projectid': projectid,
      'projectname': projectname,
      'content': content,
      'audio': audio,
      'datetimestamp': datetimestamp,
      'uploaded': uploaded ? 1 : 0
    };
    return map;
  }
}