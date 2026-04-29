import 'package:fluxfit/database/db_helper.dart';

class InitController {
  final DBHelper _dbHelper = DBHelper();

  Future<void> initDataKalistenik() async {
    final db = await _dbHelper.database;

    // cek apakah sudah ada data
    final existing = await db.query('kalistenik');

    if (existing.isNotEmpty) return; // 🔥 biar gak duplicate

    final batch = db.batch();

    final data = [
      {
        'nama': 'Arm Stretch',
        'gambar': 'assets/gifs/armstretch.gif',
        'deskripsi':
            'Rentangkan satu lengan ke depan atau menyilang ke dada, tahan beberapa detik lalu ganti sisi. Gerakan ini membantu melemaskan otot bahu dan lengan sebelum latihan.',
      },
      {
        'nama': 'Jumping Jack',
        'gambar': 'assets/gifs/jumpingjack.gif',
        'deskripsi':
            'Lompat sambil membuka kaki dan mengangkat tangan ke atas, lalu kembali ke posisi awal. Lakukan berulang dengan ritme stabil untuk meningkatkan detak jantung.',
      },
      {
        'nama': 'Push Up',
        'gambar': 'assets/gifs/pushup1.gif',
        'deskripsi':
            'Turunkan tubuh secara perlahan dengan menekuk siku, lalu dorong kembali ke atas. Jaga posisi tubuh tetap lurus untuk melatih dada, bahu, dan lengan.',
      },
      {
        'nama': 'Burpee',
        'gambar': 'assets/gifs/burpee.gif',
        'deskripsi':
            'Mulai dari berdiri, turun ke posisi squat, lanjut ke plank, lalu kembali berdiri sambil melompat. Latihan ini melatih kekuatan dan kardio secara bersamaan.',
      },
      {
        'nama': 'Side to Side Plank',
        'gambar': 'assets/gifs/sidetosideplank.gif',
        'deskripsi':
            'Mulai dari posisi plank, gerakkan tubuh ke kiri dan kanan secara bergantian. Jaga core tetap kencang untuk melatih otot perut dan stabilitas tubuh.',
      },
      {
        'nama': 'Sky Reach Squat',
        'gambar': 'assets/gifs/burpee.gif',
        'deskripsi':
            'Lakukan squat, lalu saat berdiri angkat satu tangan ke atas secara bergantian. Gerakan ini melatih kaki sekaligus fleksibilitas tubuh bagian atas.',
      },
      {
        'nama': 'Hand Walkout',
        'gambar': 'assets/gifs/handwalkout.gif',
        'deskripsi':
            'Dari posisi berdiri, bungkukkan tubuh lalu berjalan dengan tangan ke depan hingga posisi plank, lalu kembali lagi. Melatih core, bahu, dan fleksibilitas.',
      },
      {
        'nama': 'Hovering Sit Up',
        'gambar': 'assets/gifs/hoveringsitup.gif',
        'deskripsi':
            'Angkat tubuh seperti sit up, tapi tahan posisi di tengah beberapa detik sebelum turun. Fokus pada otot perut untuk meningkatkan kekuatan core.',
      },
      {
        'nama': 'Squat Kick',
        'gambar': 'assets/gifs/squatkick.gif',
        'deskripsi':
            'Lakukan squat lalu saat berdiri, tendang satu kaki ke depan secara bergantian. Gerakan ini melatih kaki, keseimbangan, dan koordinasi.',
      },
    ];

    for (var item in data) {
      batch.insert('kalistenik', item);
    }

    await batch.commit();
  }

  Future<void> initDataLevel() async {
    final db = await _dbHelper.database;

    final existing = await db.query('kalistenik_level');
    if (existing.isNotEmpty) return;

    await db.insert('kalistenik_level', {'nama': 'Pemula'});
    await db.insert('kalistenik_level', {'nama': 'Menengah'});
    await db.insert('kalistenik_level', {'nama': 'Advanced'});
  }

  Future<void> initDataKalistenikList() async {
    final db = await _dbHelper.database;

    final existing = await db.query('kalistenik_list');
    if (existing.isNotEmpty) return;

    final batch = db.batch();

    final data = [
      {'level_id': 1, 'kalistenik_id': 1, 'set_count': 10},
      {'level_id': 1, 'kalistenik_id': 2, 'set_count': 15},
      {'level_id': 1, 'kalistenik_id': 6, 'set_count': 15},
      {'level_id': 1, 'kalistenik_id': 3, 'set_count': 6},
      {'level_id': 1, 'kalistenik_id': 8, 'set_count': 8},
      {'level_id': 1, 'kalistenik_id': 5, 'set_count': 10},

      {'level_id': 2, 'kalistenik_id': 1, 'set_count': 24},
      {'level_id': 2, 'kalistenik_id': 2, 'set_count': 25},
      {'level_id': 2, 'kalistenik_id': 9, 'set_count': 24},
      {'level_id': 2, 'kalistenik_id': 3, 'set_count': 12},
      {'level_id': 2, 'kalistenik_id': 7, 'set_count': 8},
      {'level_id': 2, 'kalistenik_id': 8, 'set_count': 12},
      {'level_id': 2, 'kalistenik_id': 5, 'set_count': 16},

      {'level_id': 3, 'kalistenik_id': 1, 'set_count': 30},
      {'level_id': 3, 'kalistenik_id': 2, 'set_count': 30},
      {'level_id': 3, 'kalistenik_id': 4, 'set_count': 15},
      {'level_id': 3, 'kalistenik_id': 3, 'set_count': 20},
      {'level_id': 3, 'kalistenik_id': 9, 'set_count': 30},
      {'level_id': 3, 'kalistenik_id': 7, 'set_count': 10},
      {'level_id': 3, 'kalistenik_id': 8, 'set_count': 20},
      {'level_id': 3, 'kalistenik_id': 5, 'set_count': 40},
    ];

    for (var item in data) {
      batch.insert('kalistenik_list', item); // 🔥 FIX
    }

    await batch.commit();
  }
}
