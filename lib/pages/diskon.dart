// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, use_key_in_widget_constructors

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/style/color.dart';

class Diskon extends StatefulWidget {
  @override
  State<Diskon> createState() => _DiskonState();
}

class _DiskonState extends State<Diskon> {
  String? selectedValue;
  List<String> dropDownChoice = ["Harga tertinggi", "Harga terendah"];
  List kategori = ["", "", "", ""];
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
                height: width / 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Diskon 30%",
                    style: TextStyle(
                        fontFamily: "popinsemi", fontSize: width / 20),
                  ),
                  DropdownButton(
                    hint: Text("Select by"),
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: dropDownChoice.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                  )
                ],
              ),
              SizedBox(
                height: width / 15,
              ),
              StaggeredGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                children: kategori.map((e) => _card(width)).toList(),
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _card(width) {
    return OpenContainer(
      openBuilder: (context, action) {
        return Container();
      },
      closedBuilder: (context, action) {
        return Container(
            margin: EdgeInsets.all(10),
            height: width / 1.5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width / 25),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: width,
                      height: width / 3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(width / 25),
                              topRight: Radius.circular(width / 25)),
                          image: DecorationImage(
                              image: NetworkImage(
                                  "https://www.yangcanggih.com/wp-content/uploads/2022/01/ASUS-ROG-Zephyrus-Duo-16-4.webp"),
                              fit: BoxFit.cover)),
                    ),
                    Positioned(
                      top: width / 50,
                      left: width / 3.2,
                      child: Container(
                        height: width / 12,
                        width: width / 12,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width),
                            color: Colors.black.withOpacity(0.5)),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Iconsax.shop_add,
                            color: Colors.white,
                            size: width / 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width / 30, vertical: width / 50),
                  child: Row(
                    children: [
                      CircleAvatar(),
                      SizedBox(
                        width: width / 40,
                      ),
                      Text(
                        "Toko haram",
                        style: TextStyle(
                            fontFamily: "popinsemi", fontSize: width / 30),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width / 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ROG Zephyrus",
                        style: TextStyle(
                            fontSize: width / 23, fontFamily: "popinsemi"),
                      ),
                      Text(
                        "Rp 15.000",
                        style: TextStyle(fontSize: width / 35, color: grayText),
                      ),
                      Text(
                        "Cibitung, Bekasi",
                        style: TextStyle(fontSize: width / 35, color: grayText),
                      ),
                    ],
                  ),
                )
              ],
            ));
      },
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
          "Kategori",
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
