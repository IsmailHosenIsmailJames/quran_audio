import 'package:get/get.dart';

class AudioController extends GetxController {
  RxInt currentIndex = (-1).obs;
  RxBool isPlaying = false.obs;
  Rx<Duration> progress = const Duration().obs;
  Rx<Duration> totalDuration = const Duration().obs;
  Rx<Duration> bufferPosition = const Duration().obs;
  Rx<Duration> totalPosition = const Duration().obs;
  RxDouble speed = 1.0.obs;
  RxBool isStreamRegistered = false.obs;
  RxBool isLoading = false.obs;
  RxInt currentSurah = (-1).obs;
  RxBool isSurahAyahMode = true.obs;
}
