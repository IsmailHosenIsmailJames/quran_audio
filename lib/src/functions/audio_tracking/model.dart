import 'dart:convert';

class TrackingAudioModel {
  int surahNumber;
  int totalDurationInSeconds;
  int totalPlayedDurationInSeconds;
  String lastReciterId;

  TrackingAudioModel({
    required this.surahNumber,
    required this.totalDurationInSeconds,
    required this.totalPlayedDurationInSeconds,
    required this.lastReciterId,
  });

  TrackingAudioModel copyWith({
    int? surahNumber,
    int? totalDurationInSeconds,
    int? totalPlayedDurationInSeconds,
    String? lastReciterId,
  }) =>
      TrackingAudioModel(
        surahNumber: surahNumber ?? this.surahNumber,
        totalDurationInSeconds:
            totalDurationInSeconds ?? this.totalDurationInSeconds,
        totalPlayedDurationInSeconds:
            totalPlayedDurationInSeconds ?? this.totalPlayedDurationInSeconds,
        lastReciterId: lastReciterId ?? this.lastReciterId,
      );

  factory TrackingAudioModel.fromJson(String str) =>
      TrackingAudioModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TrackingAudioModel.fromMap(Map<String, dynamic> json) =>
      TrackingAudioModel(
        surahNumber: json["surahNumber"],
        totalDurationInSeconds: json["totalDurationInSeconds"],
        totalPlayedDurationInSeconds: json["totalPlayedDurationInSeconds"],
        lastReciterId: json["lastReciterID"],
      );

  Map<String, dynamic> toMap() => {
        "surahNumber": surahNumber,
        "totalDurationInSeconds": totalDurationInSeconds,
        "totalPlayedDurationInSeconds": totalPlayedDurationInSeconds,
        "lastReciterID": lastReciterId,
      };
}
