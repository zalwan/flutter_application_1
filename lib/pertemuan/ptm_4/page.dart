import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget buildPertemuanPage() => const Pertemuan4Page();

class Pertemuan4Page extends StatelessWidget {
  const Pertemuan4Page({super.key});

  void showToast() {
    Fluttertoast.showToast(
      msg: "This is a toast message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert Dialog"),
          content: Text("This is an alert dialog"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('Toast dan alert dialog')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Halaman template untuk Pertemuan 4. '
                'Silakan kembangkan materi di file ini.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  showToast();
                },
                child: const Text('Show Toast'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  showAlertDialog(context);
                },
                child: const Text('Show Alert Dialog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
