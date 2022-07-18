// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures, avoid_print

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/models/cart_model.dart';
import 'package:lapak/pages/detail.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:lapak/widget/skeleton.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Keranjang extends StatefulWidget {
  const Keranjang({Key? key}) : super(key: key);

  @override
  State<Keranjang> createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  late Cart cart;
  late Future getCart;
  bool isDelete = false;

  Future deleteFromCart(id) async {
    Uri url = Uri.parse("$baseUrl/cart/delete/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.delete(url, headers: headers);
    if (res.statusCode == 200) {
    } else {
      print(res.statusCode);
      print(res.body);
    }
  }

  @override
  void initState() {
    getCart = ApiService().getCart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width / 25),
          child: Column(
            children: [
              _header(width),
              SizedBox(
                height: width / 15,
              ),
              FutureBuilder(
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return StaggeredGrid.count(
                      mainAxisSpacing: 2,
                      crossAxisCount: 2,
                      children: [
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return StaggeredGrid.count(
                      mainAxisSpacing: 2,
                      crossAxisCount: 2,
                      children: [
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                      ],
                    );
                  } else {
                    if (snapshot.hasData) {
                      return _card(width, snapshot.data);
                    } else {
                      return StaggeredGrid.count(
                        mainAxisSpacing: 2,
                        crossAxisCount: 2,
                        children: [
                          Skeleton(),
                          Skeleton(),
                          Skeleton(),
                          Skeleton(),
                        ],
                      );
                    }
                  }
                },
                future: getCart,
              )
            ],
          ),
        ),
      )),
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
          "Keranjang",
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

  Widget _card(width, Cart cart) {
    if (cart.data.isEmpty)
      return Column(
        children: [
          LottieBuilder.asset("assets/json/85220-cart.json"),
          Text("Tidak ada barang di keranjang",
              style: TextStyle(
                  fontSize: width / 18,
                  color: grayText,
                  fontFamily: "popinsemi"),
              textAlign: TextAlign.center)
        ],
      );
    return StaggeredGrid.count(
      mainAxisSpacing: 2,
      crossAxisCount: 2,
      children: cart.data.map((data) {
        return OpenContainer(
            openElevation: 0,
            closedElevation: 0,
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
                                    image: NetworkImage(data.fotoBarang),
                                    fit: BoxFit.cover)),
                          ),
                          Positioned(
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
                                  deleteFromCart(data.id).then((value) {
                                    setState(() {
                                      getCart = ApiService().getCart();
                                    });
                                  });
                                },
                                icon: Icon(
                                  Iconsax.trash,
                                  color: Colors.white,
                                  size: width / 25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 30, vertical: width / 50),
                        child: Row(
                          children: [
                            CircleAvatar(
                              maxRadius: width / 25,
                              minRadius: width / 25,
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
                                  fontFamily: "popinsemi",
                                  fontSize: width / 30),
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
                                  data.namaBarang,
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
                                    data.diskon == null || data.diskon == 0
                                        ? data.harga
                                        : (0.5 * data.harga) - data.diskon,
                                    0),
                                style: TextStyle(
                                    fontSize: width / 35, color: grayText),
                              ),
                              data.diskon == null || data.diskon == 0
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
                                                  BorderRadius.circular(
                                                      width / 90),
                                              color:
                                                  Colors.blue.withOpacity(0.7)),
                                          child: Text(
                                            "${data.diskon}%",
                                            style: TextStyle(
                                                fontSize: width / 35,
                                                color: Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: width / 40),
                                        Text(
                                          CurrencyFormat.convertToIdr(
                                              data.harga, 0),
                                          style: TextStyle(
                                              fontSize: width / 35,
                                              color:
                                                  Colors.grey.withOpacity(0.6),
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        ),
                                      ],
                                    ),
                              Text(
                                data.daerah,
                                style: TextStyle(
                                    fontSize: width / 35, color: grayText),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ));
            },
            openBuilder: (context, action) =>
                Detail(data: data, where: "cart"));
      }).toList(),
    );
  }
}
