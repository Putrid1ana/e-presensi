import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nisnController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController kelasController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? selectedGender;

  @override
  void dispose() {
    nisnController.dispose();
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    kelasController.dispose();
    super.dispose();
  }

  Future<void> _register(BuildContext context) async {
    if (nisnController.text.isEmpty ||
        namaController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        kelasController.text.isEmpty ||
        selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok')),
      );
      return;
    }
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Simpan data profil ke Realtime Database
      final uid = credential.user?.uid;
      if (uid != null) {
        await FirebaseDatabase.instance.ref('profil/$uid').set({
          'namaLengkap': namaController.text.trim(),
          'nisn': nisnController.text.trim(),
          'jenisKelamin': selectedGender,
          'kelas': kelasController.text.trim(),
        });
      }
      await credential.user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registrasi berhasil, cek email untuk verifikasi!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmailVerificationScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Registrasi gagal';
      if (e.code == 'email-already-in-use') msg = 'Email sudah terdaftar';
      if (e.code == 'invalid-email') msg = 'Format email tidak valid';
      if (e.code == 'weak-password') msg = 'Password terlalu lemah';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: const Text('Registrasi Siswa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: nisnController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.badge),
                labelText: 'NISN',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                labelText: 'Nama Lengkap',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email),
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.transgender),
                labelText: 'Jenis Kelamin',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: kelasController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.class_),
                labelText: 'Kelas',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: 'Konfirmasi Password',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _register(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Daftar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
