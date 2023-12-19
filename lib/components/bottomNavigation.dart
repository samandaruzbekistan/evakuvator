

import 'package:evakuvator/constants.dart';
import 'package:flutter/material.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class BottomNavigationCustom extends StatefulWidget {
  const BottomNavigationCustom({Key? key, required int screenId}) : super(key: key);

  @override
  State<BottomNavigationCustom> createState() => _BottomNavigationCustomState();
}

class _BottomNavigationCustomState extends State<BottomNavigationCustom> {
  int selectedIndex = 0;
  late PageController controller;

  @override
  Widget build(BuildContext context) {
    return SlidingClippedNavBar.colorful(
      backgroundColor: Colors.white,
      onButtonPressed: (index) {
        setState(() {
          selectedIndex = index;
        });
        controller.animateToPage(selectedIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuad);
      },
      iconSize: 30,
      selectedIndex: selectedIndex,
      barItems: [
        BarItem(
          icon: Icons.home,
          title: 'Bosh menu',
          activeColor: kPrimaryColor,
          inactiveColor: Colors.grey,
        ),
        BarItem(
          icon: Icons.history_edu_rounded,
          title: 'Buyurtmalarim',
          activeColor: kPrimaryColor,
          inactiveColor: Colors.grey,
        ),
        BarItem(
          icon: Icons.settings,
          title: 'Sozlamalar',
          activeColor: kPrimaryColor,
          inactiveColor: Colors.grey,
        ),
      ],
    );
  }
}
