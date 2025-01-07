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
            Align(
              alignment: Alignment(
                  1, MediaQuery.of(context).size.height < 450 ? 0.43 : 0.63),
              child: Container(
                margin: const EdgeInsets.only(
                  left: 5,
                  right: 5,
                  top: 5,
                ),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Center(
                  child: Text("Audio Wave form"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
