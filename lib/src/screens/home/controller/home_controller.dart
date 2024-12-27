import 'package:al_quran_audio/src/core/recitation_info/recitation_info_model.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeController extends GetxController {
  Rx<ReciterInfoModel> reciter = ReciterInfoModel.fromJson(
    Hive.box('info').get('default_reciter'),
  ).obs;
  RxInt currentSurah = (-1).obs;
}
