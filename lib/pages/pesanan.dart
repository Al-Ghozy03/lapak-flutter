// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/pesanan_model.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/custom_card.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({Key? key}) : super(key: key);

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  late Future getPesanan;
  @override
  void initState() {
    getPesanan = ApiService().getPesanan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder(
        future: getPesanan,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Text("loading");
          } else if (snapshot.hasError) {
            return Text("terjadi kesalahan");
          } else {
            if (snapshot.hasData) {
              return SafeArea(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(width / 25),
                  child: Column(
                    children: [
                      _header(width),
                      SizedBox(
                        height: width / 15,
                      ),
                      _builder(snapshot.data, width)
                    ],
                  ),
                ),
              ));
            } else {
              return Text("kosong");
            }
          }
        },
      ),
    );
  }

  Widget _builder(Pesanan pesanan, width) {
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      children: pesanan.data
          .map((data) => CustomCard(data: data, where: "pesanan",))
          .toList(),
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
          "Pesanan",
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

  Widget _card(width) {
    return OpenContainer(
      openBuilder: (context, action) {
        return Container();
      },
      closedBuilder: (context, action) {
        return Container(
            margin: EdgeInsets.all(10),
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
                              image: NetworkImage(
                                  "https://www.yangcanggih.com/wp-content/uploads/2022/01/ASUS-ROG-Zephyrus-Duo-16-4.webp"),
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
                          onPressed: () {},
                          icon: Icon(
                            Iconsax.shop_add,
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
                      CircleAvatar(),
                      SizedBox(
                        width: width / 40,
                      ),
                      Text(
                        "Toko haram",
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
                        "ROG Zephyrus",
                        style: TextStyle(
                            fontSize: width / 23, fontFamily: "popinsemi"),
                      ),
                      Text(
                        "Rp 15.000",
                        style: TextStyle(fontSize: width / 35, color: grayText),
                      ),
                      Text(
                        "Cibitung, Bekasi",
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
