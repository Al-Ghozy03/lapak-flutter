// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, avoid_print, must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/pages/checkout/after_checkout.dart';
import 'package:lapak/pages/detail.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomCard extends StatefulWidget {
  CustomCard({Key? key, required this.data, this.where}) : super(key: key);
  final data;
  String? where;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
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

  Future deleteFromCart(id) async {
    Uri url = Uri.parse("$baseUrl/cart/delete/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.delete(url, headers: headers);
    if (res.statusCode == 200) {
      print("berhasil");
    } else {
      print(res.statusCode);
      print(res.body);
      print("gagal");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return OpenContainer(
      openBuilder: (context, action) {
        if (widget.where == "pesanan") {
          return AfterCheckout(
            data: widget.data,
          );
        }
        return Detail(
          data: widget.data,
        );
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
                              image: NetworkImage(widget.data.fotoBarang),
                              fit: BoxFit.cover)),
                    ),
                    widget.where != "pesanan"
                        ? Positioned(
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
                                  if (widget.where == "") {
                                    addToCart(widget.data.id);
                                  } else {
                                    deleteFromCart(widget.data.id);
                                  }
                                },
                                icon: Icon(
                                  widget.where == ""
                                      ? Iconsax.shop_add
                                      : Iconsax.trash,
                                  color: Colors.white,
                                  size: width / 25,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width / 30, vertical: width / 50),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.data.fotoToko),
                      ),
                      SizedBox(
                        width: width / 40,
                      ),
                      Text(
                        widget.data.namaBarang.length >= 12
                            ? "${widget.data.namaBarang.substring(0, 10)}..."
                            : widget.data.namaBarang,
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
                        widget.data.namaBarang.length >= 15
                            ? "${widget.data.namaBarang.substring(0, 12)}..."
                            : widget.data.namaBarang,
                        style: TextStyle(
                            fontSize: width / 23, fontFamily: "popinsemi"),
                      ),
                      Text(
                        CurrencyFormat.convertToIdr(widget.data.harga, 0),
                        style: TextStyle(fontSize: width / 35, color: grayText),
                      ),
                      Text(
                        widget.data.daerah,
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
}
