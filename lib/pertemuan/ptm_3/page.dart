import 'package:flutter/material.dart';

Widget buildPertemuanPage() => const Pertemuan3Page();

class Pertemuan3Page extends StatelessWidget {
  const Pertemuan3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic List'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.alarm),
            title: Text('Alarm'),
            subtitle: Text('This is an alarm'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone'),
            subtitle: Text('This is a phone'),
          ),
          ListTile(
            leading: Icon(Icons.camera),
            title: Text('Camera'),
            subtitle: Text('This is a camera'),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Message'),
            subtitle: Text('This is a message'),
          ),
        ],
      ),
    );
  }
}
