import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Center(
            child: Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.6),
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
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.center,
            child: Text(
              "The Quran Audio Recitation App brings together a curated collection of 79 reciters, providing an immersive auditory experience of the Quran. With a focus on simplicity, accessibility, and quality, the app caters to users of all ages and preferences. Whether you are at home, commuting, or meditating, this app lets you carry the soul of the Quran wherever you go.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
           Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.center,
            child: Text(
              "Discover, Listen, Reflect.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(0.8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Data collected from :"),
                  TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse("https://quran.com/"),
                          mode: LaunchMode.externalApplication);
                    },
                    child: const Text("quran.com"),
                  ),
                  const Text("and"),
                  TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse("https://everyayah.com/"),
                            mode: LaunchMode.externalApplication);
                      },
                      child: const Text("everyayah.com")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
