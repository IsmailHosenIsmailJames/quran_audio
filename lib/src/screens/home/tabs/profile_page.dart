import 'dart:convert';

import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/screens/auth/auth_controller/auth_controller.dart';
import 'package:al_quran_audio/src/screens/auth/login/login_page.dart';
import 'package:al_quran_audio/src/screens/home/controller/home_page_controller.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../functions/safe_substring.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthController authController = Get.find<AuthController>();
  final AudioController audioController = Get.find<AudioController>();
  final HomePageController homePageController = Get.find<HomePageController>();
  bool backUpAsync = false;

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
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Text(
                          user.email.substring(0, 2).toUpperCase(),
                        ),
                      ),
                      const Gap(10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            safeSubString(user.email, 25),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Gap(5),
                          Text(
                            "ID: ${user.$id}",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey.shade400),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const Gap(10),
              Text(
                (!isBackedUp)
                    ? "Your Playlists need to backup."
                    : "Your Playlists are up to date",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              if (!isBackedUp && allPlaylist.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        backUpAsync = true;
                      });
                      String? error = await homePageController.backupPlayList();
                      setState(() {
                        backUpAsync = false;
                      });
                      if (error == null) {
                        toastification.show(
                          context: context,
                          title: const Text("Successful"),
                          description: const Text("Backup process successful"),
                          type: ToastificationType.success,
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                      } else {
                        toastification.show(
                          context: context,
                          title: const Text("Error"),
                          description: Text(error),
                          type: ToastificationType.error,
                          autoCloseDuration: const Duration(seconds: 5),
                        );
                      }
                    },
                    icon: const Icon(Icons.backup_rounded),
                    label: const Text(
                      "Backup Now",
                    ),
                  ),
                ),
              const Gap(20),
              const Center(
                child: Text(
                  "Note: We are working on more features...\nStay tuned!",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
