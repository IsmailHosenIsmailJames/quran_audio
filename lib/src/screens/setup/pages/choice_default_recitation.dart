import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/core/audio/widget_audio_controller.dart';
import 'package:al_quran_audio/src/core/recitation_info/recitation_info_model.dart';
import 'package:al_quran_audio/src/core/recitation_info/recitations.dart';
import 'package:al_quran_audio/src/theme/colors.dart';
import 'package:al_quran_audio/src/theme/theme_icon_button.dart';
import 'package:al_quran_audio/widget/warper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/audio/controller/audio_controller.dart';

class ChoiceDefaultRecitation extends StatefulWidget {
  final bool? forChangeReciter;
  const ChoiceDefaultRecitation({super.key, this.forChangeReciter});

  @override
  State<ChoiceDefaultRecitation> createState() =>
      _ChoiceDefaultRecitationState();
}

class _ChoiceDefaultRecitationState extends State<ChoiceDefaultRecitation> {
  AudioController audioControllerGetx = ManageQuranAudio.audioController;
  String search = "";
  @override
  Widget build(BuildContext context) {
    return warperWithCenter(
      width: 600,
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: widget.forChangeReciter == true
              ? const Text("Change Reciter")
              : const Text("Choice Default Reciter"),
          actions: [
            if (widget.forChangeReciter == false) themeIconButton,
          ],
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            ListView.builder(
              padding:
                  const EdgeInsets.only(left: 5, right: 5, top: 50, bottom: 60),
              itemCount: recitationsInfoList.length,
              itemBuilder: (context, index) {
                final current =
                    ReciterInfoModel.fromMap(recitationsInfoList[index]);
                if (!(current.name + current.id)
                    .toLowerCase()
                    .contains(search.toLowerCase())) {
                  return const SizedBox();
                }
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    await Hive.box("info")
                        .put("default_reciter", current.toJson());
                    audioControllerGetx.setupSelectedReciterIndex.value = index;
                    Get.back(result: current);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        (widget.forChangeReciter == true)
                            ? const SizedBox(
                                height: 30,
                              )
                            : SizedBox(
                                height: 40,
                                width: 40,
                                child: getPlayButton(current, index),
                              ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(left: 10),
                            scrollDirection: Axis.horizontal,
                            child: Text(current.name),
                          ),
                        ),
                        Obx(
                          () => (index !=
                                  audioControllerGetx
                                      .setupSelectedReciterIndex.value)
                              ? const SizedBox()
                              : Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: MyColors.mainColor,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                                255, 132, 119, 119)
                                            .withValues(alpha: 0.4),
                                        spreadRadius: 5,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              height: 40,
              child: SearchBar(
                leading: const Icon(Icons.search),
                hintText: "Search",
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
              ),
            ),
            Obx(
              () => Align(
                alignment: const Alignment(1, 0.8),
                child: (audioControllerGetx.isReadyToControl.value == true)
                    ? const WidgetAudioController(
                        showSurahNumber: true,
                        showQuranAyahMode: false,
                        surahNumber: 1,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Obx getPlayButton(ReciterInfoModel current, int index) {
    return Obx(
      () {
        return IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.green.shade800,
            foregroundColor: Colors.white,
          ),
          tooltip: "Play Recitation from ${current.name}",
          icon: audioControllerGetx.currentReciterIndex.value == index &&
                  audioControllerGetx.isPlaying.value == true
              ? const Icon(Icons.pause)
              : (audioControllerGetx.currentReciterIndex.value == index &&
                      audioControllerGetx.isLoading.value)
                  ? CircularProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      strokeWidth: 2,
                    )
                  : const Icon(Icons.play_arrow),
          onPressed: () async {
            if (audioControllerGetx.isPlaying.value == true &&
                audioControllerGetx.currentReciterIndex.value == index) {
              await ManageQuranAudio.audioPlayer.pause();
            } else if ((audioControllerGetx.isPlaying.value == true ||
                    audioControllerGetx.isLoading.value == true) &&
                audioControllerGetx.currentReciterIndex.value != index) {
              await ManageQuranAudio.audioPlayer.stop();
              audioControllerGetx.currentReciterIndex.value = index;
              await ManageQuranAudio.playMultipleSurahAsPlayList(
                surahNumber: 0,
                reciter: current,
              );
            } else if (audioControllerGetx.isPlaying.value == false &&
                audioControllerGetx.currentReciterIndex.value == index) {
              if (audioControllerGetx.isReadyToControl.value == false) {
                audioControllerGetx.currentReciterIndex.value = index;
                await ManageQuranAudio.playMultipleSurahAsPlayList(
                  surahNumber: 0,
                  reciter: current,
                );
              } else {
                await ManageQuranAudio.audioPlayer.play();
              }
            } else if (audioControllerGetx.isPlaying.value == false &&
                audioControllerGetx.currentReciterIndex.value != index) {
              audioControllerGetx.currentReciterIndex.value = index;
              await ManageQuranAudio.playMultipleSurahAsPlayList(
                surahNumber: 0,
                reciter: current,
              );
              await ManageQuranAudio.audioPlayer.play();
            }
          },
        );
      },
    );
  }
}
