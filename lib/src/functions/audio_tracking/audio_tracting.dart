import 'dart:developer';

import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/recitation_info/recitation_info_model.dart';
import 'package:al_quran_audio/src/functions/audio_tracking/model.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

TrackingAudioModel? trackingAudioModel;
AudioController audioController = Get.find();
void audioTracking() {
  int currentPlayingSurah = audioController.currentPlayingSurah.value;
  Duration totalDuration = audioController.totalDuration.value;
  ReciterInfoModel currentReciterModel =
      audioController.currentReciterModel.value;
  final box = Hive.box("audio_track");
  if (trackingAudioModel == null) {
    // try to retrieve form db
    Map? previousData = box.get(currentPlayingSurah);
    if (previousData != null) {
      trackingAudioModel =
          TrackingAudioModel.fromMap(Map<String, dynamic>.from(previousData));
    } else {
      trackingAudioModel = TrackingAudioModel(
        surahNumber: currentPlayingSurah,
        totalDurationInSeconds: totalDuration.inSeconds,
        totalPlayedDurationInSeconds: 0,
        lastReciterId: currentReciterModel.id,
      );
    }
  }

  if (trackingAudioModel == null) {
    log("Unexpected error", name: "Audio Tracking");
    return;
  }

  trackingAudioModel!.surahNumber = currentPlayingSurah;

  trackingAudioModel!.totalPlayedDurationInSeconds += 1;
  trackingAudioModel!.totalDurationInSeconds = totalDuration.inSeconds;
  trackingAudioModel!.totalPlayedDurationInSeconds += 1;

  box.put(currentPlayingSurah, trackingAudioModel!.toMap());
  log("Audio Tracked \n${trackingAudioModel!.toMap()}");
}
