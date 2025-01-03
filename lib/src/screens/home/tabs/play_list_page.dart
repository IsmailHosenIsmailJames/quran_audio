import 'dart:developer';

import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/core/surah_ayah_count.dart';
import 'package:al_quran_audio/src/screens/home/controller/home_page_controller.dart';
import 'package:al_quran_audio/src/screens/home/controller/model/play_list_model.dart';
import 'package:al_quran_audio/src/screens/home/resources/surah_list.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:toastification/toastification.dart';

class PlayListPage extends StatefulWidget {
  final PersistentTabController tabController;
  const PlayListPage({super.key, required this.tabController});

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  final HomePageController homePageController = Get.put(HomePageController());
  final AudioController audioController = Get.put(AudioController());
  final themeController = Get.find<AppThemeData>();
  final infoBox = Hive.box("info");
  List<int> expandedList = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final allPlayList = homePageController.allPlaylistInDB;
        return allPlayList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 75,
                      width: 75,
                      child: Obx(
                        () {
                          bool isDark = themeController.themeModeName.value ==
                                  "dark" ||
                              (themeController.themeModeName.value ==
                                      "system" &&
                                  MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark);

                          return Image(
                            image: const AssetImage(
                              "assets/empty-folder.png",
                            ),
                            color: isDark ? Colors.white : Colors.black,
                          );
                        },
                      ),
                    ),
                    const Gap(10),
                    const Text("No PlayList found"),
                    const Gap(10),
                    ElevatedButton.icon(
                      onPressed: createANewPlayList,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Create PlayList",
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(5),
                children: <Widget>[
                      Row(
                        children: [
                          Text("Total PlayList: ${allPlayList.length}"),
                          const Spacer(),
                          SizedBox(
                            height: 25,
                            child: ElevatedButton.icon(
                              onPressed: createANewPlayList,
                              icon: const Icon(Icons.add),
                              label: const Text("Create New PlayList"),
                            ),
                          ),
                        ],
                      ),
                    ] +
                    List<Widget>.generate(
                      allPlayList.keys.length,
                      (index) {
                        return getPlayListCards(allPlayList, index);
                      },
                    ),
              );
      },
    );
  }

  Card getPlayListCards(
      RxMap<String, List<PlayListModel>> allPlayList, int index) {
    String playListKey = allPlayList.keys.elementAt(index);
    final currentPlayList = allPlayList[playListKey];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  if (expandedList.contains(index)) {
                    expandedList.remove(index);
                  } else {
                    expandedList.add(index);
                  }
                });
              },
              child: Row(
                children: [
                  SizedBox(height: 40, width: 40, child: getPlayButton(index)),
                  const Gap(5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playListKey,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Text("Total: "),
                          Text(
                            "${currentPlayList?.length ?? 0}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    expandedList.contains(index)
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () {
                          toastification.show(
                            context: context,
                            title: const Text("Under Development"),
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.green),
                            Gap(7),
                            Text("Add New "),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          toastification.show(
                            context: context,
                            title: const Text("Under Development"),
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.edit, color: Colors.green),
                            Gap(7),
                            Text("Edit Name"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () async {
                          try {
                            Hive.box("info").delete("playlist_$playListKey");

                            homePageController.reloadPlayList();

                            toastification.show(
                              context: context,
                              title: const Text("Deleted"),
                              autoCloseDuration: const Duration(seconds: 2),
                            );
                          } catch (e) {
                            log(e.toString());
                          }
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            Gap(7),
                            Text("Delete Playlist"),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            animatedExpandedList(index, currentPlayList),
          ],
        ),
      ),
    );
  }

  AnimatedContainer animatedExpandedList(
      int index, List<PlayListModel>? currentPlayList) {
    ScrollController scrollController = ScrollController();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(10.0),
      height: expandedList.contains(index) ? 300 : 0,
      child: (expandedList.contains(index))
          ? Scrollbar(
              controller: scrollController,
              interactive: true,
              radius: const Radius.circular(10),
              thumbVisibility: true,
              child: ListView.builder(
                controller: scrollController,
                itemCount: currentPlayList?.length ?? 0,
                itemBuilder: (context, i) {
                  final playListModel = currentPlayList![i];
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8, top: 4, bottom: 4),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playListModel.reciter.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              surahInfo[playListModel.surahNumber]
                                      ['name_simple'] ??
                                  "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              "Total Ayah: ${surahAyahCount[playListModel.surahNumber]}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        getPlayButtonOnPlaylistList(
                            playListModel, i, index, currentPlayList),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () {
                                homePageController.nameOfEditingPlaylist.value =
                                    homePageController
                                        .allPlaylistInDB.value.keys
                                        .elementAt(index);
                                homePageController.selectedForPlaylist.value =
                                    homePageController
                                        .allPlaylistInDB.value.values
                                        .elementAt(index);
                                homePageController.selectedForPlaylist
                                    .removeAt(index);
                                homePageController.saveToPlayList();
                                homePageController.reloadPlayList();
                              },
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  Gap(7),
                                  Text("Delete"),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          : const SizedBox(),
    );
  }

  Widget getPlayButtonOnPlaylistList(PlayListModel playListModel, int i,
      int index, List<PlayListModel> currentPlayList) {
    return Obx(() => IconButton(
          icon: (audioController.currentReciterModel.value.id ==
                      playListModel.reciter.id &&
                  index == audioController.currentPlayListIndex.value &&
                  audioController.currentPlayingSurah.value == i &&
                  audioController.isPlaying.value)
              ? const Icon(
                  Icons.pause_rounded,
                )
              : const Icon(Icons.play_arrow_rounded),
          tooltip: "Play",
          style: IconButton.styleFrom(
            side: const BorderSide(),
          ),
          onPressed: () async {
            if (audioController.currentReciterModel.value.id ==
                    playListModel.reciter.id &&
                index == audioController.currentPlayListIndex.value &&
                audioController.currentPlayingSurah.value == i &&
                audioController.isPlaying.value) {
              await ManageQuranAudio.audioPlayer.pause();
              return;
            } else if (audioController.currentReciterModel.value.id ==
                    playListModel.reciter.id &&
                index == audioController.currentPlayListIndex.value &&
                audioController.currentPlayingSurah.value == i) {
              if (audioController.isReadyToControl.value == false) {
                List<LockCachingAudioSource> playList =
                    getPlayList(currentPlayList);
                await ManageQuranAudio.playProvidedPlayList(
                  playList: playList,
                  initialIndex: i,
                );
                return;
              }
              ManageQuranAudio.audioPlayer.play();
              return;
            }
            audioController.currentPlayListIndex.value = index;
            List<LockCachingAudioSource> playList =
                getPlayList(currentPlayList);
            await ManageQuranAudio.playProvidedPlayList(
              playList: playList,
              initialIndex: i,
            );
          },
        ));
  }

  IconButton getPlayButton(int index) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      tooltip: "Play or Pause",
      icon: (audioController.currentPlayListIndex.value == index &&
              audioController.isPlaying.value == true)
          ? const Icon(Icons.pause_rounded)
          : (audioController.currentPlayListIndex.value == index &&
                  audioController.isLoading.value)
              ? CircularProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  strokeWidth: 2,
                )
              : const Icon(Icons.play_arrow_rounded),
      onPressed: () async {
        // Play the PlayList
        if (audioController.isPlaying.value == true &&
            audioController.currentPlayListIndex.value == index) {
          await ManageQuranAudio.audioPlayer.pause();
        } else if ((audioController.isPlaying.value == true ||
                audioController.isLoading.value == true) &&
            audioController.currentPlayListIndex.value != index) {
          audioController.currentPlayListIndex.value = index;
          await ManageQuranAudio.audioPlayer.stop();
          List<LockCachingAudioSource> playList = getPlayList(
              homePageController.allPlaylistInDB.values.elementAt(index));

          await ManageQuranAudio.playProvidedPlayList(
            playList: playList,
          );
        } else if (audioController.isPlaying.value == false &&
            audioController.currentPlayListIndex.value == index) {
          if (audioController.isReadyToControl.value == false) {
            List<LockCachingAudioSource> playList = getPlayList(
                homePageController.allPlaylistInDB.values.elementAt(index));

            await ManageQuranAudio.playProvidedPlayList(
              playList: playList,
            );
          } else {
            await ManageQuranAudio.audioPlayer.play();
          }
        } else if (audioController.isPlaying.value == false &&
            audioController.currentPlayListIndex.value != index) {
          audioController.currentPlayListIndex.value = index;
          List<LockCachingAudioSource> playList = getPlayList(
              homePageController.allPlaylistInDB.values.elementAt(index));
          await ManageQuranAudio.playProvidedPlayList(
            playList: playList,
          );
        }
      },
    );
  }

  List<LockCachingAudioSource> getPlayList(List<PlayListModel> playList) {
    List<LockCachingAudioSource> playListAudioSource = [];
    for (var playListModel in playList) {
      playListAudioSource.add(
        LockCachingAudioSource(
          Uri.parse(
            ManageQuranAudio.makeAudioUrl(
              playListModel.reciter,
              ManageQuranAudio.surahIDFromNumber(playListModel.surahNumber + 1),
            ),
          ),
          tag: MediaItem(
            id: "${playListModel.reciter.id}${playListModel.surahNumber}",
            title: playListModel.reciter.name,
          ),
        ),
      );
    }
    return playListAudioSource;
  }

  createANewPlayList() async {
    showDialog(
      context: context,
      builder: (context) {
        final playListController = TextEditingController();
        bool isDark = themeController.themeModeName.value == "dark" ||
            (themeController.themeModeName.value == "system" &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return Dialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Name of the PlayList",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const Gap(10),
                Container(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 2,
                    bottom: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: TextFormField(
                    controller: playListController,
                    decoration: const InputDecoration(
                      hintText: "Enter the name of the PlayList",
                      border: InputBorder.none,
                    ),
                    autofocus: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the name of the PlayList";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                const Gap(10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (playListController.text.isNotEmpty) {
                        if (Hive.box('info')
                            .containsKey(playListController.text.trim())) {
                          toastification.show(
                            context: context,
                            title: const Text(
                                "PlayList already exists or name is not allowed"),
                            type: ToastificationType.error,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                        } else {
                          // Name is valid
                          Hive.box('info').put(
                            playListController.text.trim(),
                            [],
                          );
                          Navigator.pop(context);
                          homePageController.selectForPlaylistMode.value = true;
                          homePageController.nameOfEditingPlaylist.value =
                              playListController.text.trim();
                          widget.tabController.jumpToTab(0);
                        }
                      } else {
                        toastification.show(
                          context: context,
                          title:
                              const Text("Empty PlayList name is not allowed"),
                          type: ToastificationType.error,
                          autoCloseDuration: const Duration(seconds: 2),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Create PlayList",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
