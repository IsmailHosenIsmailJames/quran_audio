import 'dart:convert';
import 'dart:developer';

import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/screens/auth/auth_controller/auth_controller.dart';
import 'package:al_quran_audio/src/screens/auth/login/login_page.dart';
import 'package:al_quran_audio/src/screens/home/controller/home_page_controller.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthController authController = Get.find<AuthController>();
  final AudioController audioController = Get.find<AudioController>();
  final HomePageController homePageController = Get.find<HomePageController>();

  Future<User?> loggedInUser() async {
    if (authController.loggedInUser.value == null) {
      return await authController.getUser();
    } else {
      return authController.loggedInUser.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loggedInUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Error"),
          );
        } else {
          User? user = snapshot.data;
          if (user == null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Get the best experience by logging in ->",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "You can save your favorite playlist to the cloud. And continue listening from where you left off. No need to worry about losing your playlist. We got you covered.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Get.to(() => const LoginPage());
                        setState(() {});
                      },
                      iconAlignment: IconAlignment.end,
                      child: const Row(
                        children: [
                          Spacer(),
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.fast_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return getUserUI(user);
          }
        }
      },
    );
  }

  Widget getUserUI(User user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Obx(
        () {
          final allPlaylist = homePageController.allPlaylistInDB.value;
          List<String> rawStringOfAllPlaylist = [];
          for (var element in allPlaylist) {
            rawStringOfAllPlaylist.add(element.toJson());
          }
          String? cloudPlayListString = Hive.box('cloud_play_list')
              .get("all_playlist", defaultValue: null);
          bool isBackedUp =
              cloudPlayListString == jsonEncode(rawStringOfAllPlaylist);
          return Text(isBackedUp ? "Backed up" : "Not backed up");
        },
      ),
    );
  }
}
