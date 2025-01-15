import 'dart:convert';

import 'package:al_quran_audio/src/api/appwrite/config.dart';
import 'package:al_quran_audio/src/core/recitation_info/recitation_info_model.dart';
import 'package:al_quran_audio/src/screens/auth/auth_controller/auth_controller.dart';
import 'package:al_quran_audio/src/screens/home/controller/model/play_list_model.dart';
import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePageController extends GetxController {
  RxBool selectForPlaylistMode = false.obs;
  RxList<PlayListModel> selectedForPlaylist = <PlayListModel>[].obs;
  RxList<AllPlayListModel> allPlaylistInDB = <AllPlayListModel>[].obs;
  RxString nameOfEditingPlaylist = "".obs;

  @override
  void onInit() {
    reloadPlayList();
    super.onInit();
  }

  void addToPlaylist(ReciterInfoModel reciterInfoModel, int surahNumber) {
    selectedForPlaylist.add(
      PlayListModel(
        reciter: reciterInfoModel,
        surahNumber: surahNumber,
      ),
    );
  }

  void removeToPlaylist(ReciterInfoModel reciterInfoModel, int surahNumber) {
    selectedForPlaylist.removeWhere(
      (element) => (element.reciter.id == reciterInfoModel.id &&
          element.surahNumber == surahNumber),
    );
  }

  bool containsInPlaylist(ReciterInfoModel reciterInfoModel, int surahNumber) {
    return selectedForPlaylist.any(
      (element) =>
          element.reciter.id == reciterInfoModel.id &&
          element.surahNumber == surahNumber,
    );
  }

  Future<void> saveToPlayList() async {
    List<String> playList = [];
    for (var playListModel in selectedForPlaylist) {
      playList.add(playListModel.toJson());
    }
    await Hive.box("play_list").put(
      nameOfEditingPlaylist.value,
      playList,
    );
    selectForPlaylistMode.value = false;
    selectedForPlaylist.clear();
  }

  void reloadPlayList() {
    allPlaylistInDB.clear();
    final infoBox = Hive.box("play_list");
    for (var key in infoBox.keys) {
      List playList = infoBox.get(key);
      List<PlayListModel> playListModels = [];
      for (var playListJson in playList) {
        playListModels.add(PlayListModel.fromJson(playListJson));
      }
      allPlaylistInDB
          .add(AllPlayListModel(playList: playListModels, name: key));
    }
  }

  Future<String?> backupPlayList() async {
    try {
      List<String> rawPlaylistData = [];
      for (var playList in allPlaylistInDB) {
        rawPlaylistData.add(playList.toJson());
      }
      String rawJson = jsonEncode(rawPlaylistData);
      final db = Databases(AppWriteConfig.client);

      try {
        final AuthController authController = Get.find<AuthController>();
        String id = authController.loggedInUser.value!.$id;
        if (Hive.box('cloud_play_list').keys.isNotEmpty) {
          await db.updateDocument(
            databaseId: authController.databaseID,
            collectionId: authController.collectionID,
            documentId: id,
            data: {
              "all_playlist_data": rawJson,
            },
          );
          await Hive.box("cloud_play_list").put("all_playlist", rawJson);
        } else {
          await db.createDocument(
            databaseId: authController.databaseID,
            collectionId: authController.collectionID,
            documentId: id,
            data: {
              "all_playlist_data": rawJson,
            },
          );
          await Hive.box("cloud_play_list").put("all_playlist", rawJson);
        }
      } on AppwriteException catch (e) {
        return e.message;
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
