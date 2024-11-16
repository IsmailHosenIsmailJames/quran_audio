import 'package:al_quran_audio/src/core/recitation_info/recitation_info_model.dart';
import 'package:al_quran_audio/src/core/recitation_info/recitations.dart';
import 'package:al_quran_audio/src/theme/colors.dart';
import 'package:al_quran_audio/src/theme/theme_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ChoiceDefaultRecitation extends StatefulWidget {
  const ChoiceDefaultRecitation({super.key});

  @override
  State<ChoiceDefaultRecitation> createState() =>
      _ChoiceDefaultRecitationState();
}

class _ChoiceDefaultRecitationState extends State<ChoiceDefaultRecitation> {
  int selectedIndex = 0;
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.play_arrow),
                  ),
                  const Gap(10),
                  Expanded(
                    child: SingleChildScrollView(
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
