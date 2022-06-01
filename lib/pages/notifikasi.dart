// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Notifikasi extends StatefulWidget {
  const Notifikasi({Key? key}) : super(key: key);

  @override
  State<Notifikasi> createState() => _NotifikasiState();
}

class _NotifikasiState extends State<Notifikasi> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(width / 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(width),
              SizedBox(
                height: width / 25,
              ),
              Text(
                "Hari ini",
                style: TextStyle(fontFamily: "popinsemi", fontSize: width / 27),
              ),
              SizedBox(
                height: width / 25,
              ),
              _notifikasi(width),
            ],
          ),
        )),
      ),
    );
  }

  Widget _notifikasi(width) {
    return Row(
      children: [
        CircleAvatar(
          maxRadius: width / 17,
          minRadius: width / 17,
        ),
        SizedBox(
          width: width / 27,
        ),
        RichText(
            text: TextSpan(
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "popin",
                    fontSize: width / 29),
                children: [
              TextSpan(
                  text: "Syeirayura",
                  style: TextStyle(fontFamily: "popinsemi")),
              TextSpan(text: " memesan laptop geming")
            ]))
      ],
    );
  }

  Widget _header(width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Iconsax.arrow_left)),
        Text(
          "Notifikasi",
          style: TextStyle(
            fontSize: width / 15,
            fontFamily: "popinsemi",
          ),
        ),
        Text(
          "Chat",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
