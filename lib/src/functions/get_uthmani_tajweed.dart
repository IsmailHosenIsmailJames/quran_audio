import 'dart:convert';
import 'dart:developer';

import 'package:al_quran_audio/src/api/apis.dart';
import 'package:al_quran_audio/src/core/surah_ayah_count.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

Future<List<String>?> getUthmaniTajweed({int? surah, int? ayah}) async {
  final infoBox = Hive.box("info");

  if (isUthmaniTajweedExist()) {
    log("uthmani_tajweed already exist");
  } else {
    final result = await getDownloadUthmaniTajweed();
    if (result) {
      if (ayah != null && surah != null) {
        infoBox.get("uthmani_tajweed/$surah:$ayah");
      } else if (ayah == null && surah != null) {
        try {
          List<String> toReturn = [];
          int ayahCount = surahAyahCount[surah - 1];
          for (int i = 1; i < ayahCount; i++) {
            toReturn.add(
              infoBox.get("uthmani_tajweed/$surah:${i + 1}", defaultValue: ""),
            );
          }
          return toReturn;
        } catch (e) {
          return null;
        }
      }
    } else {
      return null;
    }
  }
  return null;
}

Future<bool> getDownloadUthmaniTajweed() async {
  try {
    final infoBox = Hive.box("info");

    log("Getting uthmani_tajweed");
    final response = await http.get(Uri.parse(getUthmaniTajweedAPI));

    log("get uthmani tajweed successful");
    if (response.statusCode == 200) {
      final data = Map<String, dynamic>.from(jsonDecode(response.body));
      List verses = List.from(data['verses']);

      log("saving all uthmani_tajweed");
      for (int i = 0; i < verses.length; i++) {
        infoBox.put("uthmani_tajweed/${verses[i]['verse_key']}",
            verses[i]['text_uthmani_tajweed']);
      }
      log("uthmani_tajweed saved");
      return true;
    } else {
      return false;
    }
  } catch (e) {
    log("Unable to download : $e");
    return false;
  }
}

bool isUthmaniTajweedExist() {
  final infoBox = Hive.box("info");
  return infoBox.containsKey("uthmani_tajweed/1:1");
}
