// File: app_drawer.dart
import 'package:flutter/material.dart';
import 'riwayat_absensi.dart';
import 'homescreen.dart';
import 'package:absensi_gps/auth/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final String username;
  const AppDrawer({Key? key, this.username = "Username"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                username,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Absensi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => homescreen(username: username),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Riwayat Absensi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RiwayatAbsensiPage(username: username),
                ),
              );
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Keluar'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
