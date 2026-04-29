class Checkin {
  final int? checkinId;
  final int userId;
  final String? datetime;

  Checkin({this.checkinId, required this.userId, this.datetime});

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {'user_id': userId, 'datetime': datetime};
    if (checkinId != null) map['checkin_id'] = checkinId!;
    return map;
  }

  factory Checkin.fromMap(Map<String, dynamic> map) {
    return Checkin(
      checkinId: map['checkin_id'],
      userId: map['user_id'],
      datetime: map['datetime'],
    );
  }
}
