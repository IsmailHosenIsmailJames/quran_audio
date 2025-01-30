import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/functions/tajweed_scripts_composer.dart';
import 'package:al_quran_audio/src/screens/home/controller/model/play_list_model.dart';
import 'package:al_quran_audio/src/screens/home/resources/surah_list.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/recitation_info/recitation_info_model.dart';
import '../../../core/surah_ayah_count.dart';
import '../../../functions/get_uthmani_tajweed.dart';
import '../../setup/pages/choice_default_recitation.dart';
import '../controller/home_page_controller.dart';
import '../home_page.dart';

class PlayTab extends StatefulWidget {
  final PersistentTabController? tabController;
  const PlayTab({super.key, this.tabController});

  @override
  State<PlayTab> createState() => _PlayTabState();
}

class _PlayTabState extends State<PlayTab> {
  final AudioController audioController = ManageQuranAudio.audioController;
  final HomePageController homePageController = Get.put(HomePageController());
  final AppThemeData themeController = Get.find<AppThemeData>();
  final ScrollController scrollController = ScrollController();
  final infoBox = Hive.box("info");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.tabController != null
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              title: const Text("Play Quran"),
              centerTitle: true,
            ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(top: 5, left: 5, right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Colors.grey.shade600.withValues(alpha: 0.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Reciter",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const Gap(10),
                    SizedBox(
                      height: 25,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          backgroundColor: Colors.green.shade800,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final result = await Get.to(() =>
                              const ChoiceDefaultRecitation(
                                  forChangeReciter: true));
                          if (result.runtimeType == ReciterInfoModel) {
                            audioController.currentReciterModel.value =
                                result as ReciterInfoModel;
                            if (audioController.currentPlayingSurah.value !=
                                -1) {
                              if (audioController.isPlaying.value) {
                                await ManageQuranAudio
                                    .playMultipleSurahAsPlayList(
                                  surahNumber:
                                      audioController.currentPlayingSurah.value,
                                );
                              } else {
                                await ManageQuranAudio
                                    .playMultipleSurahAsPlayList(
                                  surahNumber:
                                      audioController.currentPlayingSurah.value,
                                  playInstantly: false,
                                );
                              }
                            }
                          }
                        },
                        child: const Text("Change"),
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      audioController.currentReciterModel.value.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => (homePageController.selectForPlaylistMode.value == false)
                ? const SizedBox()
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.shade400.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(left: 5, right: 5, top: 5),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text("Adding to"),
                                const Gap(5),
                                Text(
                                  homePageController
                                      .nameOfEditingPlaylist.value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(5),
                            SizedBox(
                              height: 25,
                              child: Row(
                                children: [
                                  Text(
                                      "Selected: ${homePageController.selectedForPlaylist.length}"),
                                  const Spacer(),
                                  const Gap(5),
                                  OutlinedButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.only(
                                          left: 7, right: 7),
                                    ),
                                    onPressed: () {
                                      homePageController
                                          .selectForPlaylistMode.value = false;
                                      homePageController.selectedForPlaylist
                                          .clear();
                                    },
                                    icon: const Icon(Icons.close),
                                    label: const Text("Cancel"),
                                  ),
                                  const Gap(5),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      addSelectedDataToPlayList(context);
                                    },
                                    icon: const Icon(Icons.done),
                                    label: const Text("Done"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          Expanded(
            child: Scrollbar(
              controller: scrollController,
              interactive: true,
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 100),
                itemCount: surahInfo.length,
                itemBuilder: (context, index) {
                  PlayListModel currentPlaylist = PlayListModel(
                    reciter: audioController.currentReciterModel.value,
                    surahNumber: index,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      int startAyah = 0;
                      for (int i = 0; i < index; i++) {
                        startAyah += surahAyahCount[i];
                      }
                      showPopUpForQuranWithTajweedText(
                          context, index, startAyah);
                    },
                    child: Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
                      child: Obx(
                        () => Row(
                          children: [
                            const Gap(3),
                            SizedBox(
                              height: 34,
                              width: 34,
                              child: getPlayButton(index, audioController),
                            ),
                            const Gap(10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ("${index + 1}. ${surahInfo[index]['name_simple'] ?? ""}")
                                      .replaceAll("-", " "),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  (surahInfo[index]['revelation_place'] ?? "")
                                      .capitalizeFirst,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  (surahInfo[index]['name_arabic'] ?? "")
                                      .capitalizeFirst,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  surahAyahCount[index].toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const Gap(5),
                            if (homePageController
                                    .selectForPlaylistMode.value ==
                                false)
                              getPopUpButton(audioController, index, context,
                                  currentPlaylist),
                            if (homePageController
                                    .selectForPlaylistMode.value ==
                                true)
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Checkbox(
                                  value: homePageController.containsInPlaylist(
                                      audioController.currentReciterModel.value,
                                      index),
                                  onChanged: (value) {
                                    if (value == true) {
                                      homePageController.addToPlaylist(
                                        audioController
                                            .currentReciterModel.value,
                                        index,
                                      );
                                    } else {
                                      homePageController.removeToPlaylist(
                                          audioController
                                              .currentReciterModel.value,
                                          index);
                                    }
                                  },
                                ),
                              ),
                            if (homePageController
                                    .selectForPlaylistMode.value ==
                                true)
                              const Gap(8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> showPopUpForQuranWithTajweedText(
      BuildContext context, int index, int startAyah) {
    return showModalBottomSheet(
      showDragHandle: true,
      scrollControlDisabledMaxHeightRatio: 1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
      ),
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 1,
          minChildSize: 0.75,
          maxChildSize: 1,
          expand: true,
          snap: true,
          builder: (context, scrollController) {
            return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(
                  bottom: 100,
                  left: 10,
                  right: 10,
                  top: 10,
                ),
                itemCount: (surahAyahCount[(index)] / 10).ceil(),
                itemBuilder: (context, i) {
                  int ayahCount = surahAyahCount[index];
                  int start = i * 10 + 1;
                  int end = start + 10 + 1;
                  if (end > ayahCount) {
                    end = ayahCount;
                  }

                  List<InlineSpan> listOfAyahsSpanText = [];

                  for (int currentAyahNumber = start;
                      currentAyahNumber <= end;
                      currentAyahNumber++) {
                    // log("uthmani_tajweed/${(index) + 1}:$currentAyahNumber");
                    listOfAyahsSpanText.addAll(
                      getTajweedTexSpan(
                        infoBox.get(
                          "uthmani_tajweed/${(index) + 1}:$currentAyahNumber",
                          defaultValue: "",
                        ),
                      ),
                    );
                  }
                  if (listOfAyahsSpanText.isEmpty) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Text(
                            "Unable to load",
                            style: TextStyle(
                              fontSize: audioController.fontSizeArabic.value,
                            ),
                          ),
                          const Gap(10),
                          ElevatedButton.icon(
                            onPressed: () async {
                              toastification.show(
                                context: context,
                                title: const Text("Trying to download"),
                                description:
                                    const Text("Wait a bit until it's done"),
                              );
                              await getUthmaniTajweed();
                              toastification.show(
                                context: context,
                                title: const Text("Trying to download"),
                                description:
                                    const Text("Wait a bit until it's done"),
                              );

                              setState(() {});
                            },
                            icon: const Icon(
                                FluentIcons.arrow_download_24_regular),
                            label: const Text("Download"),
                          ),
                        ],
                      );
                    }
                  }
                  return Text.rich(TextSpan(children: listOfAyahsSpanText),
                      style: TextStyle(
                        fontSize: audioController.fontSizeArabic.value,
                      ));
                });
          },
        );
      },
    );
  }

  void addSelectedDataToPlayList(BuildContext context) async {
    await homePageController.saveToPlayList();
    homePageController.reloadPlayList();

    widget.tabController?.jumpToTab(1);
    toastification.show(
      context: context,
      title: const Text("Added to Playlist"),
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.success,
    );
  }

  PopupMenuButton<String> getPopUpButton(AudioController audioController,
      int index, BuildContext context, PlayListModel currentPlayModel) {
    final box = Hive.box('play_list');
    List<PlayListModel> favoriteListModel = [];
    List<String> favoriteList =
        List<String>.from(box.get("Favorite", defaultValue: []));
    bool isExitsInFavorite = false;

    for (String favorite in favoriteList) {
      final model = PlayListModel.fromJson(favorite);
      favoriteListModel.add(model);
      if (model.reciter.id == currentPlayModel.reciter.id &&
          model.surahNumber == currentPlayModel.surahNumber) {
        isExitsInFavorite = true;
      }
    }

    return PopupMenuButton(
      borderRadius: BorderRadius.circular(7),
      onSelected: (value) async {
        String url = ManageQuranAudio.makeAudioUrl(
            audioController.currentReciterModel.value,
            ManageQuranAudio.surahIDFromNumber(index + 1));

        if (value == "Favorite") {
          await addOrRemoveFavorite(
              favoriteListModel, isExitsInFavorite, currentPlayModel, context);
        } else if (value == "Playlist") {
          List<String> playListName =
              List<String>.from(Hive.box("play_list").keys.toList());
          await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                insetPadding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Gap(10),
                      const Text(
                        "Add to",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: playListName.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              minTileHeight: 50,
                              title: Text(playListName[index]),
                              onTap: () async {
                                homePageController.nameOfEditingPlaylist.value =
                                    playListName[index];
                                List<PlayListModel> playModelsList =
                                    getPlayList(playListName[index]);
                                bool isAlreadyExits = false;
                                for (var element in playModelsList) {
                                  if (element.reciter.id ==
                                          currentPlayModel.reciter.id &&
                                      element.surahNumber ==
                                          currentPlayModel.surahNumber) {
                                    isAlreadyExits = true;
                                    break;
                                  }
                                }
                                if (isAlreadyExits) {
                                  toastification.show(
                                    context: context,
                                    title: const Text("Already Exits"),
                                    type: ToastificationType.info,
                                    autoCloseDuration:
                                        const Duration(seconds: 2),
                                  );
                                } else {
                                  playModelsList.add(currentPlayModel);
                                  homePageController.selectedForPlaylist.value =
                                      playModelsList;
                                  homePageController.saveToPlayList();
                                  homePageController.reloadPlayList();
                                  Navigator.pop(context);
                                  toastification.show(
                                    context: context,
                                    title: Text(
                                      "Successfully added to ${playListName[index]}",
                                    ),
                                    autoCloseDuration:
                                        const Duration(seconds: 3),
                                    type: ToastificationType.success,
                                  );
                                }
                              },
                              trailing: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          // Add to playlist
          // toastification.show(
          //   context: context,
          //   title: const Text("Added to Playlist"),
          //   autoCloseDuration: const Duration(seconds: 2),
          // );
        } else if (value == "Download") {
          // Download
          launchUrl(
            Uri.parse(
              url,
            ),
            mode: LaunchMode.externalApplication,
          );
        } else if (value == "Share") {
          // Share
          final reciter = audioController.currentReciterModel.value;

          await Share.share(
            "Reciter: ${reciter.name}\nSurah: ${surahInfo[index]['name_simple']}\nSurah Number: ${index + 1}\nURL: $url",
          );
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: "Favorite",
            child: Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: isExitsInFavorite ? Colors.green : null,
                ),
                const Gap(7),
                Text(
                    "${isExitsInFavorite ? "Remove form" : "Add to"} Favorite"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "Playlist",
            child: Row(
              children: [
                Icon(Icons.playlist_add_rounded),
                Gap(7),
                Text("Add to Playlist"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "Download",
            child: Row(
              children: [
                Icon(Icons.download_rounded),
                Gap(7),
                Text("Download"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "Share",
            child: Row(
              children: [
                Icon(FluentIcons.share_24_filled),
                Gap(7),
                Text("Share"),
              ],
            ),
          ),
        ];
      },
      child: Container(
        height: 40,
        width: 20,
        decoration: BoxDecoration(
          color: Colors.grey.shade600.withValues(
            alpha: 0.2,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Icon(
          Icons.more_vert,
          size: 18,
        ),
      ),
    );
  }

  Future<void> addOrRemoveFavorite(
      List<PlayListModel> favoriteListModel,
      bool isExitsInFavorite,
      PlayListModel currentPlayModel,
      BuildContext context) async {
    homePageController.nameOfEditingPlaylist.value = "Favorite";
    homePageController.selectedForPlaylist.value = favoriteListModel;
    if (isExitsInFavorite) {
      homePageController.selectedForPlaylist.removeWhere((element) =>
          element.reciter.id == currentPlayModel.reciter.id &&
          element.surahNumber == currentPlayModel.surahNumber);
    } else {
      homePageController.selectedForPlaylist.add(currentPlayModel);
    }
    await homePageController.saveToPlayList();
    homePageController.reloadPlayList();
    setState(() {});

    // Add to favorite
    toastification.show(
      context: context,
      title:
          Text("${isExitsInFavorite ? "Removed form" : "Added to"} Favorite"),
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.success,
    );
  }

  List<PlayListModel> getPlayList(String playListName) {
    final box = Hive.box("play_list");
    List<PlayListModel> playlistModels = [];
    List<String> rawPlayModelsList =
        List<String>.from(box.get(playListName, defaultValue: []));

    for (String favorite in rawPlayModelsList) {
      final model = PlayListModel.fromJson(favorite);
      playlistModels.add(model);
    }
    return playlistModels;
  }
}
