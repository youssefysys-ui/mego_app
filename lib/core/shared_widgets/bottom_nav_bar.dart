import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'home'.tr),
        BottomNavigationBarItem(icon: const Icon(Icons.category), label: 'categories'.tr),
        BottomNavigationBarItem(icon: const Icon(Icons.shopping_cart), label: 'cart'.tr),
        BottomNavigationBarItem(icon: const Icon(Icons.person), label: 'profile'.tr),
      ],
    );
  }
}
