// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, use_key_in_widget_constructors, curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/diskon_model.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/attribute.dart';
import 'package:lapak/widget/custom_card.dart';
import 'package:lapak/widget/skeleton.dart';
import 'package:material_dialogs/material_dialogs.dart';

class DiskonPage extends StatefulWidget {
  @override
  State<DiskonPage> createState() => _DiskonPageState();
}

class _DiskonPageState extends State<DiskonPage> {
  String? selectedValue;
  List<String> dropDownChoice = ["Harga tertinggi", "Harga terendah"];
  late Future getDiskon;
  @override
  void initState() {
    getDiskon = ApiService().getDiskon("asc");
    super.initState();
  }

  FutureOr changeFilter(String value) {
    getDiskon = ApiService().getDiskon(value);
  }

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
                  // DropdownButton(
                  //   hint: Text("Select by"),
                  //   value: selectedValue,
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       selectedValue = newValue!;
                  //     });
                  //     if (selectedValue == "Harga terendah") {
                  //       changeFilter("asc");
                  //     } else {
                  //       changeFilter("desc");
                  //     }
                  //   },
                  //   items: dropDownChoice.map((e) {
                  //     return DropdownMenuItem(
                  //       value: e,
                  //       child: Text(e),
                  //     );
                  //   }).toList(),
                  // )
                ],
              ),
              SizedBox(
                height: width / 15,
              ),
              FutureBuilder(
                future: getDiskon,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2,
                      children: [
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("terjadi kesalahan"),
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data.data.length == 0)
                        return Center(
                            child:LottieBuilder.asset("assets/json/93134-not-found.json"));
                      return _card(width, snapshot.data);
                    } else {
                      return Center(
                        child: Text("kosong"),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _card(width, Diskon data) {
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      children: data.data.map((data) {
        return CustomCard(
          data: data,
          where: "",
        );
      }).toList(),
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
          "Diskon",
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
