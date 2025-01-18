import 'package:al_quran_audio/src/theme/theme_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:url_launcher/url_launcher.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> listOfPoints = [
      "Get 80 best Quran reciters recitations.",
      "Read Quran with Tajweed while listening.",
      "Create your personalized playlists.",
      "Enjoy background playback support.",
      "Track your listening progress.",
      "Share and download your favorite one.",
      "Backup playlists and listening history.",
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(50),
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.6),
                      spreadRadius: 10,
                      blurRadius: 40,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage(
                      "assets/AlQuranAudio.jpg",
                    ),
                  ),
                ),
              ),
            ),
            const Gap(30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Gap(10),
                const Text(
                  "Theme",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(5),
                themeIconButton
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Quran Companion",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: List.generate(
                  listOfPoints.length,
                  (index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      minTileHeight: 20,
                      horizontalTitleGap: 6,
                      minVerticalPadding: 4,
                      leading: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.green.shade700,
                        child: const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      title: Text(
                        listOfPoints[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Divider(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(0.8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("We used "),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse("https://quran.com/"),
                            mode: LaunchMode.externalApplication);
                      },
                      child: Text(
                        "Quran.com",
                        style: TextStyle(
                          color: Colors.green.shade400,
                        ),
                      ),
                    ),
                    const Text(" & "),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse("https://quranicaudio.com/"),
                            mode: LaunchMode.externalApplication);
                      },
                      child: Text(
                        "Quranicaudio.com",
                        style: TextStyle(color: Colors.green.shade400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
