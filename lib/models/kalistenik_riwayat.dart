class KalistenikRiwayat {
  final int? riwayatId;
  final int userId;
  final int levelId;
  final String datetime;
  final double? progress;

  KalistenikRiwayat({
    this.riwayatId,
    required this.userId,
    required this.levelId,
    required this.datetime,
    this.progress,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'user_id': userId,
      'level_id': levelId,
      'datetime': datetime,
      'progress': progress,
    };
    if (riwayatId != null) map['riwayat_id'] = riwayatId!;
    return map;
  }

  factory KalistenikRiwayat.fromMap(Map<String, dynamic> map) {
    return KalistenikRiwayat(
      riwayatId: map['riwayat_id'],
      userId: map['user_id'],
      levelId: map['level_id'],
      datetime: map['datetime'],
      progress: (map['progress'] as num?)?.toDouble(),
    );
  }
}
