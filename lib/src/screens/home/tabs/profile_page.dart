import 'dart:async';
import 'dart:convert';

import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/functions/audio_tracking/model.dart';
import 'package:al_quran_audio/src/screens/auth/auth_controller/auth_controller.dart';
import 'package:al_quran_audio/src/screens/home/controller/home_page_controller.dart';
import 'package:al_quran_audio/src/screens/home/resources/surah_list.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: MediaQuery.of(context).size.width < 900
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              title: const Text("Profile"),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
      body: ListView(
        children: [
          FutureBuilder(
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
                              await Get.toNamed('/login');
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
          ),
          const Gap(15),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Audio History",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Listened ${formatDuration(Duration(seconds: getTotalDurationInSeconds()))}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 50,
                  child: PopupMenuButton(
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onSelected: (value) {
                        setState(() {
                          sortBy = value.toString();
                        });
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            value: "surahIncreasing",
                            child: Text(
                              "Sort by increasing Surah Number",
                              style: TextStyle(
                                color: sortBy == "surahIncreasing"
                                    ? Colors.green
                                    : null,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: "surahDecreasing",
                            child: Text(
                              "Sort by decreasing Surah Number",
                              style: TextStyle(
                                color: sortBy == "surahDecreasing"
                                    ? Colors.green
                                    : null,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: "increasing",
                            child: Text(
                              "Sort by increasing surah duration",
                              style: TextStyle(
                                color: sortBy == "increasing"
                                    ? Colors.green
                                    : null,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: "decreasing",
                            child: Text(
                              "Sort by decreasing surah duration",
                              style: TextStyle(
                                color: sortBy == "decreasing"
                                    ? Colors.green
                                    : null,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: "increasingListened",
                            child: Text(
                              "Sort by increasing listened duration",
                              style: TextStyle(
                                color: sortBy == "increasingListened"
                                    ? Colors.green
                                    : null,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: "decreasingListened",
                            child: Text(
                              "Sort by decreasing listened duration",
                              style: TextStyle(
                                color: sortBy == "decreasingListened"
                                    ? Colors.green
                                    : null,
                              ),
                            ),
                          ),
                        ];
                      }),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.withValues(alpha: 0.05),
            ),
            child: StreamBuilder(
              stream: getPeriodicStream(),
              builder: (context, snapshot) {
                List<TrackingAudioModel> audioTrackingModelList =
                    getAudioTrackingModelList();
                return Column(
                  children: List.generate(
                    audioTrackingModelList.length,
                    (index) {
                      TrackingAudioModel currentTrackingModel =
                          audioTrackingModelList[index];
                      bool isDone =
                          currentTrackingModel.totalPlayedDurationInSeconds >=
                              currentTrackingModel.totalDurationInSeconds - 2;
                      bool didNotPlayed =
                          currentTrackingModel.totalPlayedDurationInSeconds ==
                                  0 &&
                              currentTrackingModel.totalDurationInSeconds == 1;
                      return getAudioHistoryOfSurahs(
                          currentTrackingModel, didNotPlayed, context, isDone);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String sortBy = "surahIncreasing";

  Padding getAudioHistoryOfSurahs(TrackingAudioModel currentTrackingModel,
      bool didNotPlayed, BuildContext context, bool isDone) {
    double width = MediaQuery.of(context).size.width;
    if (width > 800) {
      width = width / 3;
    }
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            child: FittedBox(
              child: Text(
                (currentTrackingModel.surahNumber + 1).toString(),
              ),
            ),
          ),
          const Gap(10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    surahInfo[currentTrackingModel.surahNumber]
                            ["name_simple"] ??
                        "",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(10),
                  (didNotPlayed)
                      ? const Text(
                          "Didn't played yet",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        )
                      : Text(
                          "Listened: ${formatDuration(Duration(seconds: currentTrackingModel.totalPlayedDurationInSeconds))} | Duration: ${formatDuration(Duration(seconds: currentTrackingModel.totalDurationInSeconds))}",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                ],
              ),
              SizedBox(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.75 -
                          ((isDone && didNotPlayed == false) ? 30 : 0),
                      child: LinearProgressIndicator(
                        value:
                            currentTrackingModel.totalPlayedDurationInSeconds /
                                currentTrackingModel.totalDurationInSeconds,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const Gap(5),
                    if (isDone && didNotPlayed == false)
                      const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Stream<int> getPeriodicStream() async* {
    yield* Stream.periodic(const Duration(seconds: 5), (_) {
      return 1;
    }).asyncMap(
      (value) async => value,
    );
  }

  List<TrackingAudioModel> getAudioTrackingModelList() {
    List<TrackingAudioModel> toReturn = [];
    final box = Hive.box("audio_track");
    for (int key = 0; key < 114; key++) {
      final value = box.get(key);
      TrackingAudioModel? model = value != null
          ? TrackingAudioModel.fromMap(
              Map<String, dynamic>.from(value),
            )
          : null;
      model ??= TrackingAudioModel(
          surahNumber: key,
          lastReciterId: audioController.currentReciterModel.value.id,
          totalDurationInSeconds: 1,
          totalPlayedDurationInSeconds: 0);

      toReturn.add(model);
    }

    if (sortBy == "surahIncreasing") {
      return toReturn;
    } else if (sortBy == "surahDecreasing") {
      return toReturn.reversed.toList();
    } else if (sortBy == "increasing") {
      toReturn.sort((a, b) => a.totalDurationInSeconds.compareTo(
            b.totalDurationInSeconds,
          ));
      return toReturn;
    } else if (sortBy == "decreasing") {
      toReturn.sort((a, b) => b.totalDurationInSeconds.compareTo(
            a.totalDurationInSeconds,
          ));
      return toReturn;
    } else if (sortBy == "increasingListened") {
      toReturn.sort((a, b) => a.totalPlayedDurationInSeconds.compareTo(
            b.totalPlayedDurationInSeconds,
          ));
      return toReturn;
    } else if (sortBy == "decreasingListened") {
      toReturn.sort((a, b) => b.totalPlayedDurationInSeconds.compareTo(
            a.totalPlayedDurationInSeconds,
          ));
      return toReturn;
    }

    return toReturn;
  }

  int getTotalDurationInSeconds() {
    int totalDurationInSeconds = 0;
    getAudioTrackingModelList().forEach((element) {
      totalDurationInSeconds += element.totalPlayedDurationInSeconds;
    });
    return totalDurationInSeconds;
  }

  String formatDuration(Duration duration) {
    return "${duration.inHours}:${duration.inMinutes % 60}:${duration.inSeconds % 60}";
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
                    ? cloudPlayListString?.isEmpty == true
                        ? "Your Playlists need to backup."
                        : "Backup changes to cloud"
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
                    label: Text(
                      cloudPlayListString?.isEmpty == true
                          ? "Backup Now"
                          : "Backup Changes",
                    ),
                  ),
                ),
              const Gap(20),
            ],
          );
        },
      ),
    );
  }
}
