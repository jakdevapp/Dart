class Room {
  int id;
  String roomid;

  Room({this.id, this.roomid});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'roomid': roomid
    };
    return map;
  }
}

class Asset {
  int id;
  String datetimestamp;
  String roomid;
  String assetid;
  String ownerid;
  String title;
  String detail;
  String photo;
  String damagedetail;
  bool damage;

  Asset({this.id, this.datetimestamp, this.roomid, this.assetid, this.ownerid,
    this.title, this.detail, this.photo, this.damagedetail, this.damage});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'datetimestamp': datetimestamp,
      'roomid': roomid,
      'assetid': assetid,
      'ownerid': ownerid,
      'title': title,
      'detail': detail,
      'photo': photo,
      'damagedetail': damagedetail,
      'damage': damage ? 1 : 0
    };
    return map;
  }
}

