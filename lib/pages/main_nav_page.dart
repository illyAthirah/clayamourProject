import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clayamour/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/pages/cart_page.dart';
import 'home_page.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:motion_tab_bar_v2/motion-badge.widget.dart';

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage>
    with TickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;

  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;

  final List<Widget> _pages = const [HomePage(), CartPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _motionTabBarController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.uid;
    return Scaffold(
      backgroundColor: background,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _motionTabBarController,
        children: _pages,
      ),
      bottomNavigationBar: uid == null
          ? _buildMotionTabBar(0)
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseService.userSubcollection(
                uid,
                'cart',
              ).snapshots(),
              builder: (context, snap) {
                final count = snap.data?.docs.length ?? 0;
                return _buildMotionTabBar(count);
              },
            ),
      floatingActionButton: _whatsappButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMotionTabBar(int cartCount) {
    return MotionTabBar(
      controller: _motionTabBarController,
      initialSelectedTab: "Home",
      useSafeArea: true,
      labels: const ["Home", "Cart", "Profile"],
      icons: const [
        Icons.home_rounded,
        Icons.shopping_bag_rounded,
        Icons.person_rounded,
      ],
      badges: [
        null,
        cartCount > 0
            ? MotionBadgeWidget(
                text: '$cartCount',
                textColor: Colors.white,
                color: AppColors.error,
                size: 18,
              )
            : null,
        null,
      ],
      tabSize: 50,
      tabBarHeight: 65,
      textStyle: TextStyle(
        fontSize: 12,
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      tabIconColor: Colors.grey.shade500,
      tabIconSize: 26.0,
      tabIconSelectedSize: 28.0,
      tabSelectedColor: primary,
      tabIconSelectedColor: Colors.white,
      tabBarColor: Colors.white,
      onTabItemSelected: (int value) {
        setState(() {
          _motionTabBarController!.index = value;
        });
      },
    );
  }

  // 💬 WhatsApp Floating Button
  Widget _whatsappButton() {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 80, // Safe distance above nav bar
        right: 12,
      ),
      child: FloatingActionButton.small(
        onPressed: _openWhatsApp,
        backgroundColor: const Color(0xFF25D366), // WhatsApp green
        elevation: 4,
        child: const Icon(
          Icons.chat_bubble_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  // 📱 Open WhatsApp with confirmation
  Future<void> _openWhatsApp() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 28),
            SizedBox(width: 12),
            Text(
              'Contact Seller',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Continue to chat with ClayAmour seller on WhatsApp?',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Open WhatsApp',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Open WhatsApp
    const phoneNumber = '601112233623'; // Replace with your WhatsApp business number
    const message = 'Hi ClayAmour! I need help.';

    final whatsappUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp. Please make sure it is installed.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening WhatsApp: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
