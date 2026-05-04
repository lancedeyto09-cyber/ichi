import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService();

  bool _loading = true;
  bool _saving = false;

  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _barangayCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final auth = context.read<AuthService>();
      final data = await _profileService.getUserProfile();

      _usernameCtrl.text =
          (data?['username'] ?? auth.currentUser?.displayName ?? '').toString();
      _phoneCtrl.text = (data?['phone'] ?? '').toString();

      final address = Map<String, dynamic>.from(data?['address'] ?? {});

      _houseCtrl.text = (address['houseNumber'] ?? '').toString();
      _barangayCtrl.text = (address['barangay'] ?? '').toString();
      _cityCtrl.text = (address['municipalityOrCity'] ?? '').toString();
      _provinceCtrl.text = (address['province'] ?? '').toString();
      _zipCtrl.text = (address['zipCode'] ?? '').toString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    try {
      await _profileService.updateProfile(
        username: _usernameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        houseNumber: _houseCtrl.text.trim(),
        barangay: _barangayCtrl.text.trim(),
        municipalityOrCity: _cityCtrl.text.trim(),
        province: _provinceCtrl.text.trim(),
        zipCode: _zipCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _houseCtrl.dispose();
    _barangayCtrl.dispose();
    _cityCtrl.dispose();
    _provinceCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              _userInfo(auth),
                              const SizedBox(height: 20),
                              _field(_usernameCtrl, 'Username'),
                              _field(_phoneCtrl, 'Phone Number',
                                  keyboardType: TextInputType.phone),
                              const SizedBox(height: 10),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Saved Address',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _field(_houseCtrl, 'House Number / Street'),
                              _field(_barangayCtrl, 'Barangay'),
                              _field(_cityCtrl, 'Municipality or City'),
                              _field(_provinceCtrl, 'Province'),
                              _field(_zipCtrl, 'Zip Code',
                                  keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _saving ? null : _saveProfile,
                                  child: _saving
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : const Text('Save Profile'),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _menuItem(
                                icon: Icons.shopping_bag,
                                title: 'My Orders',
                                onTap: () {
                                  Navigator.pushNamed(context, '/user-orders');
                                },
                              ),
                              _menuItem(
                                icon: Icons.favorite,
                                title: 'Saved Items',
                                onTap: () {
                                  Navigator.pushNamed(context, '/favorites');
                                },
                              ),
                              const SizedBox(height: 20),
                              _logoutButton(context),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _userInfo(AuthService auth) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          child: Icon(Icons.person, size: 40),
        ),
        const SizedBox(height: 10),
        Text(
          auth.currentUser?.email ?? '',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.bgLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _logoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await context.read<AuthService>().signOut();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Logout'),
    );
  }
}
