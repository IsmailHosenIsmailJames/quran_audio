import 'dart:convert';

class ReciterInfoModel {
  final String name;
  final String id;

  ReciterInfoModel({
    required this.name,
    required this.id,
  });

  ReciterInfoModel copyWith({
    String? name,
    String? id,
  }) =>
      ReciterInfoModel(
        name: name ?? this.name,
        id: id ?? this.id,
      );

  factory ReciterInfoModel.fromJson(String str) =>
      ReciterInfoModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ReciterInfoModel.fromMap(Map<String, dynamic> json) =>
      ReciterInfoModel(
        name: json["name"],
        id: json["id"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "id": id,
      };
}
