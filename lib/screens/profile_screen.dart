import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

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
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _userInfo(auth),
                      const SizedBox(height: 20),
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
                      _menuItem(
                        icon: Icons.explore,
                        title: 'Explore',
                        onTap: () {
                          Navigator.pushNamed(context, '/explore');
                        },
                      ),
                      const Spacer(),
                      _logoutButton(context),
                    ],
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
          auth.currentUser?.displayName ?? 'User',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          auth.currentUser?.email ?? '',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
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
        await Provider.of<AuthService>(context, listen: false).signOut();
        Navigator.pushReplacementNamed(context, '/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Logout'),
    );
  }
}
