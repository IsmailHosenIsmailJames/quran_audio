import 'dart:developer';
import 'dart:io';

import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/functions/get_cached_file_size_of_audio.dart';
import 'package:al_quran_audio/src/functions/tajweed_scripts_composer.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final audioController = Get.find<AudioController>();
  final appThemeDataController = Get.find<AppThemeData>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(FluentIcons.settings_24_regular),
            Gap(10),
            Text("Settings"),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.light_mode_rounded),
                  Gap(10),
                  Text(
                    "Theme Brightness",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Gap(5),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: appThemeDataController.themeModeName.value,
                  onChanged: (value) {
                    appThemeDataController.setTheme(value!);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: "system",
                      child: Row(
                        children: [
                          Gap(10),
                          Icon(
                            Icons.brightness_4_rounded,
                            size: 18,
                          ),
                          Gap(10),
                          Text("System default"),
                        ],
                      ),
                    ),
                    const DropdownMenuItem(
                      value: "dark",
                      child: Row(
                        children: [
                          Gap(10),
                          Icon(
                            Icons.dark_mode_rounded,
                            size: 18,
                          ),
                          Gap(10),
                          Text("Dark"),
                        ],
                      ),
                    ),
                    const DropdownMenuItem(
                      value: "light",
                      child: Row(
                        children: [
                          Gap(10),
                          Icon(
                            Icons.light_mode_rounded,
                            size: 18,
                          ),
                          Gap(10),
                          Text("Light"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(15),
              const Row(
                children: [
                  Icon(FluentIcons.text_font_16_filled),
                  Gap(10),
                  Text(
                    "Quran Font Size",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: audioController.fontSizeArabic.value,
                        min: 10,
                        max: 50,
                        divisions: 40,
                        onChanged: (value) async {
                          audioController.fontSizeArabic.value = value;
                          await Hive.box("info").put("fontSizeArabic", value);
                        },
                      ),
                    ),
                    const Gap(5),
                    Text(
                      audioController.fontSizeArabic.value.round().toString(),
                    ),
                    const Gap(10),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Obx(
                  () => Text.rich(
                    TextSpan(
                      children: getTajweedTexSpan(
                        startAyahBismillah(
                          "uthmani_tajweed",
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: audioController.fontSizeArabic.value,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              const Gap(15),
              const Row(
                children: [
                  Icon(
                    Icons.cached_rounded,
                  ),
                  Gap(10),
                  Text(
                    "Audio Cached",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Gap(5),
              Container(
                margin: const EdgeInsets.only(
                  left: 5,
                  top: 5,
                  bottom: 5,
                  right: 5,
                ),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: FutureBuilder(
                  future: getCategorizedCacheFilesWithSize(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<String, List<Map<String, dynamic>>> data =
                          snapshot.data!;

                      List<String> keys = data.keys.toList();

                      return getListOfCacheWidget(keys, data);
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(child: Text("No Data found"));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column getListOfCacheWidget(
      List<String> keys, Map<String, List<Map<String, dynamic>>> data) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 100, child: Text("Cache Size")),
            SizedBox(
              width: 100,
              child: FutureBuilder<int>(
                future: justAudioCache(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    return Text(formatBytes(snapshot.data ?? 0));
                  }
                },
              ),
            ),
            SizedBox(
              width: 100,
              height: 25,
              child: ElevatedButton(
                onPressed: () async {
                  for (var key in data.keys) {
                    var value = data[key];

                    // ignore: avoid_function_literals_in_foreach_calls
                    for (var element in value!) {
                      await File(element['path']).delete();
                      log(element['path'], name: "deleted");
                    }
                  }
                  setState(() {});
                },
                child: const Text("Clean"),
              ),
            ),
          ],
        ),
        const Divider(),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 100, child: Text("Last Modified")),
            SizedBox(width: 100, child: Text("Cache Size")),
            Gap(100),
          ],
        ),
        const Gap(10),
        ...List.generate(
          keys.length,
          (index) {
            List<Map<String, dynamic>> current = data[keys[index]]!;

            int fileSize = 0;

            for (var fileInfo in current) {
              fileSize += (fileInfo['size'] ?? 0) as int;
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 100, child: Text(keys[index])),
                SizedBox(
                    width: 100,
                    child: Text((formatBytes(fileSize, 2)).toString())),
                SizedBox(
                  width: 100,
                  height: 29,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 2),
                    child: OutlinedButton(
                      onPressed: () async {
                        for (var element in current) {
                          await File(element['path']).delete();
                          log(element['path'], name: "deleted");
                        }
                        setState(() {});
                      },
                      child: const Text("Clean"),
                    ),
                  ),
                ),
              ],
            );
          },
        )
      ],
    );
  }
}

Future<Map<String, List<Map<String, dynamic>>>>
    getCategorizedCacheFilesWithSize() async {
  Map<String, List<Map<String, dynamic>>> categorizedFiles = {};
  final cacheDir = Directory(
      join((await getTemporaryDirectory()).path, "just_audio_cache", "remote"));
  final files = cacheDir
      .listSync()
      .whereType<File>(); // List all files in the cache directory

  final now = DateTime.now();

  for (var file in files) {
    final lastModified = file.lastModifiedSync().second;

    final differenceInDays =
        Duration(seconds: now.second - lastModified).inDays;
    final fileSize = file.lengthSync(); // Get the file size

    final fileInfo = {
      'path': file.path,
      'size': fileSize,
    };

    String timeKey = getTheTimeKey(differenceInDays);
    List<Map<String, dynamic>> tem = categorizedFiles[timeKey] ?? [];
    tem.add(fileInfo);
    categorizedFiles[timeKey] = tem;
  }

  return categorizedFiles;
}

String getTheTimeKey(int distanceInDay) {
  String timeKey = "";
  if (distanceInDay > 365) {
    timeKey = "1 Year ago";
  } else if (distanceInDay > 182) {
    timeKey = "6 Months ago";
  } else if (distanceInDay > 91) {
    timeKey = "3 Months ago";
  } else if (distanceInDay > 60) {
    timeKey = "2 Months ago";
  } else if (distanceInDay > 30) {
    timeKey = "1 Month ago";
  } else if (distanceInDay > 21) {
    timeKey = "3 Weeks ag0";
  } else if (distanceInDay > 14) {
    timeKey = "2 Weeks ago";
  } else if (distanceInDay > 7) {
    timeKey = "1 Weeks ago";
  } else if (distanceInDay > 6) {
    timeKey = "6 Days ago";
  } else if (distanceInDay > 5) {
    timeKey = "5 Days ago";
  } else if (distanceInDay > 4) {
    timeKey = "4 Days ago";
  } else if (distanceInDay > 3) {
    timeKey = "3 Days ago";
  } else if (distanceInDay > 2) {
    timeKey = "2 Days ago";
  } else if (distanceInDay > 1) {
    timeKey = "1 Day ago";
  } else {
    timeKey = "Today";
  }
  return timeKey;
}
