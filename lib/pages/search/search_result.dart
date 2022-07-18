// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, must_be_immutable, sized_box_for_whitespace, avoid_print, unused_field, curly_braces_in_flow_control_structures
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/models/detail_model.dart';
import 'package:lapak/models/search_model.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/custom_card.dart';
import 'package:lapak/widget/skeleton.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchResult extends StatefulWidget {
  String search;
  SearchResult({required this.search});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  TextEditingController search = TextEditingController();
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
                    return StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2,
                      children: [
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                      ],
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data.data.length == 0)
                        return Column(
                          children: [
                            LottieBuilder.asset(
                                "assets/json/93134-not-found.json"),
                            Text("Barang tidak ditemukan",
                                style: TextStyle(
                                    fontSize: width / 18,
                                    color: grayText,
                                    fontFamily: "popinsemi"),
                                textAlign: TextAlign.center)
                          ],
                        );
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Show ${snapshot.data.data.length} result",
                                style: TextStyle(color: grayText),
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
        var value = DetailModel(
            id: data.item.id,
            storeId: data.id,
            owner: data.owner,
            namaToko: data.namaToko,
            daerah: data.daerah,
            fotoToko: data.fotoToko,
            namaBarang: data.item.namaBarang,
            harga: data.item.harga,
            deskripsi: data.item.deskripsi,
            kategori: data.item.kategori,
            fotoBarang: data.item.fotoBarang,
            diskon: data.item.diskon);
        return CustomCard(
          data: value,
          where: "",
        );
      }).toList(),
    );
  }
}
