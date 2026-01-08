// ignore_for_file: public_member_api_docs, sort_constructors_first

class Player {
  final String nickname;
  final String socketID;
  final double points;
  final String playerType;
  Player({
    required this.nickname,
    required this.socketID,
    required this.points,
    required this.playerType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nickname': nickname,
      'socketID': socketID,
      'points': points,
      'playerType': playerType,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      nickname: map['nickname']??'',
      socketID: map['socketID']??'',
      points: (map['points']??0).toDouble(),
      playerType: map['playerType']??'',
    );
  }

  Player copyWith({
    String? nickname,
    String? socketID,
    double? points,
    String? playerType,
  }) {
    return Player(
      nickname: nickname ?? this.nickname,
      socketID: socketID ?? this.socketID,
      points: points ?? this.points,
      playerType: playerType ?? this.playerType,
    );
  }
}
