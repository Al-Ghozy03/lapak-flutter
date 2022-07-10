// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, avoid_print, must_be_immutable, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/pages/checkout/after_checkout.dart';
import 'package:lapak/pages/detail.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomCard extends StatefulWidget {
  CustomCard({Key? key, required this.data, this.where}) : super(key: key);
  final data;
  var where;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return OpenContainer(
      openElevation: 0,
      closedElevation: 0,
      openBuilder: (context, action) {
        if (widget.where == "pesanan") {
          return AfterCheckout(
            data: widget.data,
          );
        }
        return Detail(
          data: widget.data,
          where: widget.where,
        );
      },
      closedBuilder: (context, action) {
        return Container(
            margin: EdgeInsets.all(10),
            width: width / 2,
            height: width / 1.4,
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
                            left: width / 3.4,
                            child: Container(
                              height: width / 12,
                              width: width / 12,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(width),
                                  color: Colors.black.withOpacity(0.5)),
                              child: IconButton(
                                onPressed: () {
                                  addToCart(widget.data.id);
                                },
                                icon: Icon(
                                  widget.where == "" ||
                                          widget.where == "kategori"
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
                        maxRadius: width/25,
                        minRadius: width/25,
                        backgroundImage: NetworkImage(widget.data.fotoToko),
                      ),
                      SizedBox(
                        width: width / 40,
                      ),
                      Text(
                        widget.data.namaToko.length >= 8
                            ? "${widget.data.namaToko.substring(0, 7)}..."
                            : widget.data.namaToko,
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
                            widget.data.namaBarang,
                            style: TextStyle(
                              fontSize: width / 23,
                              fontFamily: "popinsemi",
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                              widget.data.diskon == 0
                                  ? widget.data.harga
                                  : (0.5 * widget.data.harga) -
                                      widget.data.diskon,
                              0),
                          style:
                              TextStyle(fontSize: width / 35, color: grayText),
                        ),
                        widget.data.diskon == 0
                            ? Container()
                            : Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: width / 200),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width / 50,
                                        vertical: width / 200),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(width / 90),
                                        color: Colors.blue.withOpacity(0.7)),
                                    child: Text(
                                      "${widget.data.diskon}%",
                                      style: TextStyle(
                                          fontSize: width / 35,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: width / 40),
                                  Text(
                                    CurrencyFormat.convertToIdr(
                                        widget.data.harga, 0),
                                    style: TextStyle(
                                        fontSize: width / 35,
                                        color: Colors.grey.withOpacity(0.6),
                                        decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              ),
                        Text(
                          widget.data.daerah,
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
