import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clayamour/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/pages/cart_page.dart';
import 'home_page.dart';
import 'package:clayamour/services/firebase_service.dart';

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _currentIndex = 0;

  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);

  final List<Widget> _pages = const [HomePage(), CartPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.uid;
    return Scaffold(
      backgroundColor: background,
      body: _pages[_currentIndex],
      bottomNavigationBar: uid == null
          ? _navBar(0)
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseService.userSubcollection(uid, 'cart').snapshots(),
              builder: (context, snap) {
                final count = snap.data?.docs.length ?? 0;
                return _navBar(count);
              },
            ),
    );
  }

  BottomNavigationBar _navBar(int cartCount) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          label: 'Cart',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_bag_outlined),
              if (cartCount > 0)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE57373),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
