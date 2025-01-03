import 'package:al_quran_audio/src/api/appwrite/config.dart';

Future<bool> isUserLoggedIn() async {
  final hasLoggedIn = await AppWriteConfig.account.get().then((response) {
    return true;
  }).catchError((error) {
    return false;
  });
  return hasLoggedIn;
}
