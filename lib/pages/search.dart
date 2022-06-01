// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/pages/search_result.dart';
import 'package:lapak/widget/custom_route.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          return;
                        } else {
                          Navigator.of(context).push(CustomPageRoute(
                              child: SearchResult(
                            search: value,
                          )));
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
                height: width / 30,
              ),
              _searchResult(width),
            ],
          ),
        ),
      )),
    );
  }

  Widget _searchResult(width) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color.fromARGB(255, 230, 230, 230),
        child: Icon(
          Iconsax.search_normal_1,
          size: width / 20,
          color: Colors.grey,
        ),
      ),
      title: Text("sepatu bekas"),
    );
  }
}
