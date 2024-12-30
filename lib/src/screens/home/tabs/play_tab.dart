import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/screens/home/resources/surah_list.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/recitation_info/recitation_info_model.dart';
import '../../../core/surah_ayah_count.dart';
import '../../setup/pages/choice_default_recitation.dart';
import '../home_page.dart';

class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioController audioController = ManageQuranAudio.audioController;

    return Column(
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
                          if (audioController.currentPlayingSurah.value != -1) {
                            await ManageQuranAudio.playMultipleSurahAsPlayList(
                                surahNumber:
                                    audioController.currentPlayingSurah.value);
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
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 100),
            itemCount: surahInfo.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
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
                    getPopUpButton(audioController, index, context),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  PopupMenuButton<String> getPopUpButton(
      AudioController audioController, int index, BuildContext context) {
    return PopupMenuButton(
      borderRadius: BorderRadius.circular(7),
      onSelected: (value) async {
        String url = ManageQuranAudio.makeAudioUrl(
            audioController.currentReciterModel.value,
            ManageQuranAudio.surahIDFromNumber(index + 1));

        if (value == "Favorite") {
          // Add to favorite
          toastification.show(
            context: context,
            title: const Text("Added to Favorite"),
            autoCloseDuration: const Duration(seconds: 2),
          );
        } else if (value == "Playlist") {
          // Add to playlist
          toastification.show(
            context: context,
            title: const Text("Added to Playlist"),
            autoCloseDuration: const Duration(seconds: 2),
          );
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
          const PopupMenuItem(
            value: "Favorite",
            child: Row(
              children: [
                Icon(Icons.favorite_rounded),
                Gap(7),
                Text("Add to Favorite"),
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
}
