// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/pages/search/search_result.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future value;
@override
  void initState() {
    value = ApiService().getPesanan();
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
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Iconsax.arrow_left),
                    iconSize: width / 20,
                  ),
                  Container(
                    width: width / 1.3,
                    child: TextField(
                      autofocus: true,
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          return;
                        } else {
                          Get.to(
                              SearchResult(
                                search: value,
                              ),
                              transition: Transition.rightToLeft);
                        }
                      },
                      style: TextStyle(fontSize: width / 30),
                      decoration: InputDecoration(
                          hintText: "Search",
                          suffixIcon: Icon(Iconsax.search_normal_1),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: width / 35),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(width / 30))),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: width / 30,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
