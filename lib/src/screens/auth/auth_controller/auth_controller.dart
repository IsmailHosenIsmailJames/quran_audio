import 'dart:convert';
import 'dart:developer';

import 'package:al_quran_audio/src/api/appwrite/config.dart';
import 'package:al_quran_audio/src/screens/home/controller/home_page_controller.dart';
import 'package:al_quran_audio/src/screens/home/controller/model/play_list_model.dart';
import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import 'package:appwrite/models.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthController extends GetxController {
  Rx<User?> loggedInUser = Rx<User?>(null);

  String databaseID = "6778271900148ad93326";
  String collectionID = "all_play_list";

  @override
  void onInit() {
    super.onInit();
    getUser();
  }

  Future<User?> getUser() async {
    try {
      final user = await AppWriteConfig.account.get();
      loggedInUser.value = user;
      return user;
    } on AppwriteException catch (e) {
      print(e.message);
    }
    return null;
  }

  Future<String?> login(String email, String password) async {
    try {
      await AppWriteConfig.account
          .createEmailPasswordSession(email: email, password: password);
    } on AppwriteException catch (e) {
      return e.message;
    }
    final user = await AppWriteConfig.account.get();
    loggedInUser.value = user;
    try {
      String id = user.$id;
      final AuthController authController = Get.find<AuthController>();
      final response = Databases(AppWriteConfig.client).getDocument(
        databaseId: authController.databaseID,
        collectionId: authController.collectionID,
        documentId: id,
      );
      return response.then((value) async {
        if (value.data["all_playlist_data"] != null) {
          await Hive.box("cloud_play_list").put(
            "all_playlist",
            value.data["all_playlist_data"],
          );
          List<String> rawPlayList =
              List<String>.from(jsonDecode(value.data["all_playlist_data"]));
          for (var rawPlayList in rawPlayList) {
            final decodeSinglePlayList = AllPlayListModel.fromJson(rawPlayList);
            List<String> playList = [];
            for (var playListModel in decodeSinglePlayList.playList) {
              playList.add(playListModel.toJson());
            }
            await Hive.box("play_list").put(
              decodeSinglePlayList.name,
              playList,
            );
          }
        }

        HomePageController homePageController = Get.find<HomePageController>();
        homePageController.reloadPlayList();

        return null;
      });
    } on AppwriteException catch (e) {
      log(e.message.toString());
    }
    return null;
  }

  Future<String?> register(String email, String password) async {
    try {
      await AppWriteConfig.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      return e.message;
    }
    return await login(email, password);
  }
}
