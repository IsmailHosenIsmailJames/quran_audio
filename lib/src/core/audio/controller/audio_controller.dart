import 'dart:convert';

import 'package:al_quran_audio/src/core/recitation_info/recitation_info_model.dart';
import 'package:al_quran_audio/src/core/recitation_info/recitations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AudioController extends GetxController {
  static final box = Hive.box("info");
  RxInt currentReciterIndex = (0).obs;
  RxInt currentPlayListIndex = (0).obs;
  RxInt setupSelectedReciterIndex = (0).obs;
  RxBool isFullScreenMode = false.obs;

  RxInt currentPlayingSurah = (0).obs;
  Rx<ReciterInfoModel> currentReciterModel = ReciterInfoModel.fromJson(
    box.get(
      "default_reciter",
      defaultValue: jsonEncode(recitationsInfoList[0]),
    ),
  ).obs;
  RxDouble fontSizeArabic =
      (box.get("fontSizeArabic", defaultValue: 16.0) as double).obs;
  RxBool isPlaying = false.obs;
  Rx<Duration> progress = const Duration().obs;
  Rx<Duration> totalDuration = const Duration().obs;
  Rx<Duration> bufferPosition = const Duration().obs;
  Rx<Duration> totalPosition = const Duration().obs;
  RxDouble speed = 1.0.obs;
  RxBool isStreamRegistered = false.obs;
  RxBool isLoading = false.obs;
  RxBool isSurahAyahMode = false.obs;
  RxBool isReadyToControl = false.obs;
  RxBool isPlayingCompleted = false.obs;
}
