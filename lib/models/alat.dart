class Alat {
  final int? alatId;
  final String nama;
  final int harga;
  final String? deskripsi;
  final String? gambar;

  Alat({
    this.alatId,
    required this.nama,
    required this.harga,
    this.deskripsi,
    this.gambar,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'nama': nama,
      'harga': harga,
      'deskripsi': deskripsi,
      'gambar': gambar,
    };
    if (alatId != null) map['alat_id'] = alatId!;
    return map;
  }

  factory Alat.fromMap(Map<String, dynamic> map) {
    return Alat(
      alatId: map['alat_id'],
      nama: map['nama'],
      harga: map['harga'],
      deskripsi: map['deskripsi'],
      gambar: map['gambar'],
    );
  }
}
