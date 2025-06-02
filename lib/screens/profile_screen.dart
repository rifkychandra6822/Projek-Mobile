import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Mahasiswa TPM', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 24),
                const Text('Saran dan Kesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                  'Mata kuliah Teknologi Pemrograman Mobile sangat menarik karena memberikan pengalaman langsung membuat aplikasi mobile yang terhubung ke backend.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Logout', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
