import 'package:flutter/material.dart';

enum TingkatMateri { dasar, menengah, lanjutan }

extension TingkatMateriLabel on TingkatMateri {
  String get label => switch (this) {
    TingkatMateri.dasar => 'Dasar',
    TingkatMateri.menengah => 'Menengah',
    TingkatMateri.lanjutan => 'Lanjutan',
  };
}

class Materi {
  final IconData icon;
  final String judul;
  final String deskripsi;
  final String detail;
  final TingkatMateri tingkat;

  const Materi({
    required this.icon,
    required this.judul,
    required this.deskripsi,
    required this.detail,
    required this.tingkat,
  });
}

const List<Materi> daftarMateri = [
  Materi(
    icon: Icons.flutter_dash,
    judul: '1. Pengenalan Flutter & Dart',
    deskripsi: 'Memahami ekosistem, struktur project, dan cara kerja Flutter.',
    detail:
        'Flutter adalah SDK UI lintas platform yang menggunakan bahasa Dart. '
        'Pelajari fungsi folder lib, pubspec.yaml, package, hot reload, proses '
        'build, serta konsep bahwa tampilan Flutter tersusun dari widget.',
    tingkat: TingkatMateri.dasar,
  ),
  Materi(
    icon: Icons.code,
    judul: '2. Dasar Bahasa Dart',
    deskripsi: 'Sintaks, null safety, koleksi, fungsi, dan object-oriented.',
    detail:
        'Kuasai variabel final dan const, tipe nullable, operator, List, Map, '
        'Set, function, named parameter, class, inheritance, mixin, extension, '
        'generic, serta error handling dengan try-catch.',
    tingkat: TingkatMateri.dasar,
  ),
  Materi(
    icon: Icons.account_tree_outlined,
    judul: '3. Widget Tree & BuildContext',
    deskripsi: 'Mengenal susunan widget dan konteks di dalam tree.',
    detail:
        'Pelajari hubungan Widget, Element, dan RenderObject; fungsi BuildContext; '
        'penggunaan key; serta cara Flutter melakukan proses build dan update '
        'secara efisien ketika konfigurasi widget berubah.',
    tingkat: TingkatMateri.dasar,
  ),
  Materi(
    icon: Icons.widgets_outlined,
    judul: '4. Stateless, Stateful & Lifecycle',
    deskripsi: 'Memilih widget dan memahami siklus hidup state.',
    detail:
        'Gunakan StatelessWidget untuk UI tanpa state lokal dan StatefulWidget '
        'untuk state yang berubah. Pahami initState, didChangeDependencies, '
        'didUpdateWidget, setState, build, dan dispose agar resource dikelola aman.',
    tingkat: TingkatMateri.dasar,
  ),
  Materi(
    icon: Icons.dashboard_outlined,
    judul: '5. Layout & Responsive UI',
    deskripsi: 'Menyusun tampilan yang adaptif untuk berbagai ukuran layar.',
    detail:
        'Kombinasikan Row, Column, Stack, Flex, Expanded, Wrap, ListView, GridView, '
        'dan CustomScrollView. Gunakan MediaQuery, LayoutBuilder, SafeArea, serta '
        'constraint untuk membuat layout responsif dan mencegah overflow.',
    tingkat: TingkatMateri.dasar,
  ),
  Materi(
    icon: Icons.edit_note_outlined,
    judul: '6. Input, Form & Validation',
    deskripsi: 'Menerima input pengguna dengan validasi yang jelas.',
    detail:
        'Bangun form memakai Form, GlobalKey<FormState>, TextFormField, controller, '
        'focus, validator, checkbox, radio, dropdown, dan date picker. Tampilkan '
        'pesan kesalahan yang mudah dipahami dan selalu dispose controller.',
    tingkat: TingkatMateri.dasar,
  ),
  Materi(
    icon: Icons.navigation_outlined,
    judul: '7. Navigation & Routing',
    deskripsi: 'Mengatur perpindahan halaman dan data antar-route.',
    detail:
        'Pelajari Navigator.push, pop, named route, argument, hasil dari route, '
        'nested navigation, deep link, dan route guard. Untuk aplikasi kompleks, '
        'gunakan router deklaratif agar URL dan state navigasi konsisten.',
    tingkat: TingkatMateri.menengah,
  ),
  Materi(
    icon: Icons.sync_outlined,
    judul: '8. Asynchronous Programming',
    deskripsi: 'Mengelola Future, Stream, dan pekerjaan asynchronous.',
    detail:
        'Gunakan async-await untuk Future, Stream untuk data berkelanjutan, serta '
        'FutureBuilder dan StreamBuilder untuk UI. Tangani loading, sukses, kosong, '
        'error, pembatalan subscription, timeout, dan pekerjaan berat dengan isolate.',
    tingkat: TingkatMateri.menengah,
  ),
  Materi(
    icon: Icons.cloud_outlined,
    judul: '9. REST API & JSON',
    deskripsi: 'Mengambil, mengirim, dan memetakan data dari server.',
    detail:
        'Pahami HTTP method, header, status code, autentikasi, timeout, pagination, '
        'dan retry. Pisahkan model serta service, lakukan serialisasi JSON dengan '
        'type safety, dan tampilkan state loading, empty, error, serta success.',
    tingkat: TingkatMateri.menengah,
  ),
  Materi(
    icon: Icons.storage_outlined,
    judul: '10. Local Storage & Offline Data',
    deskripsi: 'Menyimpan preferensi, file, cache, dan data terstruktur.',
    detail:
        'Pilih penyimpanan sesuai kebutuhan: key-value untuk preferensi sederhana, '
        'file untuk dokumen, dan database lokal untuk data terstruktur. Rancang '
        'migration, cache invalidation, sinkronisasi, serta pengalaman offline.',
    tingkat: TingkatMateri.menengah,
  ),
  Materi(
    icon: Icons.hub_outlined,
    judul: '11. State Management',
    deskripsi: 'Mengelola state lokal dan state aplikasi secara terstruktur.',
    detail:
        'Mulai dari setState dan ValueNotifier, lalu pelajari pola Provider, '
        'Riverpod, atau BLoC. Pisahkan state dari UI, buat state immutable, tentukan '
        'single source of truth, dan hindari rebuild yang tidak diperlukan.',
    tingkat: TingkatMateri.menengah,
  ),
  Materi(
    icon: Icons.palette_outlined,
    judul: '12. Theme, Accessibility & Localization',
    deskripsi: 'Membuat aplikasi konsisten, inklusif, dan multibahasa.',
    detail:
        'Gunakan ThemeData dan ColorScheme untuk design system, dukung dark mode, '
        'text scaling, contrast, semantics, keyboard navigation, serta screen reader. '
        'Pisahkan string agar aplikasi dapat dilokalkan ke beberapa bahasa.',
    tingkat: TingkatMateri.menengah,
  ),
  Materi(
    icon: Icons.architecture_outlined,
    judul: '13. Architecture, SOLID & Repository',
    deskripsi:
        'Menyusun codebase besar dengan batas tanggung jawab yang jelas.',
    detail:
        'Pisahkan presentation, domain, dan data sesuai kompleksitas aplikasi. '
        'Gunakan prinsip SOLID, repository, use case, DTO, dan mapping model agar '
        'business logic mudah diuji serta detail API atau database mudah diganti.',
    tingkat: TingkatMateri.lanjutan,
  ),
  Materi(
    icon: Icons.extension_outlined,
    judul: '14. Dependency Injection & Modularization',
    deskripsi:
        'Mengurangi coupling dan membagi fitur menjadi modul terisolasi.',
    detail:
        'Masukkan dependency melalui constructor dan kelola lifecycle object pada '
        'composition root. Kelompokkan kode berdasarkan fitur, batasi public API '
        'setiap modul, serta hindari service locator global yang sulit diuji.',
    tingkat: TingkatMateri.lanjutan,
  ),
  Materi(
    icon: Icons.fact_check_outlined,
    judul: '15. Testing & Quality Assurance',
    deskripsi: 'Melindungi behavior dengan unit, widget, dan integration test.',
    detail:
        'Gunakan unit test untuk logic, widget test untuk interaksi UI, integration '
        'test untuk alur utama, dan golden test untuk visual stabil. Terapkan fake '
        'pada batas eksternal, uji error state, serta jalankan analyzer dan test di CI.',
    tingkat: TingkatMateri.lanjutan,
  ),
  Materi(
    icon: Icons.animation_outlined,
    judul: '16. Animation & Custom Graphics',
    deskripsi: 'Membuat motion yang halus dan visual khusus.',
    detail:
        'Mulai dari implicit animation, Hero, dan AnimatedSwitcher, kemudian gunakan '
        'AnimationController serta Tween untuk kontrol penuh. Pelajari CustomPainter, '
        'kurva animasi, gesture, dan cara menghindari animasi yang membebani frame.',
    tingkat: TingkatMateri.lanjutan,
  ),
  Materi(
    icon: Icons.phone_android_outlined,
    judul: '17. Platform Integration & Background Work',
    deskripsi: 'Mengakses kemampuan native dan proses di luar UI utama.',
    detail:
        'Integrasikan permission, kamera, lokasi, notifikasi, deep link, dan platform '
        'channel secara aman. Pahami lifecycle aplikasi, background task, pembatasan '
        'sistem operasi, serta penanganan ketika fitur perangkat tidak tersedia.',
    tingkat: TingkatMateri.lanjutan,
  ),
  Materi(
    icon: Icons.speed_outlined,
    judul: '18. Performance & DevTools',
    deskripsi:
        'Mengukur dan memperbaiki jank, rebuild, memory, dan ukuran aplikasi.',
    detail:
        'Gunakan Flutter DevTools untuk membaca frame timeline, CPU, memory, network, '
        'dan widget rebuild. Optimalkan berdasarkan hasil profiling dengan const '
        'widget, lazy list, image cache, repaint boundary, dan pemindahan kerja berat.',
    tingkat: TingkatMateri.lanjutan,
  ),
  Materi(
    icon: Icons.security_outlined,
    judul: '19. Application Security',
    deskripsi: 'Melindungi credential, data pengguna, dan komunikasi aplikasi.',
    detail:
        'Jangan menyimpan secret di source code. Gunakan secure storage untuk token, '
        'HTTPS, validasi input, autentikasi dan otorisasi yang benar, serta logging '
        'tanpa data sensitif. Ingat bahwa validasi utama tetap dilakukan di server.',
    tingkat: TingkatMateri.lanjutan,
  ),
  Materi(
    icon: Icons.rocket_launch_outlined,
    judul: '20. Release & CI/CD',
    deskripsi: 'Menyiapkan build produksi dan otomatisasi pengiriman aplikasi.',
    detail:
        'Atur environment, flavor, versioning, signing, icon, dan konfigurasi release. '
        'Gunakan pipeline CI/CD untuk format, analyze, test, build, dan distribusi. '
        'Tambahkan crash reporting, monitoring, serta strategi rollout dan rollback.',
    tingkat: TingkatMateri.lanjutan,
  ),
];

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: daftarMateri.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Materi Mobile Programming',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pelajari Flutter secara bertahap dari dasar hingga lanjutan.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
          );
        }

        final materi = daftarMateri[index - 1];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(materi.icon),
            ),
            title: Text(
              materi.judul,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(materi.deskripsi),
                const SizedBox(height: 6),
                _LevelBadge(tingkat: materi.tingkat),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(materi.detail),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.tingkat});

  final TingkatMateri tingkat;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tingkat.label),
      labelStyle: Theme.of(context).textTheme.labelSmall,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
