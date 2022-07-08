import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';

class Error extends StatelessWidget {
  const Error({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        LottieBuilder.asset("assets/94900-error.json"),
        Text(
          "Something went wrong",
          style: TextStyle(fontSize: width / 15, fontFamily: "popinsemi"),
        )
      ],
    );
  }
}
