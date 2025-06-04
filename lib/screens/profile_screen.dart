import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../utils/hash_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('logged_in_username');

      if (username != null) {
        final userData = await DatabaseHelper.instance.getUser(username);
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      } else {
        // If no logged in user found, redirect to login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_username');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _showEditProfileDialog() async {
    final usernameController =
        TextEditingController(text: _userData?['username'] ?? '');
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Username tidak boleh kosong'
                          : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration:
                          const InputDecoration(labelText: 'Password Baru'),
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password tidak boleh kosong'
                          : null,
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                          labelText: 'Konfirmasi Password'),
                      obscureText: true,
                      validator: (value) => value != passwordController.text
                          ? 'Konfirmasi password tidak sama'
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setStateDialog(() => isLoading = true);
                            try {
                              final hashedPassword = HashUtil.hashPassword(
                                  passwordController.text);
                              final updatedUser = {
                                'username': usernameController.text,
                                'password': hashedPassword,
                              };
                              await DatabaseHelper.instance
                                  .updateUser(_userData!['id'], updatedUser);
                              // Update SharedPreferences jika username berubah
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('logged_in_username',
                                  usernameController.text);
                              Navigator.pop(context);
                              _loadUserData();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Profil berhasil diperbarui')),
                                );
                              }
                            } catch (e) {
                              setStateDialog(() => isLoading = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Gagal memperbarui profil: $e')),
                                );
                              }
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus Akun'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await DatabaseHelper.instance.deleteUser(_userData!['id']);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('logged_in_username');
                if (mounted) {
                  Navigator.pop(context); // close dialog
                  Navigator.pushReplacementNamed(context, '/');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Akun berhasil dihapus')),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus akun: $e')),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditProfileDialog,
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteAccountDialog,
            tooltip: 'Hapus Akun',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('No user data found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFFD4AF37),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'User Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                leading: const Icon(Icons.person_outline,
                                    color: Color(0xFFD4AF37)),
                                title: const Text(
                                  'Nama',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  _userData!['username'] ?? 'N/A',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.calendar_today,
                                    color: Color(0xFFD4AF37)),
                                title: const Text(
                                  'Terdaftar Sejak',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  DateTime.now().toString().split(' ')[0],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
