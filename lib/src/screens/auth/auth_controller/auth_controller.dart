import 'package:al_quran_audio/src/api/appwrite/config.dart';
import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import 'package:appwrite/models.dart';

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
