import 'package:al_quran_audio/src/core/audio/controller/audio_controller.dart';
import 'package:al_quran_audio/src/functions/get_cached_file_size_of_audio.dart';
import 'package:al_quran_audio/src/functions/tajweed_scripts_composer.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

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
                  "Cached Size",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(10),
            Container(
              margin: const EdgeInsets.only(
                left: 15,
                top: 5,
                bottom: 5,
                right: 5,
              ),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Total Cache Size :  "),
                      FutureBuilder<int>(
                        future: justAudioCache(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else {
                            return Text(formatBytes(snapshot.data ?? 0));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
