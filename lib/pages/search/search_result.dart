// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, must_be_immutable, sized_box_for_whitespace, avoid_print, unused_field

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/search_model.dart';
import 'package:lapak/pages/detail.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/custom_card.dart';
import 'package:lapak/widget/skeleton.dart';

class SearchResult extends StatefulWidget {
  String search;
  SearchResult({required this.search});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  String? selectedValue;
  List<String> dropDownChoice = ["Harga tertinggi", "Harga terendah"];
  TextEditingController search = TextEditingController();
  late Search _search;
  late Future getResult;

  FutureOr changeResult(dynamic value) async {
    getResult = ApiService().search(search.text, value);
  }

  @override
  void initState() {
    search.text = widget.search;
    getResult = ApiService().search(widget.search, "asc");
    super.initState();
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
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Iconsax.arrow_left),
                    iconSize: width / 20,
                  ),
                  Container(
                    width: width / 1.3,
                    child: TextField(
                      controller: search,
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          return;
                        } else {
                          changeResult("asc");
                        }
                      },
                      style: TextStyle(fontSize: width / 30),
                      decoration: InputDecoration(
                          hintText: "Search",
                          suffixIcon: Icon(Iconsax.search_normal_1),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0, horizontal: width / 35),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(width / 30))),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: width / 15,
              ),
              FutureBuilder(
                future: getResult,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Column(
                      children: [
                        StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 2,
                          children: [
                            Skeleton(),
                            Skeleton(),
                            Skeleton(),
                            Skeleton(),
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("terjadi kesalahan"),
                    );
                  } else {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Show ${snapshot.data.data.length} result",
                                style: TextStyle(color: grayText),
                              ),
                              DropdownButton(
                                hint: Text("Select by"),
                                value: selectedValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue = newValue!;
                                  });
                                  if (selectedValue == "Harga terendah") {
                                    changeResult("asc");
                                  } else {
                                    changeResult("desc");
                                  }
                                },
                                items: dropDownChoice.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: width / 25,
                          ),
                          _card(width, snapshot.data),
                        ],
                      );
                    } else {
                      return Center(
                        child: Text("kosong"),
                      );
                    }
                  }
                },
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _card(width, Search search) {
    return StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        children: search.data.map((data) {
          return OpenContainer(
            openBuilder: (context, action) {
              return Detail(
                data: data,
              );
            },
            closedBuilder: (context, action) {
              return CustomCard(
                data: data,
                where: "",
              );
            },
          );
        }).toList());
  }
}
