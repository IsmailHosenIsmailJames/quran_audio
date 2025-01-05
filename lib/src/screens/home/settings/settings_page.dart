import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
            Obx(
              () => DropdownButton<String>(
                value: appThemeDataController.themeModeName.value,
                onChanged: (value) {
                  appThemeDataController.setTheme(value!);
                },
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
                        setState(() {});
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
            const Gap(15),
            const Row(
              children: [
                Icon(
                  Icons.cached_rounded,
                ),
                Gap(10),
                Text(
                  "Cached Size",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            FutureBuilder<int>(
              future: getCacheSize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return Text("Cache Size: ${formatBytes(snapshot.data ?? 0)}");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

String formatBytes(int bytes, [int decimals = 2]) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  int i = (log(bytes) / log(1024)).floor();
  double size = bytes / pow(1024, i);
  return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
}

Future<int> getCacheSize() async {
  final cacheDir = await getCacheDirectory();
  int totalSize = 0;

  if (cacheDir.existsSync()) {
    cacheDir.listSync().forEach((file) {
      if (file is File) {
        totalSize += file.lengthSync();
      }
    });
  }

  return totalSize;
}

Future<Directory> getCacheDirectory() async {
  return await getTemporaryDirectory();
}
