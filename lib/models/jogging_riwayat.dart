class JoggingRiwayat {
  final int? joggingId;
  final int userId;
  final String datetimeStart;
  final String? datetimeEnd;
  final double? jarak;
  final int? langkah;

  JoggingRiwayat({
    this.joggingId,
    required this.userId,
    required this.datetimeStart,
    this.datetimeEnd,
    this.jarak,
    this.langkah,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'user_id': userId,
      'datetime_start': datetimeStart,
      'datetime_end': datetimeEnd,
      'jarak': jarak,
      'langkah': langkah,
    };
    if (joggingId != null) map['jogging_id'] = joggingId!;
    return map;
  }

  factory JoggingRiwayat.fromMap(Map<String, dynamic> map) {
    return JoggingRiwayat(
      joggingId: map['jogging_id'],
      userId: map['user_id'],
      datetimeStart: map['datetime_start'],
      datetimeEnd: map['datetime_end'],
      jarak: (map['jarak'] as num?)?.toDouble(),
      langkah: map['langkah'],
    );
  }
}
