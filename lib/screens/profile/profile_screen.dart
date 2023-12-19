import 'package:evakuvator/components/bottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'components/profile_menu.dart';
import 'components/profile_pic.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Size mediaSize;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Image.asset("assets/images/logo.png", width: mediaSize.width*0.4,),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "Mening profilim",
              icon: "assets/icons/User Icon.svg",
              press: () => {},
            ),
            ProfileMenu(
              text: "Bildirishnomalar",
              icon: "assets/icons/Bell.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Sozlamalar",
              icon: "assets/icons/Settings.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Bog'lanish",
              icon: "assets/icons/Call.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Chiqish",
              icon: "assets/icons/Log out.svg",
              press: () {
                var box = Hive.box('users');
                box.clear();
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationCustom(screenId: 2,),
    );
  }
}
