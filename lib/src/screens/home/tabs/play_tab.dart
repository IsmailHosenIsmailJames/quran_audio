import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/screens/home/resources/surah_list.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

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
                    PopupMenuButton(
                      borderRadius: BorderRadius.circular(7),
                      onSelected: (value) {},
                      itemBuilder: (context) {
                        return [];
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
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
