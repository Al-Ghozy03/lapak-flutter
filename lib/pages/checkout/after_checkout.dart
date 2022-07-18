// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AfterCheckout extends StatefulWidget {
  final data;
  AfterCheckout({this.data});

  @override
  State<AfterCheckout> createState() => _AfterCheckoutState();
}

class _AfterCheckoutState extends State<AfterCheckout> {
  int total = 1;
  bool isLoading = false;
  Future barangSampai(int id) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    Uri url = Uri.parse("$baseUrl/checkout/update/$id");
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.put(url, headers: headers);
    if (res.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      Get.back();
      return true;
    } else {
      setState(() {
        isLoading = false;
      });
      print(res.statusCode);
      print(res.body);
      return false;
    }
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
                  height: width / 10,
                ),
                _infoItem(width),
                SizedBox(
                  height: width / 10,
                ),
                Text(
                  "Alamat pengiriman",
                  style:
                      TextStyle(fontFamily: "popinsemi", fontSize: width / 20),
                ),
                SizedBox(
                  height: width / 25,
                ),
                _lokasi(width),
                SizedBox(
                  height: width / 10,
                ),
                Text(
                  "Info pembayaran",
                  style:
                      TextStyle(fontFamily: "popinsemi", fontSize: width / 20),
                ),
                SizedBox(
                  height: width / 25,
                ),
                _paymentInfo(width, "Harga barang",
                    CurrencyFormat.convertToIdr(widget.data.harga, 0)),
                SizedBox(
                  height: width / 50,
                ),
                _paymentInfo(width, "Total barang",
                    widget.data.totalBarang.toString()),
                SizedBox(
                  height: width / 50,
                ),
                _paymentInfo(
                    width,
                    "Total Harga",
                    CurrencyFormat.convertToIdr(
                        widget.data.totalHarga, 0)),
                SizedBox(
                  height: width / 50,
                ),
                SizedBox(
                  height: width / 4,
                ),
                Container(
                  width: width,
                  child: ElevatedButton(
                      onPressed: () {
                        barangSampai(widget.data.id);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: blueTheme,
                          padding: EdgeInsets.symmetric(vertical: width / 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width / 50))),
                      child: !isLoading
                          ? Text(
                              "Barang sudah sampai",
                              style: TextStyle(
                                  fontSize: width / 20,
                                  fontFamily: "popinsemi"),
                            )
                          : CircularProgressIndicator(
                              color: Colors.white,
                            )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentInfo(width, type, price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          type,
          style: TextStyle(fontSize: width / 30, color: grayText),
        ),
        Text(
          price,
          style: TextStyle(fontSize: width / 30, color: grayText),
        )
      ],
    );
  }

  Widget _lokasi(width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: width / 8.5,
              height: width / 8.5,
              decoration: BoxDecoration(
                  color: Color(0xffDFE3EC),
                  borderRadius: BorderRadius.circular(width / 40)),
              child: Icon(
                Iconsax.location,
                size: width / 15,
                color: blueTheme,
              ),
            ),
            SizedBox(
              width: width / 30,
            ),
            Text(
              widget.data.alamat,
              style: TextStyle(fontSize: width / 27, fontFamily: "popinsemi"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoItem(width) {
    return Row(
      children: [
        Container(
          width: width / 4,
          height: width / 4,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width / 30),
              image: DecorationImage(
                  image: NetworkImage(widget.data.fotoBarang),
                  fit: BoxFit.cover)),
        ),
        SizedBox(
          width: width / 30,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.namaBarang,
                style: TextStyle(fontSize: width / 23, fontFamily: "popinsemi"),
              ),
              // Text(
              //   CurrencyFormat.convertToIdr(widget.data.harga, 0),
              //   style: TextStyle(color: grayText, fontSize: width / 35),
              // ),
            ],
          ),
        )
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
          "Checkout",
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
