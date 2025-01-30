import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../core/audio/controller/audio_controller.dart';
import '../../core/audio/play_quran_audio.dart';
import '../../core/audio/widget_audio_controller.dart';
import '../../theme/theme_controller.dart';
import '../auth/auth_controller/auth_controller.dart';
import 'controller/home_page_controller.dart';
import 'settings/settings_page.dart';
import 'tabs/play_list_page.dart';
import 'tabs/play_tab.dart';
import 'tabs/profile_page.dart';

class HomeDesktopPage extends StatefulWidget {
  const HomeDesktopPage({super.key});

  @override
  State<HomeDesktopPage> createState() => _HomeDesktopPageState();
}

class _HomeDesktopPageState extends State<HomeDesktopPage> {
  AudioController audioController = ManageQuranAudio.audioController;
  final themeController = Get.put(AppThemeData());
  final HomePageController homePageController = Get.put(HomePageController());

  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          IconButton(
            onPressed: () async {
              await Get.to(
                () => const SettingsPage(),
              );
              setState(() {});
            },
            icon: const Icon(
              FluentIcons.settings_24_regular,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Row(
              children: [
                Expanded(
                  child: PlayTab(),
                ),
                Expanded(
                  child: PlayListPage(),
                ),
                Expanded(child: ProfilePage()),
              ],
            ),
            Obx(
              () => Container(
                margin: const EdgeInsets.only(bottom: 55),
                child: (audioController.isPlaying.value == true ||
                        audioController.isReadyToControl.value == true)
                    ? WidgetAudioController(
                        showSurahNumber: false,
                        showQuranAyahMode: true,
                        surahNumber: audioController.currentPlayingSurah.value,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Obx getPlayButton(int index, AudioController audioController) {
  return Obx(
    () {
      return IconButton(
        style: IconButton.styleFrom(
          backgroundColor: Colors.green.shade800,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
        tooltip: "Play or Pause",
        icon: (audioController.currentPlayingSurah.value == index &&
                audioController.isPlaying.value == true)
            ? const Icon(Icons.pause)
            : (audioController.currentPlayingSurah.value == index &&
                    audioController.isLoading.value)
                ? CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    strokeWidth: 2,
                  )
                : const Icon(Icons.play_arrow),
        onPressed: () async {
          if (audioController.isPlaying.value == true &&
              audioController.currentPlayingSurah.value == index) {
            await ManageQuranAudio.audioPlayer.pause();
          } else if ((audioController.isPlaying.value == true ||
                  audioController.isLoading.value == true) &&
              audioController.currentPlayingSurah.value != index) {
            audioController.currentPlayingSurah.value = index;
            await ManageQuranAudio.audioPlayer.stop();
            await ManageQuranAudio.playMultipleSurahAsPlayList(
              surahNumber: index,
              reciter: audioController.currentReciterModel.value,
            );
          } else if (audioController.isPlaying.value == false &&
              audioController.currentPlayingSurah.value == index) {
            if (audioController.isReadyToControl.value == false) {
              await ManageQuranAudio.playMultipleSurahAsPlayList(
                surahNumber: index,
                reciter: audioController.currentReciterModel.value,
              );
            } else {
              await ManageQuranAudio.audioPlayer.play();
            }
          } else if (audioController.isPlaying.value == false &&
              audioController.currentPlayingSurah.value != index) {
            audioController.currentPlayingSurah.value = index;
            await ManageQuranAudio.playMultipleSurahAsPlayList(
              surahNumber: index,
              reciter: audioController.currentReciterModel.value,
            );
          }
        },
      );
    },
  );
}
