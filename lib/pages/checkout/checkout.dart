// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/info_model.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as Io;

class Checkout extends StatefulWidget {
  final data;
  Checkout({this.data});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  int total = 1;
  Info _info = Info(name: "", alamat: "");
  bool isLoading = false;

  void getInfo() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    Map<String, dynamic> info = {};
    String infoStr = storage.getString("info").toString();

    setState(() {
      info = jsonDecode(infoStr) as Map<String, dynamic>;
      _info = Info.fromJson(info);
    });
  }

  TextEditingController alamat = TextEditingController();
  Future checkout(int totalBarang, int totalHarga, String alamat) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    Uri url = Uri.parse("$baseUrl/checkout/order");
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.post(url,
        body: jsonEncode({
          "total_barang": totalBarang,
          "total_harga": totalHarga,
          "barang_id": widget.data.id,
          "owner_barang": widget.data.owner,
          "alamat": alamat
        }),
        headers: headers);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body)["data"];
      socket.emit("send_notif", {
        "from": data["user_id"],
        "message": "memesan ${widget.data.namaBarang}",
        "to": widget.data.owner,
      });
      setState(() {
        isLoading = false;
      });
      print(res.statusCode);
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

  void changeAddress() async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          final width = MediaQuery.of(context).size.width;
          return Padding(
            padding: EdgeInsets.all(width / 20),
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Ganti alamat pengiriman",
                    style: TextStyle(
                        fontSize: width / 20, fontFamily: "popinsemi"),
                  ),
                ),
                SizedBox(
                  height: width / 30,
                ),
                TextField(
                  controller: alamat,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Iconsax.location,
                        size: width / 15,
                      ),
                      hintText: "Alamat",
                      hintStyle: TextStyle(
                          fontSize: width / 30, fontFamily: "popinmedium"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(width / 40)),
                      filled: true,
                      fillColor: Color.fromARGB(255, 237, 237, 237)),
                ),
                SizedBox(
                  height: width / 20,
                ),
                Container(
                  width: width,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          primary: blueTheme,
                          padding: EdgeInsets.symmetric(vertical: width / 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width / 50))),
                      child: Text(
                        "Simpan",
                        style: TextStyle(
                            fontSize: width / 20, fontFamily: "popinsemi"),
                      )),
                )
              ],
            ),
          );
        });
  }

  Io.Socket socket = Io.io(baseUrl, <String, dynamic>{
    "transports": ["websocket"],
  });

  void connectSocket() {
    socket.onConnect((data) => print("connect ${socket.id}"));
    socket.onDisconnect((data) => print("disconnect"));
    socket.onConnectError((data) => print("error $data"));
  }

  @override
  void initState() {
    getInfo();
    super.initState();
    connectSocket();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Widget _lokasi(width) {
      return InkWell(
        onTap: () => changeAddress(),
        child: Row(
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
                  alamat.text == "" ? _info.alamat : alamat.text,
                  style:
                      TextStyle(fontSize: width / 27, fontFamily: "popinsemi"),
                ),
              ],
            ),
            Icon(Iconsax.arrow_right_3)
          ],
        ),
      );
    }

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
                _paymentInfo(width, "Total barang", total.toString()),
                SizedBox(
                  height: width / 50,
                ),
                _paymentInfo(width, "Total Harga",
                    CurrencyFormat.convertToIdr(widget.data.harga * total, 0)),
                SizedBox(
                  height: width / 4,
                ),
                Container(
                  width: width,
                  child: ElevatedButton(
                      onPressed: () {
                        checkout(total, widget.data.harga * total,
                            alamat.text != "" ? alamat.text : _info.alamat);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: blueTheme,
                          padding: EdgeInsets.symmetric(vertical: width / 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width / 50))),
                      child: !isLoading
                          ? Text(
                              "Pesan",
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
              Text(
                CurrencyFormat.convertToIdr(widget.data.harga, 0),
                style: TextStyle(color: grayText, fontSize: width / 35),
              ),
              Container(
                width: width / 2.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            if (total == 1) {
                              return;
                            } else {
                              total--;
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(shape: CircleBorder()),
                        child: Text(
                          "-",
                          style: TextStyle(color: grayText),
                        )),
                    Text(
                      total.toString(),
                      style: TextStyle(fontSize: width / 35),
                    ),
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            total++;
                          });
                        },
                        style: OutlinedButton.styleFrom(shape: CircleBorder()),
                        child: Text(
                          "+",
                          style: TextStyle(color: grayText),
                        )),
                  ],
                ),
              )
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
