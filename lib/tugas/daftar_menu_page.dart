import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MenuItem {
  const MenuItem({required this.nama, required this.icon});

  final String nama;
  final IconData icon;
}

const List<MenuItem> daftarMenu = [
  MenuItem(nama: 'Menu 1 - Nasi Goreng', icon: Icons.rice_bowl),
  MenuItem(nama: 'Menu 2 - Mie Ayam', icon: Icons.ramen_dining),
  MenuItem(nama: 'Menu 3 - Ayam Geprek', icon: Icons.restaurant),
  MenuItem(nama: 'Menu 4 - Bakso', icon: Icons.soup_kitchen),
];

class DaftarMenuPage extends StatelessWidget {
  const DaftarMenuPage({super.key});

  void showToast() {
    Fluttertoast.showToast(
      msg: 'Selamat datang pada aplikasi ini!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void showKonfirmasiDialog(BuildContext context, String namaItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pilihan'),
          content: Text('Apakah Anda memilih $namaItem?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: 'Anda memilih $namaItem',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Pertemuan 4'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: showToast,
              child: const Text(
                'Daftar Menu Makanan Siap Saji',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: showToast,
              child: const Text('Klik untuk sapaan'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: daftarMenu.length,
                itemBuilder: (context, index) {
                  final menu = daftarMenu[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(menu.icon, color: Colors.deepOrange),
                      title: Text(menu.nama),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showKonfirmasiDialog(context, menu.nama),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
