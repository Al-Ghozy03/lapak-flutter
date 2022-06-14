// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:lapak/style/color.dart';

class Attribute extends StatelessWidget {
  const Attribute({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
          text: TextSpan(
              style: TextStyle(color: Colors.black, fontFamily: "popin"),
              children: [
            TextSpan(text: "Illustration from "),
            TextSpan(
                text: "Freepik and Flaticon",
                style: TextStyle(fontFamily: "popinsemi", color: blueTheme))
          ])),
    );
  }
}
