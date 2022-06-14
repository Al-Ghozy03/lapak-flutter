// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: width / 40, vertical: width / 40),
      padding: EdgeInsets.all(width / 40),
      height: height / 3,
      width: width,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(width / 20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 10,
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 3),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeShimmer(
            width: width,
            height: height / 6,
            radius: width / 50,
            baseColor: Colors.grey.withOpacity(0.2),
            highlightColor: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(
            height: width / 30,
          ),
          FadeShimmer(
            width: width,
            height: height / 75,
            radius: width,
            baseColor: Colors.grey.withOpacity(0.2),
            highlightColor: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(
            height: width / 50,
          ),
          FadeShimmer(
            width: width / 5,
            height: height / 75,
            radius: width,
            baseColor: Colors.grey.withOpacity(0.2),
            highlightColor: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
