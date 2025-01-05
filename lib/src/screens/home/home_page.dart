import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/core/audio/widget_audio_controller.dart';
import 'package:al_quran_audio/src/screens/auth/auth_controller/auth_controller.dart';
import 'package:al_quran_audio/src/screens/home/controller/home_page_controller.dart';
import 'package:al_quran_audio/src/screens/home/tabs/play_list_page.dart';
import 'package:al_quran_audio/src/screens/home/tabs/play_tab.dart';
import 'package:al_quran_audio/src/screens/home/tabs/profile_page.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:al_quran_audio/src/theme/theme_icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  PersistentTabController tabController =
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
            onPressed: () {
              showSettings(context, audioController);
            },
            icon: const Icon(
              FluentIcons.settings_24_regular,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(
            () {
              bool isDark = themeController.themeModeName.value == "dark" ||
                  (themeController.themeModeName.value == "system" &&
                      MediaQuery.of(context).platformBrightness ==
                          Brightness.dark);
              return PersistentTabView(
                backgroundColor:
                    isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                margin: const EdgeInsets.only(left: 3, right: 3, bottom: 3),

                context,
                controller: tabController,
                screens: [
                  PlayTab(
                    tabController: tabController,
                  ),
                  PlayListPage(
                    tabController: tabController,
                  ),
                  const ProfilePage(),
                ],
                items: [
                  PersistentBottomNavBarItem(
                    icon: const Icon(Icons.play_circle_rounded),
                    title: ("Play"),
                    activeColorPrimary: Colors.green.shade800,
                    activeColorSecondary: Colors.white,
                    inactiveColorPrimary: Colors.green.shade600,
                  ),
                  PersistentBottomNavBarItem(
                    icon: const Icon(Icons.playlist_play_rounded),
                    title: ("Play Lists"),
                    activeColorPrimary: Colors.green.shade800,
                    activeColorSecondary: Colors.white,
                    inactiveColorPrimary: Colors.green.shade600,
                  ),
                  PersistentBottomNavBarItem(
                    icon: const Icon(FluentIcons.person_24_filled),
                    title: ("Profile"),
                    activeColorPrimary: Colors.green.shade800,
                    activeColorSecondary: Colors.white,
                    inactiveColorPrimary: Colors.green.shade600,
                  ),
                ],
                handleAndroidBackButtonPress: true, // Default is true.
                resizeToAvoidBottomInset:
                    true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
                stateManagement: true, // Default is true.
                hideNavigationBarWhenKeyboardAppears: true,
                popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,

                decoration: NavBarDecoration(
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                      color: Colors.grey.shade400.withValues(alpha: 0.5),
                      width: 0.7),
                ),
                isVisible: true,
                animationSettings: const NavBarAnimationSettings(
                  navBarItemAnimation: ItemAnimationSettings(
                    // Navigation Bar's items animation properties.
                    duration: Duration(milliseconds: 400),
                    curve: Curves.ease,
                  ),
                  screenTransitionAnimation: ScreenTransitionAnimationSettings(
                    // Screen transition animation on change of selected tab.
                    animateTabTransition: true,
                    duration: Duration(milliseconds: 400),
                    screenTransitionAnimationType:
                        ScreenTransitionAnimationType.fadeIn,
                  ),
                ),
                confineToSafeArea: true,
                navBarHeight: kBottomNavigationBarHeight,
                navBarStyle: NavBarStyle
                    .style7, // Choose the nav bar style with this property
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
    );
  }

  void showSettings(BuildContext context, AudioController audioController) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      context: context,
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(FluentIcons.settings_24_regular),
                  const Gap(5),
                  const Text("Settings"),
                  const Spacer(),
                  themeIconButton,
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(15),
            const Row(
              children: [
                Gap(15),
                Icon(FluentIcons.text_font_16_filled),
                Gap(10),
                Text(
                  "Font Size",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: audioController.fontSizeArabic.value,
                      min: 10,
                      max: 50,
                      divisions: 40,
                      onChanged: (value) async {
                        audioController.fontSizeArabic.value = value;
                        setState(() {});
                        Hive.box("info").put("fontSizeArabic", value);
                      },
                    ),
                  ),
                  const Gap(5),
                  Text(
                    audioController.fontSizeArabic.value.round().toString(),
                  ),
                  const Gap(10),
                ],
              ),
            )
          ],
        );
      },
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
