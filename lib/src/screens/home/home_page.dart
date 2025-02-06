import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/core/audio/widget_audio_controller.dart';
import 'package:al_quran_audio/src/screens/auth/auth_controller/auth_controller.dart';
import 'package:al_quran_audio/src/screens/home/controller/home_page_controller.dart';
import 'package:al_quran_audio/src/screens/home/tabs/play_list_page.dart';
import 'package:al_quran_audio/src/screens/home/tabs/play_tab.dart';
import 'package:al_quran_audio/src/screens/home/tabs/profile_page.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AudioController audioController = ManageQuranAudio.audioController;
  final themeController = Get.put(AppThemeData());
  final HomePageController homePageController = Get.put(HomePageController());
  PersistentTabController pageController =
      PersistentTabController(initialIndex: 0);

  final AuthController authController = Get.find<AuthController>();
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
          IconButton(
            onPressed: () async {
              await Get.toNamed('/settings');
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
            Obx(
              () {
                bool isDark = themeController.themeModeName.value == "dark" ||
                    (themeController.themeModeName.value == "system" &&
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark);
                return PersistentTabView(
                  backgroundColor: isDark
                      ? const Color.fromARGB(255, 20, 20, 20)
                      : Colors.grey.shade100,
                  context,
                  controller: pageController,
                  screens: [
                    PlayTab(
                      tabController: pageController,
                    ),
                    PlayListPage(
                      tabController: pageController,
                    ),
                    const ProfilePage(),
                  ],
                  items: [
                    PersistentBottomNavBarItem(
                      icon: const Icon(Icons.play_circle_rounded),
                      title: ("Play"),
                      activeColorSecondary: Colors.green.shade600,
                      inactiveColorPrimary:
                          isDark ? Colors.white : Colors.grey.shade700,
                    ),
                    PersistentBottomNavBarItem(
                      icon: const Icon(Icons.playlist_play_rounded),
                      title: ("Play Lists"),
                      activeColorSecondary: Colors.green.shade600,
                      inactiveColorPrimary:
                          isDark ? Colors.white : Colors.grey.shade700,
                    ),
                    PersistentBottomNavBarItem(
                      icon: const Icon(FluentIcons.person_24_filled),
                      title: ("Profile"),
                      activeColorSecondary: Colors.green.shade600,
                      inactiveColorPrimary:
                          isDark ? Colors.white : Colors.grey.shade700,
                    ),
                  ],
                  handleAndroidBackButtonPress: true,
                  resizeToAvoidBottomInset: true,
                  stateManagement: true,
                  hideNavigationBarWhenKeyboardAppears: true,
                  popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
                  decoration: NavBarDecoration(
                    border: Border(
                      top: BorderSide(
                          color: Colors.grey.shade600.withValues(alpha: 0.4)),
                    ),
                  ),
                  isVisible: true,
                  animationSettings: const NavBarAnimationSettings(
                    navBarItemAnimation: ItemAnimationSettings(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.ease,
                    ),
                    screenTransitionAnimation:
                        ScreenTransitionAnimationSettings(
                      animateTabTransition: true,
                      duration: Duration(milliseconds: 400),
                      screenTransitionAnimationType:
                          ScreenTransitionAnimationType.fadeIn,
                    ),
                  ),
                  confineToSafeArea: true,
                  navBarHeight: kBottomNavigationBarHeight,
                  navBarStyle: NavBarStyle.style12,
                );
              },
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
