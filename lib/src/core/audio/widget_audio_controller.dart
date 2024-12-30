import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/core/surah_ayah_count.dart';
import 'package:al_quran_audio/src/functions/get_uthmani_tajweed.dart';
import 'package:al_quran_audio/src/theme/colors.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:toastification/toastification.dart';

class WidgetAudioController extends StatefulWidget {
  final bool showSurahNumber;
  final bool showQuranAyahMode;
  final int surahNumber;
  const WidgetAudioController({
    super.key,
    required this.showSurahNumber,
    required this.showQuranAyahMode,
    required this.surahNumber,
  });

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
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    animationController.forward();
    super.initState();
  }

  AudioController audioController = ManageQuranAudio.audioController;
  final themeController = Get.put(AppThemeData());

  final infoBox = Hive.box("info");

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, value) {
        return Obx(
          () {
            bool isDark = (themeController.themeModeName.value == "dark" ||
                (themeController.themeModeName.value == "system" &&
                    MediaQuery.of(context).platformBrightness ==
                        Brightness.dark));
            Color colorToApply =
                isDark ? Colors.white : MyColors.secondaryColor;
            int latestSurahNumber = audioController.currentPlayingSurah.value;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (audioController.isSurahAyahMode.value)
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10, top: 25),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color.fromARGB(255, 29, 29, 29)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 0.7),
                          ),
                          child: Scrollbar(
                            controller: scrollController,
                            thickness: 5,
                            thumbVisibility: true,
                            radius: const Radius.circular(7),
                            interactive: true,
                            child: ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.all(10),
                                itemCount:
                                    (surahAyahCount[(latestSurahNumber)] / 10)
                                        .ceil(),
                                itemBuilder: (context, index) {
                                  int ayahCount =
                                      surahAyahCount[latestSurahNumber];
                                  int start = index * 10 + 1;
                                  int end = (index + 1) * 10;
                                  if (end > ayahCount) {
                                    end = ayahCount;
                                  }

                                  List<InlineSpan> listOfAyahsSpanText = [];

                                  for (int currentAyahNumber = start;
                                      currentAyahNumber <= end;
                                      currentAyahNumber++) {
                                    listOfAyahsSpanText.addAll(
                                      getTajweedTexSpan(
                                        infoBox.get(
                                          "uthmani_tajweed/${(latestSurahNumber) + 1}:$currentAyahNumber",
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
                                              fontSize: audioController
                                                  .fontSizeArabic.value,
                                            ),
                                          ),
                                          const Gap(10),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              toastification.show(
                                                context: context,
                                                title: const Text(
                                                    "Trying to download"),
                                                description: const Text(
                                                    "Wait a bit until it's done"),
                                              );
                                              await getUthmaniTajweed();
                                              toastification.show(
                                                context: context,
                                                title: const Text(
                                                    "Trying to download"),
                                                description: const Text(
                                                    "Wait a bit until it's done"),
                                              );

                                              setState(() {});
                                            },
                                            icon: const Icon(FluentIcons
                                                .arrow_download_24_regular),
                                            label: const Text("Download"),
                                          ),
                                        ],
                                      );
                                    }
                                  }
                                  return Text.rich(
                                      TextSpan(children: listOfAyahsSpanText),
                                      style: TextStyle(
                                        fontSize: audioController
                                            .fontSizeArabic.value,
                                      ));
                                }),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: isDark
                                        ? Colors.grey.shade900
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 0.7),
                                    )),
                                onPressed: () {
                                  audioController.isSurahAyahMode.value =
                                      !audioController.isSurahAyahMode.value;
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                getControllers(context, isDark, colorToApply),
              ],
            );
          },
        );
      },
    );
  }

  Container getControllers(
      BuildContext context, bool isDark, Color colorToApply) {
    return Container(
      height: 85,
      width: animation.value * MediaQuery.of(context).size.width * 1,
      margin: EdgeInsets.only(
          left: 10,
          top: 10,
          right: 10,
          bottom: widget.showQuranAyahMode ? 10 : 70),
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
            baseBarColor: colorToApply.withValues(alpha: 0.2),
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
              if (widget.showSurahNumber)
                CircleAvatar(
                  radius: 15,
                  child: Text(
                    audioController.currentPlayingSurah.value.toString(),
                    style: TextStyle(color: colorToApply),
                  ),
                ),
              const Gap(5),
              IconButton(
                onPressed: () {
                  int toSeek = audioController.progress.value.inSeconds - 10;
                  if (toSeek < 0) {
                    toSeek = 0;
                  }
                  ManageQuranAudio.audioPlayer.seek(Duration(seconds: toSeek));
                },
                icon: Icon(
                  FluentIcons.skip_back_10_24_regular,
                  color: colorToApply,
                ),
              ),
              IconButton(
                onPressed: audioController.currentPlayingSurah.value <= 0
                    ? null
                    : () {
                        ManageQuranAudio.audioPlayer.seekToPrevious();
                      },
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: audioController.currentPlayingSurah.value <= 0
                      ? Colors.grey
                      : colorToApply,
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (audioController.isLoading.value) {
                    return;
                  }
                  if (audioController.isPlaying.value) {
                    await ManageQuranAudio.audioPlayer.pause();
                  } else {
                    await ManageQuranAudio.audioPlayer.play();
                  }
                },
                icon: audioController.isLoading.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: colorToApply,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(
                        audioController.isPlaying.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: colorToApply,
                      ),
              ),
              IconButton(
                onPressed: audioController.currentPlayingSurah.value >= 113
                    ? null
                    : () {
                        ManageQuranAudio.audioPlayer.seekToNext();
                      },
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: audioController.currentPlayingSurah.value >= 113
                      ? Colors.grey
                      : colorToApply,
                ),
              ),
              IconButton(
                onPressed: () {
                  int toSeek = audioController.progress.value.inSeconds + 10;
                  if (toSeek > audioController.totalDuration.value.inSeconds) {
                    toSeek = audioController.totalDuration.value.inSeconds;
                  }
                  ManageQuranAudio.audioPlayer.seek(Duration(seconds: toSeek));
                },
                icon: Icon(
                  FluentIcons.skip_forward_10_24_regular,
                  color: colorToApply,
                ),
              ),
              if (widget.showQuranAyahMode)
                IconButton(
                  onPressed: () {
                    audioController.isSurahAyahMode.value =
                        !audioController.isSurahAyahMode.value;
                  },
                  icon: Icon(
                    audioController.isSurahAyahMode.value
                        ? FluentIcons.full_screen_minimize_24_regular
                        : FluentIcons.full_screen_maximize_24_regular,
                    color: colorToApply,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<InlineSpan> getTajweedTexSpan(String ayah,
      {bool hideEnd = false, bool doBold = false}) {
    List<Map<String, String?>> tajweed = extractWordsGetTazweeds(ayah);
    List<InlineSpan> spanText = [];
    for (int i = 0; i < tajweed.length; i++) {
      Map<String, String?> taz = tajweed[i];
      String word = taz['word'] ?? "";
      String className = taz['class'] ?? "null";
      String tag = taz['tag'] ?? "null";
      if (className == 'null' || tag == "null") {
        spanText.add(
          TextSpan(text: word),
        );
      } else {
        if (className == "end" && hideEnd != true) {
          spanText.add(
            TextSpan(
              text: "۝$word ",
            ),
          );
        } else {
          if (hideEnd && word.length == 1 && i == 13) {
            continue;
          }
          Color textColor = colorsForTajweed[className] ??
              const Color.fromARGB(255, 121, 85, 72);
          spanText.add(
            TextSpan(
              text: word,
              style: TextStyle(
                color: textColor,
              ),
            ),
          );
        }
      }
    }
    return spanText;
  }
}

String startAyahBismillah(String scriptType) {
  final scriptBox = Hive.box("info");
  return scriptBox.get("uthmani_tajweed/1:1", defaultValue: "");
}

Map<String, Color> colorsForTajweed = {
  "ham_wasl": const Color.fromARGB(200, 145, 145, 145),
  "laam_shamsiyah": const Color.fromARGB(200, 149, 149, 255),
  "madda_normal": const Color.fromARGB(255, 200, 0, 255),
  "madda_permissible": const Color.fromARGB(255, 246, 123, 255),
  "madda_necessary": const Color.fromARGB(200, 255, 0, 238),
  "idgham_wo_ghunnah": const Color.fromARGB(255, 72, 142, 255),
  "ghunnah": const Color.fromARGB(255, 11, 169, 22),
  "slnt": const Color.fromARGB(200, 114, 114, 114),
  "qalaqah": const Color.fromARGB(255, 155, 212, 91),
  "ikhafa": const Color.fromARGB(255, 255, 140, 32),
  "madda_obligatory": const Color.fromARGB(255, 192, 90, 165),
  "idgham_ghunnah": const Color.fromARGB(255, 0, 79, 216),
};

Map<String, String> detailsOfTazwed = {
  "ham_wasl": "",
  "laam_shamsiyah": "",
  "madda_normal": "",
  "madda_permissible": "",
  "madda_necessary": "",
  "idgham_wo_ghunnah": "",
  "ghunnah": "",
  "slnt": "",
  "qalaqah": "",
  "ikhafa": "",
  "madda_obligatory": "",
  "idgham_ghunnah": "",
};

List<Map<String, String?>> extractWordsGetTazweeds(String text) {
  final regexp = RegExp(r'<[^>]+>(.*?)</[^>]+>|[^<]+');
  final matchers = regexp.allMatches(text);
  final allWords = matchers.map((match) => match.group(0)!).toList();
  List<Map<String, String?>> tajweed = [];
  for (String word in allWords) {
    List<Map<String, String?>> tem = getTagAndWord(word);
    if (tem.isEmpty) {
      tajweed.add({
        "tag": "null",
        "class": "null",
        "word": word,
      });
    } else {
      tajweed.add(tem[0]);
    }
  }
  return tajweed;
}

List<Map<String, String?>> getTagAndWord(String word) {
  final regex = RegExp(
      r'<(?<tag>\w+)\s+class=(?<class>\w+)>(?<word>[^<]+)</(?<tag2>\1)>' // Capture tag, class, and word
      );

  final matches = regex.allMatches(word);
  final result = matches
      .map((match) => {
            "tag": match.namedGroup('tag'),
            "class": match.namedGroup('class'),
            "word": match.namedGroup('word'),
          })
      .toList();
  return result;
}
