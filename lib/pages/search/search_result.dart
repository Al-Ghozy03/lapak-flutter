// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, must_be_immutable, sized_box_for_whitespace, avoid_print, unused_field
import 'dart:async';
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/search_model.dart';
import 'package:lapak/pages/detail.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:lapak/widget/skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  int userId = 0;
  void getUserId() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    setState(() {
      userId = Jwt.parseJwt(storage.getString("token").toString())["id"];
    });
  }

  FutureOr changeResult(dynamic items) async {
    getResult = ApiService().search(search.text, items);
  }

  Future deleteBarang(int id) async {
    Uri url = Uri.parse("$baseUrl/barang/delete/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.delete(url, headers: headers);
    if (res.statusCode == 200) {
      print("berhasil hapus");
      return true;
    } else {
      print(res.statusCode);
      print("gagal");
    }
  }

  Future addToCart(id) async {
    Uri url = Uri.parse("$baseUrl/cart/add/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.post(url, headers: headers);
    if (res.statusCode == 200) {
      print("berhasil");
    } else {
      print(res.statusCode);
      print(jsonDecode(res.body));
    }
  }

  @override
  void initState() {
    getUserId();
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

  Widget _card(width, Search data) {
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      children: data.data.map((data) {
        return _customCard(width, data);
      }).toList(),
    );
  }

  Widget _customCard(width, data) {
    return OpenContainer(
      openBuilder: (context, action) {
        return Detail(data: data,where: "search",);
      },
      closedBuilder: (context, action) {
        return Container(
            margin: EdgeInsets.all(10),
            width: width / 2,
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
                              image: NetworkImage(data.item.fotoBarang),
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
                          onPressed: () {
                            if (data.owner == userId) {
                              deleteBarang(data.item.id);
                            } else {
                              addToCart(data.item.id);
                            }
                          },
                          icon: Icon(
                            data.owner != userId
                                ? Iconsax.shop_add
                                : Iconsax.trash,
                            color: Colors.white,
                            size: width / 25,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width / 30, vertical: width / 50),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(data.fotoToko),
                      ),
                      SizedBox(
                        width: width / 40,
                      ),
                      Text(
                        data.namaToko.length >= 8
                            ? "${data.namaToko.substring(0, 7)}..."
                            : data.namaToko,
                        style: TextStyle(
                            fontFamily: "popinsemi", fontSize: width / 30),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            data.item.namaBarang.length >= 15
                                ? "${data.item.namaBarang.substring(0, 12)}..."
                                : data.item.namaBarang,
                            style: TextStyle(
                                fontSize: width / 23, fontFamily: "popinsemi"),
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(data.item.harga, 0),
                          style:
                              TextStyle(fontSize: width / 35, color: grayText),
                        ),
                        Text(
                          data.daerah,
                          style:
                              TextStyle(fontSize: width / 35, color: grayText),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ));
      },
    );
  }
}
