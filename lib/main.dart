import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/functions/get_uthmani_tajweed.dart';
import 'package:al_quran_audio/src/screens/auth/auth_controller/auth_controller.dart';
import 'package:al_quran_audio/src/screens/home/home_page.dart';
import 'package:al_quran_audio/src/screens/setup/setup_page.dart';
import 'package:al_quran_audio/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:toastification/toastification.dart';

import 'src/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();
  await Hive.openBox('info');
  await Hive.openBox('play_list');
  await Hive.openBox('cloud_play_list');
  await Hive.openBox('audio_time_stamp');
  await Hive.openBox('completed_surah');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Al Quran Audio',
        theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: MyColors.mainColor,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.mainColor,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              iconColor: Colors.white,
            ),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: MyColors.mainColor,
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.poppinsTextTheme().apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
            decorationColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.mainColor,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              iconColor: Colors.white,
            ),
          ),
        ),
        defaultTransition: Transition.leftToRight,
        home: Hive.box('info').get('default_reciter') == null
            ? const SetupPage()
            : const HomePage(),
        onInit: () async {
          Get.put(AuthController());
          final appTheme = Get.put(AppThemeData());
          final AudioController audioController =
              ManageQuranAudio.audioController;
          final box = Hive.box('info');
          final reciterIndex = box.get("reciter_index", defaultValue: 0);
          audioController.currentReciterIndex.value = reciterIndex;

          getUthmaniTajweed();
          appTheme.initTheme();
        },
      ),
    );
  }
}
