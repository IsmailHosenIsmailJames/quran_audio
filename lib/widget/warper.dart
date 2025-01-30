import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget warperWithCenter(Widget child, {double? width, bool? gradientReverse}) {
  return Scaffold(
    body: Center(
      child: Container(
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              spreadRadius: 100 * (gradientReverse == true ? -1 : 1),
              blurRadius: 140,
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}
