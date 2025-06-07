import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/database_helper.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool isEditing = false;
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController nimCtrl = TextEditingController();
  final TextEditingController kesanPesanCtrl = TextEditingController();
  String? _imagePath;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final users = await DatabaseHelper.instance.getAllUsers();
    if (users.isNotEmpty) {
      setState(() {
        user = User.fromMap(users.first);
        usernameCtrl.text = user!.username;
        emailCtrl.text = user!.email ?? '';
        nimCtrl.text = user!.nim ?? '';
        kesanPesanCtrl.text = user!.kesanPesan ?? '';
        _imagePath = user!.profilePicture;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front, // Selalu gunakan kamera depan (webcam laptop)
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Untuk platform web
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _imagePath = pickedFile.path;
          });
        } else {
          // Untuk platform mobile
          setState(() {
            _imagePath = pickedFile.path;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera Laptop'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (kIsWeb) {
      if (_webImage != null) {
        return CircleAvatar(
          radius: 60,
          backgroundColor: Colors.amber[800],
          backgroundImage: MemoryImage(_webImage!),
        );
      }
    } else {
      if (_imagePath != null) {
        return CircleAvatar(
          radius: 60,
          backgroundColor: Colors.amber[800],
          backgroundImage: FileImage(File(_imagePath!)),
        );
      }
    }
    
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.amber[800],
      child: const Icon(Icons.person, size: 60, color: Colors.white),
    );
  }

  Future<void> updateProfile() async {
    if (user == null) return;
    final updatedUser = user!.toMap();
    updatedUser['username'] = usernameCtrl.text.trim();
    updatedUser['email'] = emailCtrl.text.trim();
    updatedUser['nim'] = nimCtrl.text.trim();
    updatedUser['kesan_pesan'] = kesanPesanCtrl.text.trim();
    updatedUser['profile_picture'] = _imagePath;
    
    if (kIsWeb && _webImage != null) {
      // Save image data for web
      updatedUser['profile_picture_data'] = _webImage;
    }
    
    await DatabaseHelper.instance.updateUser(updatedUser);
    setState(() {
      isEditing = false;
      user = User.fromMap(updatedUser);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
  }

  Future<void> deleteProfile() async {
    if (user == null) return;
    await DatabaseHelper.instance.deleteUser(user!.id!);
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.amber[800],
        elevation: 0,
        actions: user == null
            ? null
            : [
                IconButton(
                  icon: Icon(isEditing ? Icons.save : Icons.edit),
                  tooltip: isEditing ? 'Simpan' : 'Edit',
                  onPressed: isEditing ? updateProfile : () => setState(() => isEditing = true),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Hapus',
                  onPressed: deleteProfile,
                ),
              ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: isEditing ? _showImageSourceDialog : null,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildProfileImage(),
                                if (isEditing)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.amber[800],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('Nama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          isEditing
                              ? TextField(
                                  controller: usernameCtrl,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                )
                              : Text(user!.username, style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          isEditing
                              ? TextField(
                                  controller: emailCtrl,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                )
                              : Text(user!.email ?? '-', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          Text('NIM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          isEditing
                              ? TextField(
                                  controller: nimCtrl,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                )
                              : Text(user!.nim ?? '-', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          Text('Kesan & Pesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          isEditing
                              ? TextField(
                                  controller: kesanPesanCtrl,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    prefixIcon: Icon(Icons.message_outlined),
                                  ),
                                )
                              : Text(user!.kesanPesan ?? '-', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
