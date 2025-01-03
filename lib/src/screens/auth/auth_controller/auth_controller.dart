import 'package:al_quran_audio/src/api/appwrite/config.dart';
import 'package:al_quran_audio/src/api/appwrite/functions.dart';
import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import 'package:appwrite/models.dart';

class AuthController extends GetxController {
  Rx<User?> loggedInUser = Rx<User?>(null);
  @override
  void onInit() {
    super.onInit();
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
