import 'package:al_quran_audio/src/api/apis.dart';
import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/core/recitation_info/recitation_info_model.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class ManageQuranAudio {
  static AudioPlayer audioPlayer = AudioPlayer();
  static AudioController audioControllerGetx = Get.put(AudioController());

  /// Plays a single ayah audio using the specified ayah and surah numbers.
  ///
  /// This function stops any currently playing audio, constructs the audio URL
  /// for the specified ayah and surah, and then plays the ayah audio using the
  /// audio player. If a reciter is not provided, it defaults to the currently
  /// selected recitation model. Optionally, a media item can be provided to
  /// set additional metadata for the audio.
  ///
  /// [ayahNumber] - The verse number within the surah to play.
  /// [surahNumber] - The chapter number in the Quran.
  /// [reciter] - (Optional) A specific reciter's information; defaults to the current recitation model if not provided.
  /// [mediaItem] - (Optional) A media item to set as the tag for the audio.
  static Future<void> startListening() async {
    audioPlayer.durationStream.listen((event) {
      if (event != null) {
        audioControllerGetx.duration.value = event.inMilliseconds;
      }
    });

    audioPlayer.positionStream.listen((event) {
      audioControllerGetx.progress.value = event.inMilliseconds;
    });

    audioPlayer.speedStream.listen((event) {
      audioControllerGetx.speed.value = event;
    });

    audioPlayer.playerStateStream.listen((event) {
      if (audioControllerGetx.currentIndex.value != -1) {
        audioControllerGetx.isPlaying.value = event.playing;
        if (event.processingState == ProcessingState.loading) {
          audioControllerGetx.isLoading.value = true;
        } else {
          audioControllerGetx.isLoading.value = false;
        }
      }
    });

    audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        audioControllerGetx.isPlaying.value = false;
        audioControllerGetx.currentIndex.value = -1;
      }
    });

    audioControllerGetx.isStreamRegistered.value = true;
  }

  static Future<void> playSingleSurah({
    required int surahNumber,
    ReciterInfoModel? reciter,
    MediaItem? mediaItem,
  }) async {
    if (audioControllerGetx.isStreamRegistered.value == false) {
      await startListening();
    }
    audioPlayer.stop();
    reciter ??= findRecitationModel();

    await audioPlayer.setAudioSource(
        LockCachingAudioSource(
          Uri.parse(
            makeAudioUrl(
              reciter,
              surahIDFromNumber(surahNumber),
            ),
          ),
          tag: MediaItem(
            id: "${reciter.id}$surahNumber",
            title: reciter.name,
          ),
        ),
        initialIndex: 0,
        initialPosition: Duration.zero);
    await audioPlayer.play();
  }

  /// Generates a URL pointing to a specific ayah's audio on everyayah.com.
  ///
  /// The URL is constructed by concatenating the base API URL with the
  /// subfolder of the currently selected reciter and the ayah number. The
  /// ayah number is zero-padded with three digits. For example, if the
  /// currently selected reciter has subfolder "Abdul_Basit_Murattal_64kbps"
  /// and the ayah number is 1, the generated URL will be:
  ///
  /// https://everyayah.com/data/Abdul_Basit_Murattal_64kbps/001.mp3
  static String makeAudioUrl(ReciterInfoModel reciter, String surahID) {
    return "$baseAPI/${reciter.id}/$surahID.mp3";
  }

  /// Retrieves the currently selected reciter from the 'info' box in hive.
  ///
  /// The currently selected reciter is stored as a JSON string in the
  /// 'reciter' key of the 'info' box in hive. When this function is called,
  /// it reads the JSON string from that key and parses it into a
  /// [ReciterInfoModel] using the [ReciterInfoModel.fromJson] method.
  /// The resulting [ReciterInfoModel] is then returned.
  static ReciterInfoModel findRecitationModel() {
    final jsonReciter = Hive.box('info').get('reciter');
    return ReciterInfoModel.fromJson(jsonReciter);
  }

  /// Returns a [MediaItem] with the given [surahID] and [reciter].
  ///
  /// The [MediaItem] will have:
  /// - [id] and [title] set to [surahID].
  /// - [displayTitle] set to [surahID].
  /// - [album] set to [reciter]'s name.
  /// - [artist] set to [reciter]'s subfolder.
  /// - [artUri] set to the given [artUri] if not null, or null if null.
  static MediaItem findMediaItem(
      {required String surahID,
      required ReciterInfoModel reciter,
      Uri? artUri}) {
    return MediaItem(
      id: surahID,
      title: surahID,
      displayTitle: surahID,
      album: reciter.name,
      artUri: artUri,
    );
  }

  /// Generates a formatted ayah ID string by combining the surah number
  /// and ayah number. Both numbers are zero-padded to three digits.
  ///
  /// [ayahNumber] - The verse number within the surah.
  /// [surahNumber] - The chapter number in the Quran.
  ///
  /// Returns a string representation of the ayah ID in the format 'SSSAAA'
  /// where 'SSS' is the zero-padded surah number and 'AAA' is the zero-padded ayah number.
  static String surahIDFromNumber(int surahNumber) {
    return surahNumber.toString().padLeft(3, '0');
  }
}
