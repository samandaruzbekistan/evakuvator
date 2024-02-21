import 'package:evakuvator/components/bottomNavigation.dart';
import 'package:evakuvator/constants.dart';
import 'package:evakuvator/firebase_api.dart';
import 'package:evakuvator/screens/new_order.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

import 'components/categories.dart';
import 'components/discount_banner.dart';
import 'components/home_header.dart';



class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              HomeHeader(),
              DiscountBanner(),
              // Categories(),
              InkWell(
                onTap: () async {
                  Get.to(NewOrder(category: "YTH", avatar: "eva_call",));
                  // var fcm;
                  // fcm = await FirebaseApi().getFCMToken();
                  // print(fcm);
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width*0.9),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFF5F6F9),),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 80),
                        child: Image.asset("assets/icons/eva_call.png"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Evakuator chaqirish",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25, color: kPrimaryColor),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationCustom(screenId:0),
    );
  }
}
