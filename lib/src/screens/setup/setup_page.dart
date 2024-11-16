import 'package:al_quran_audio/src/screens/setup/pages/choice_default_recitation.dart';
import 'package:al_quran_audio/src/screens/setup/pages/intro_page.dart';
import 'package:flutter/material.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int pageIndex = 0;
  PageController pageController = PageController();
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
                  onPressed: () {
                    if (pageIndex == 0) {
                      pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    } else {
                      // TODO : Type my logic
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
