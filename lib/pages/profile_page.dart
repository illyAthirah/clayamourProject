import 'package:flutter/material.dart';
import 'package:clayamour/pages/favourite_page.dart';
import 'package:clayamour/pages/my_orders_page.dart';
import 'package:clayamour/pages/delivery_addresses_page.dart';
import 'package:clayamour/pages/edit_profile_page.dart';
import 'package:clayamour/pages/change_password_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _profileHeader(),
            const SizedBox(height: 24),

            _sectionCard(
              title: "My Activity",
              items: [
                _item(
                  Icons.receipt_long,
                  "My Orders",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                    );
                  },
                ),
                _item(
                  Icons.favorite_border,
                  "Favourites",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavouritePage()),
                    );
                  },
                ),
                _item(
                  Icons.location_on_outlined,
                  "Delivery Addresses",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeliveryAddressesPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            _sectionCard(
              title: "Account",
              items: [
                _item(
                  Icons.edit_outlined,
                  "Edit Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),

                _item(
                  Icons.lock_outline,
                  "Change Password",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                _item(Icons.notifications_none, "Notifications"),
              ],
            ),

            const SizedBox(height: 20),

            _sectionCard(
              title: "Support",
              items: [
                _item(Icons.help_outline, "Help Center"),
                _item(Icons.info_outline, "About ClayAmour"),
              ],
            ),

            const SizedBox(height: 28),

            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  // 👤 Profile header
  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primary.withOpacity(0.2),
            child: const Icon(Icons.person, size: 30, color: primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Aqilah Joharudin",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "qiqilala@gmail.com",
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📦 Section card
  Widget _sectionCard({required String title, required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  // 📄 List item
  Widget _item(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: textPrimary),
              ),
            ),
            const Icon(Icons.chevron_right, color: textSecondary),
          ],
        ),
      ),
    );
  }

  // 🚪 Logout
  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {
          // later: show confirmation dialog
        },
        child: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
