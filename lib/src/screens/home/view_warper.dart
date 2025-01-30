import 'dart:developer';

import 'package:al_quran_audio/src/screens/home/home_desktop_page.dart';
import 'package:al_quran_audio/src/screens/home/home_page.dart';
import 'package:al_quran_audio/widget/warper.dart';
import 'package:flutter/widgets.dart';

class ViewWarper extends StatefulWidget {
  const ViewWarper({super.key});

  @override
  State<ViewWarper> createState() => _ViewWarperState();
}

class _ViewWarperState extends State<ViewWarper> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    log(width.toString());
    return warperWithCenter(
        width > 900 ? const HomeDesktopPage() : const HomePage(),
        gradientReverse: true);
  }
}
