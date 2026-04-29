class KalistenikLevel {
  final int? levelId;
  final String nama;

  KalistenikLevel({this.levelId, required this.nama});

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {'nama': nama};
    if (levelId != null) map['level_id'] = levelId!;
    return map;
  }

  factory KalistenikLevel.fromMap(Map<String, dynamic> map) {
    return KalistenikLevel(levelId: map['level_id'], nama: map['nama']);
  }
}
