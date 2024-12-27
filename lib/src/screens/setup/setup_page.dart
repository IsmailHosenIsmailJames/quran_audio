import 'dart:convert';

import 'package:al_quran_audio/src/core/recitation_info/recitations.dart';
import 'package:al_quran_audio/src/screens/home/home_page.dart';
import 'package:al_quran_audio/src/screens/setup/controller/setup_controller.dart';
import 'package:al_quran_audio/src/screens/setup/pages/choice_default_recitation.dart';
import 'package:al_quran_audio/src/screens/setup/pages/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toastification/toastification.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int pageIndex = 0;
  PageController pageController = PageController();
  final setupPageController = Get.put(SetupController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (value) {
              setState(() {
                pageIndex = value;
              });
            },
            children: const [
              IntroPage(),
              ChoiceDefaultRecitation(),
            ],
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    if (pageIndex == 0) {
                      pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    } else {
                      if (setupPageController.selectedIndex.value == -1) {
                        toastification.show(
                          context: context,
                          title: const Text("Please select a reciter"),
                          type: ToastificationType.info,
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                      } else {
                        try {
                          final reciter = recitationsInfoList[
                              setupPageController.selectedIndex.value];
                          await Hive.box("info")
                              .put("default_reciter", jsonEncode(reciter));
                          await Hive.box("info")
                              .put("reciter", jsonEncode(reciter));

                          Get.offAll(() => const HomePage());
                        } catch (e) {
                          toastification.show(
                            context: context,
                            title: const Text("Something went wrong"),
                            type: ToastificationType.info,
                            autoCloseDuration: const Duration(seconds: 3),
                          );
                        }
                      }
                    }
                  },
                  child: Row(
                    children: [
                      const Spacer(flex: 6),
                      Text(pageIndex == 0 ? "Next" : "Finish"),
                      const Spacer(flex: 5),
                      Icon(pageIndex == 0 ? Icons.arrow_forward : Icons.done),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
