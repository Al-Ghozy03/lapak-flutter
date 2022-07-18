// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, curly_braces_in_flow_control_structures

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/models/detail_model.dart';
import 'package:lapak/models/pesanan_model.dart';
import 'package:lapak/pages/checkout/after_checkout.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:lapak/widget/skeleton.dart';
import 'package:material_dialogs/material_dialogs.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width / 25),
            child: Column(
              children: [
                _header(width),
                SizedBox(height: width / 20),
                FutureBuilder(
                  future: getPesanan,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
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
                        return _builder(snapshot.data, width);
                      } else {
                        return Text("kosong");
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _builder(PesananModel pesanan, width) {
    if (pesanan.data.isEmpty) {
      return Column(
        children: [
          LottieBuilder.asset("assets/json/lf20_ioskgmiv.json"),
          Text("Tidak ada barang di pesanan",
              style: TextStyle(
                  fontSize: width / 18,
                  color: grayText,
                  fontFamily: "popinsemi"),
              textAlign: TextAlign.center)
        ],
      );
    } else {
      return StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        children: pesanan.data.map((data) {
          var value = DetailModel(
              id: data.item.orderBarang.id,
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
              diskon: data.item.diskon,
              totalBarang: data.item.orderBarang.totalBarang,
              totalHarga: int.parse(data.item.orderBarang.totalHarga),
              alamat: data.item.orderBarang.alamat);
          return InkWell(
            onTap: () => Get.to(AfterCheckout(data: value),
                    transition: Transition.rightToLeft)
                ?.then((value) {
              setState(() {
                getPesanan = ApiService().getPesanan();
              });
            }),
            child: Container(
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
                                  image: NetworkImage(value.fotoBarang),
                                  fit: BoxFit.cover)),
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
                            backgroundImage: NetworkImage(value.fotoToko),
                          ),
                          SizedBox(
                            width: width / 40,
                          ),
                          Text(
                            value.namaToko.length >= 8
                                ? "${value.namaToko.substring(0, 7)}..."
                                : value.namaToko,
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
                                value.namaBarang,
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
                                  value.diskon == 0
                                      ? value.harga
                                      : (0.5 * value.harga) - value.diskon,
                                  0),
                              style: TextStyle(
                                  fontSize: width / 35, color: grayText),
                            ),
                            value.diskon == 0
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
                                            borderRadius: BorderRadius.circular(
                                                width / 90),
                                            color:
                                                Colors.blue.withOpacity(0.7)),
                                        child: Text(
                                          "${value.diskon}%",
                                          style: TextStyle(
                                              fontSize: width / 35,
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: width / 40),
                                      Text(
                                        CurrencyFormat.convertToIdr(
                                            value.harga, 0),
                                        style: TextStyle(
                                            fontSize: width / 35,
                                            color: Colors.grey.withOpacity(0.6),
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                    ],
                                  ),
                            Text(
                              value.daerah,
                              style: TextStyle(
                                  fontSize: width / 35, color: grayText),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
          );
        }).toList(),
      );
    }
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
