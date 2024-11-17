import 'dart:developer';

import 'package:al_quran_audio/src/core/audio/play_quran_audio.dart';
import 'package:al_quran_audio/src/core/recitation_info/recitation_info_model.dart';
import 'package:al_quran_audio/src/core/recitation_info/recitations.dart';
import 'package:al_quran_audio/src/theme/colors.dart';
import 'package:al_quran_audio/src/theme/theme_icon_button.dart';
import 'package:flutter/material.dart';

class ChoiceDefaultRecitation extends StatefulWidget {
  const ChoiceDefaultRecitation({super.key});

  @override
  State<ChoiceDefaultRecitation> createState() =>
      _ChoiceDefaultRecitationState();
}

class _ChoiceDefaultRecitationState extends State<ChoiceDefaultRecitation> {
  int selectedIndex = 0;
  int playingIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choice Default Reciter"),
        actions: [
          themeIconButton,
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 60),
        itemCount: recitationsInfoList.length,
        itemBuilder: (context, index) {
          final current =
              RecitationInfoModel.fromMap(recitationsInfoList[index]);
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withOpacity(0.2),
              ),
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                      tooltip: "Play Recitation from ${current.name}",
                      icon: Icon(playingIndex == index
                          ? Icons.pause
                          : Icons.play_arrow),
                      onPressed: () async {
                        setState(() {
                          playingIndex = index;
                        });
                        await ManageQuranAudio.playMultipleAyahOfSurah(
                          surahNumber: 1,
                          reciter: current,
                        );

                        log("finished");
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 10),
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        current.name
                            .replaceAll(".Com", "")
                            .replaceAll(".Net", ""),
                      ),
                    ),
                  ),
                  if (index == selectedIndex)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: MyColors.mainColor,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 132, 119, 119)
                                .withOpacity(0.4),
                            spreadRadius: 5,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.done,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
