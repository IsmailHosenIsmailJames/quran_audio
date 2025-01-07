import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/audio/widget_audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenAudioMode extends StatefulWidget {
  const FullScreenAudioMode({super.key});

  @override
  State<FullScreenAudioMode> createState() => _FullScreenAudioModeState();
}

class _FullScreenAudioModeState extends State<FullScreenAudioMode> {
  final audioController = Get.find<AudioController>();

  @override
  void initState() {
    audioController.isFullScreenMode.value = true;
    audioController.isSurahAyahMode.value = true;

    super.initState();
  }

  @override
  void dispose() {
    audioController.isFullScreenMode.value = false;
    audioController.isSurahAyahMode.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WidgetAudioController(
              showSurahNumber: false,
              showQuranAyahMode: true,
              surahNumber: audioController.currentPlayingSurah.value,
            ),
          ],
        ),
      ),
    );
  }
}
