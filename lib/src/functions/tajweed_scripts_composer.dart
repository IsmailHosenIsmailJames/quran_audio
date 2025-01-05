import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

List<InlineSpan> getTajweedTexSpan(String ayah,
    {bool hideEnd = false, bool doBold = false}) {
  List<Map<String, String?>> tajweed = extractWordsGetTazweeds(ayah);
  List<InlineSpan> spanText = [];
  for (int i = 0; i < tajweed.length; i++) {
    Map<String, String?> taz = tajweed[i];
    String word = taz['word'] ?? "";
    String className = taz['class'] ?? "null";
    String tag = taz['tag'] ?? "null";
    if (className == 'null' || tag == "null") {
      spanText.add(
        TextSpan(text: word),
      );
    } else {
      if (className == "end" && hideEnd != true) {
        spanText.add(
          TextSpan(
            text: "۝$word ",
          ),
        );
      } else {
        if (hideEnd && word.length == 1 && i == 13) {
          continue;
        }
        Color textColor = colorsForTajweed[className] ??
            const Color.fromARGB(255, 121, 85, 72);
        spanText.add(
          TextSpan(
            text: word,
            style: TextStyle(
              color: textColor,
            ),
          ),
        );
      }
    }
  }
  return spanText;
}

String startAyahBismillah(String scriptType) {
  final scriptBox = Hive.box("info");
  return scriptBox.get("uthmani_tajweed/1:1", defaultValue: "");
}

Map<String, Color> colorsForTajweed = {
  "ham_wasl": const Color.fromARGB(200, 145, 145, 145),
  "laam_shamsiyah": const Color.fromARGB(200, 149, 149, 255),
  "madda_normal": const Color.fromARGB(255, 200, 0, 255),
  "madda_permissible": const Color.fromARGB(255, 246, 123, 255),
  "madda_necessary": const Color.fromARGB(200, 255, 0, 238),
  "idgham_wo_ghunnah": const Color.fromARGB(255, 72, 142, 255),
  "ghunnah": const Color.fromARGB(255, 11, 169, 22),
  "slnt": const Color.fromARGB(200, 114, 114, 114),
  "qalaqah": const Color.fromARGB(255, 155, 212, 91),
  "ikhafa": const Color.fromARGB(255, 255, 140, 32),
  "madda_obligatory": const Color.fromARGB(255, 192, 90, 165),
  "idgham_ghunnah": const Color.fromARGB(255, 0, 79, 216),
};

Map<String, String> detailsOfTazwed = {
  "ham_wasl": "",
  "laam_shamsiyah": "",
  "madda_normal": "",
  "madda_permissible": "",
  "madda_necessary": "",
  "idgham_wo_ghunnah": "",
  "ghunnah": "",
  "slnt": "",
  "qalaqah": "",
  "ikhafa": "",
  "madda_obligatory": "",
  "idgham_ghunnah": "",
};

List<Map<String, String?>> extractWordsGetTazweeds(String text) {
  final regexp = RegExp(r'<[^>]+>(.*?)</[^>]+>|[^<]+');
  final matchers = regexp.allMatches(text);
  final allWords = matchers.map((match) => match.group(0)!).toList();
  List<Map<String, String?>> tajweed = [];
  for (String word in allWords) {
    List<Map<String, String?>> tem = getTagAndWord(word);
    if (tem.isEmpty) {
      tajweed.add({
        "tag": "null",
        "class": "null",
        "word": word,
      });
    } else {
      tajweed.add(tem[0]);
    }
  }
  return tajweed;
}

List<Map<String, String?>> getTagAndWord(String word) {
  final regex = RegExp(
      r'<(?<tag>\w+)\s+class=(?<class>\w+)>(?<word>[^<]+)</(?<tag2>\1)>' // Capture tag, class, and word
      );

  final matches = regex.allMatches(word);
  final result = matches
      .map((match) => {
            "tag": match.namedGroup('tag'),
            "class": match.namedGroup('class'),
            "word": match.namedGroup('word'),
          })
      .toList();
  return result;
}
