class Kalistenik {
  final int? kalistenikId;
  final String nama;
  final String? deskripsi;
  final String? gambar;

  Kalistenik({
    this.kalistenikId,
    required this.nama,
    this.deskripsi,
    this.gambar,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'nama': nama,
      'deskripsi': deskripsi,
      'gambar': gambar,
    };
    if (kalistenikId != null) map['kalistenik_id'] = kalistenikId!;
    return map;
  }

  factory Kalistenik.fromMap(Map<String, dynamic> map) {
    return Kalistenik(
      kalistenikId: map['kalistenik_id'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      gambar: map['gambar'],
    );
  }
}
