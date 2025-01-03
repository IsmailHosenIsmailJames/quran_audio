import 'package:al_quran_audio/src/core/recitation_info/recitation_info_model.dart';
import 'dart:convert';

class PlayListModel {
  final int surahNumber;
  final ReciterInfoModel reciter;

  PlayListModel({
    required this.surahNumber,
    required this.reciter,
  });

  PlayListModel copyWith({
    int? surahNumber,
    ReciterInfoModel? reciter,
  }) =>
      PlayListModel(
        surahNumber: surahNumber ?? this.surahNumber,
        reciter: reciter ?? this.reciter,
      );

  factory PlayListModel.fromJson(String str) =>
      PlayListModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PlayListModel.fromMap(Map<String, dynamic> json) => PlayListModel(
        surahNumber: json["surahNumber"],
        reciter: ReciterInfoModel.fromMap(json["reciter"]),
      );

  Map<String, dynamic> toMap() => {
        "surahNumber": surahNumber,
        "reciter": reciter.toMap(),
      };
}