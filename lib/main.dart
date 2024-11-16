import 'package:al_quran_audio/src/screens/home/home_page.dart';
import 'package:al_quran_audio/src/screens/setup/setup_page.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();
  await Hive.openBox('info');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Al Quran Audio',
      theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green.shade700,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
            ),
          )),
      home: Hive.box('info').get('default_recitation') == null
          ? const SetupPage()
          : const HomePage(),
    );
  }
}
