import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/core/audio/widget_audio_controller.dart';
import 'package:al_quran_audio/src/core/surah_ayah_count.dart';
import 'package:al_quran_audio/src/screens/home/controller/home_controller.dart';
import 'package:al_quran_audio/src/screens/home/resources/surah_list.dart';
import 'package:al_quran_audio/src/theme/theme_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = Get.put(HomeController());
  final audioControllerGetx = Get.put(AudioController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/AlQuranAudio.jpg"),
            ),
            Gap(10),
            Text("Al Quran Audio"),
          ],
        ),
        actions: [
          themeIconButton,
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
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
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                backgroundColor:
                                    const Color.fromARGB(255, 200, 250, 200),
                                foregroundColor: Colors.green.shade800,
                              ),
                              onPressed: () {},
                              child: const Text("Change"),
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            homeController.reciter.value.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 5, bottom: 100),
                    itemCount: surahInfo.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircleAvatar(child: Text("${index + 1}")),
                            ),
                            const Gap(10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (surahInfo[index]['name_simple'] ?? "")
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
                            const Gap(10),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Obx(
                                () {
                                  return IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                    ),
                                    tooltip: "Play or Pause",
                                    icon: audioControllerGetx
                                                    .currentIndex.value ==
                                                index &&
                                            audioControllerGetx
                                                    .isPlaying.value ==
                                                true
                                        ? const Icon(Icons.pause)
                                        : (audioControllerGetx
                                                        .currentIndex.value ==
                                                    index &&
                                                audioControllerGetx
                                                    .isLoading.value)
                                            ? CircularProgressIndicator(
                                                color: Colors.white,
                                                backgroundColor: Colors.white
                                                    .withValues(alpha: 0.2),
                                                strokeWidth: 2,
                                              )
                                            : const Icon(Icons.play_arrow),
                                    onPressed: () async {
                                      audioControllerGetx.currentSurah.value =
                                          index;
                                      homeController.currentSurah.value = index;
                                      if (audioControllerGetx
                                                  .currentIndex.value ==
                                              index &&
                                          audioControllerGetx.isPlaying.value ==
                                              true) {
                                        // pause audio
                                        audioControllerGetx.currentIndex.value =
                                            index;
                                        await ManageQuranAudio.audioPlayer
                                            .pause();
                                      } else if (audioControllerGetx
                                                  .currentIndex.value ==
                                              index &&
                                          audioControllerGetx.isPlaying.value !=
                                              true) {
                                        // resume audio
                                        audioControllerGetx.currentIndex.value =
                                            index;
                                        await ManageQuranAudio.audioPlayer
                                            .play();
                                      } else {
                                        // start brand new audio
                                        audioControllerGetx.isPlaying.value =
                                            true;
                                        audioControllerGetx.currentIndex.value =
                                            index;
                                        await ManageQuranAudio.playSingleSurah(
                                          surahNumber: index + 1,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Align(
              alignment: const Alignment(1, 1),
              child: (audioControllerGetx.isPlaying.value == true ||
                      audioControllerGetx.currentIndex.value != -1)
                  ? WidgetAudioController(
                      showSurahNumber: false,
                      showQuranAyahMode: true,
                      surahNumber: homeController.currentSurah.value,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
