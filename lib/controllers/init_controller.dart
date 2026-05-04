import 'package:fluxfit/database/db_helper.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<void> initDataAlat() async {
    final db = await _dbHelper.database;

    final existing = await db.query('alat');
    if (existing.isNotEmpty) return;

    final batch = db.batch();

    final data = [
      {
        'nama': 'Barbell',
        'harga': 750000,
        'deskripsi':
            'Alat angkat beban dengan batang panjang dan piringan di kedua sisi, digunakan untuk latihan kekuatan seperti squat dan bench press.',
        'gambar':
            'https://down-id.img.susercontent.com/file/aafa8d731eb22493b586fb1da60790c6',
      },
      {
        'nama': 'Dumbbell',
        'harga': 150000,
        'deskripsi':
            'Beban tangan yang digunakan untuk berbagai latihan otot seperti bicep curl dan shoulder press.',
        'gambar':
            'https://contents.mediadecathlon.com/p2720115/k\$e7a02b9ee16e1e9e77f0a9d35de269b8/hex-dumbel-latihan-beban-dan-cross-training-5-kg-hitam-corength-8603281.jpg?f=1920x0&format=auto',
      },
      {
        'nama': 'Yoga Mat',
        'harga': 120000,
        'deskripsi':
            'Matras empuk untuk latihan yoga, stretching, dan workout agar lebih nyaman dan tidak licin.',
        'gambar':
            'https://contents.mediadecathlon.com/p2939785/k\$84ca93a383ab82ea901a517640dc2590/matras-yoga-ringan-8-mm-burgundy-kimjaly-8644104.jpg?f=1920x0&format=auto',
      },
      {
        'nama': 'Resistance Band',
        'harga': 50000,
        'deskripsi':
            'Karet elastis untuk latihan kekuatan dan fleksibilitas, cocok untuk pemula hingga advanced.',
        'gambar':
            'https://m.media-amazon.com/images/I/61jI-MIOlzL._AC_UF894,1000_QL80_.jpg',
      },
      {
        'nama': 'Kettlebell',
        'harga': 200000,
        'deskripsi':
            'Beban berbentuk bola dengan pegangan, digunakan untuk latihan seperti swing dan deadlift.',
        'gambar':
            'https://i5.walmartimages.com/seo/Athletic-Works-50lb-Kettlebell-Casting-Iron-Durable-Black-Hammertone-Finish-Black_1e11a095-8d01-444f-b8e2-0d72f1db6ada.8f4ceeb6877593a07da129885292521a.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF',
      },
      {
        'nama': 'Pull-Up Bar',
        'harga': 180000,
        'deskripsi':
            'Alat yang dipasang di pintu untuk latihan pull-up dan chin-up.',
        'gambar':
            'https://grosiralatfitnes.com/wp-content/uploads/2024/08/WhatsApp-Image-2024-08-10-at-17.43.30-2.jpeg',
      },
      {
        'nama': 'Skipping Rope',
        'harga': 40000,
        'deskripsi':
            'Tali lompat untuk latihan kardio yang efektif membakar kalori.',
        'gambar':
            'https://hartsport.co.nz/cdn/shop/files/hart-1-8m-hart-skipping-ropes-6-300-1-8-32466559893578.jpg?v=1737583922',
      },
      {
        'nama': 'Foam Roller',
        'harga': 90000,
        'deskripsi': 'Alat untuk pijat otot dan recovery setelah latihan.',
        'gambar':
            'https://www.medco-athletics.com/media/catalog/product/6/1/6126vho0ycl._ac_sl1350_.jpg?optimize=low&bg-color=255,255,255&fit=bounds&height=700&width=700&canvas=700:700',
      },
      {
        'nama': 'Treadmill',
        'harga': 3000000,
        'deskripsi':
            'Alat kardio untuk berjalan atau berlari di dalam ruangan.',
        'gambar':
            'https://www.ireborn.co.id/wp-content/uploads/2020/10/X8-Treadmill-Elektrik-Cover-NEW.jpg',
      },
      {
        'nama': 'Stationary Bike',
        'harga': 2500000,
        'deskripsi': 'Sepeda statis untuk latihan kardio di rumah.',
        'gambar':
            'https://chrissports.com/cdn/shop/files/2_TRAX_recumbent_bike_stationary_Chris_Sports_6_800x.jpg?v=1708419502',
      },
    ];

    for (var item in data) {
      batch.insert(
        'alat',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      ); // 🔥 FIX
    }

    await batch.commit();
  }
}
