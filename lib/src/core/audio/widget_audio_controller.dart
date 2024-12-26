import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/theme/colors.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetAudioController extends StatefulWidget {
  const WidgetAudioController({super.key});

  @override
  State<WidgetAudioController> createState() => _WidgetAudioControllerState();
}

class _WidgetAudioControllerState extends State<WidgetAudioController>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    animationController.forward();
    super.initState();
  }

  final audioController = Get.put(AudioController());
  final themeController = Get.put(AppThemeData());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, value) {
        return Obx(
          () {
            bool isDark = (themeController.isDark.value == true ||
                (themeController.themeModeName.value == "system" &&
                    MediaQuery.of(context).platformBrightness ==
                        Brightness.dark));
            Color colorToApply =
                isDark ? Colors.white : MyColors.secondaryColor;
            return Container(
              height: 85,
              width: animation.value * MediaQuery.of(context).size.width * 1,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: isDark ? Colors.grey.shade800 : Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProgressBar(
                    progress: audioController.progress.value,
                    buffered: audioController.bufferPosition.value,
                    total: audioController.totalDuration.value,
                    progressBarColor: Colors.green,
                    baseBarColor: Colors.white,
                    bufferedBarColor: Colors.green.shade200,
                    thumbColor: MyColors.secondaryColor,
                    barHeight: 5.0,
                    thumbRadius: 7.0,
                    timeLabelLocation: TimeLabelLocation.sides,
                    onSeek: (duration) {
                      ManageQuranAudio.audioPlayer.seek(duration);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 13,
                        child: Text(
                          audioController.currentSurah.value.toString(),
                          style: TextStyle(color: colorToApply),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          int toSeek =
                              audioController.progress.value.inSeconds - 10;
                          if (toSeek < 0) {
                            toSeek = 0;
                          }
                          ManageQuranAudio.audioPlayer
                              .seek(Duration(seconds: toSeek));
                        },
                        icon: Icon(
                          FluentIcons.skip_back_10_24_regular,
                          color: colorToApply,
                        ),
                      ),
                      IconButton(
                        onPressed: audioController.currentSurah.value <= 1
                            ? null
                            : () {
                                audioController.currentSurah.value -= 1;
                                ManageQuranAudio.playSingleSurah(
                                  surahNumber:
                                      audioController.currentSurah.value,
                                );
                              },
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: audioController.currentSurah.value <= 1
                              ? Colors.grey
                              : colorToApply,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          audioController.isPlaying.value
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: colorToApply,
                        ),
                      ),
                      IconButton(
                        onPressed: audioController.currentSurah.value >= 114
                            ? null
                            : () {
                                audioController.currentSurah.value += 1;
                                ManageQuranAudio.playSingleSurah(
                                  surahNumber:
                                      audioController.currentSurah.value,
                                );
                              },
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: audioController.currentSurah.value >= 114
                              ? Colors.grey
                              : colorToApply,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          int toSeek =
                              audioController.progress.value.inSeconds + 10;
                          if (toSeek >
                              audioController.totalDuration.value.inSeconds) {
                            toSeek =
                                audioController.totalDuration.value.inSeconds;
                          }
                          ManageQuranAudio.audioPlayer
                              .seek(Duration(seconds: toSeek));
                        },
                        icon: Icon(
                          FluentIcons.skip_forward_10_24_regular,
                          color: colorToApply,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorToApply,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
