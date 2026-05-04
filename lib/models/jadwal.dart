class Jadwal {
  final int? jadwalId;
  final int userId;
  final String nama;
  final String? startTime;
  final String? endTime;
  final String? hari;

  Jadwal({
    this.jadwalId,
    required this.userId,
    required this.nama,
    this.startTime,
    this.endTime,
    this.hari,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'nama': nama,
      'start_time': startTime,
      'end_time': endTime,
      'hari': hari,
    };
  }

  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      jadwalId: map['jadwal_id'],
      userId: map['user_id'],
      nama: map['nama'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      hari: map['hari'],
    );
  }
}
