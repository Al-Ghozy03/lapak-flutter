// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, use_key_in_widget_constructors, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/models/detail_model.dart';
import 'package:lapak/models/kategori_model.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/custom_card.dart';
import 'package:lapak/widget/skeleton.dart';
import 'package:material_dialogs/material_dialogs.dart';

class KategoriPage extends StatefulWidget {
  String kategori;
  KategoriPage({required this.kategori});
  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  late Kategori kategori;
  late Future getKategori;

  FutureOr changeFilter(dynamic value) async {
    getKategori = ApiService().getKategori(widget.kategori, value);
  }

  @override
  void initState() {
    getKategori = ApiService().getKategori(widget.kategori, "asc");
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(width),
              SizedBox(
                height: width / 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.kategori,
                    style: TextStyle(
                        fontFamily: "popinsemi", fontSize: width / 20),
                  ),
                ],
              ),
              SizedBox(
                height: width / 15,
              ),
              FutureBuilder(
                future: getKategori,
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
                      if (snapshot.data.data.length == 0) {
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
                      }
                      return _card(width, snapshot.data);
                    } else {
                      return Text("kosong");
                    }
                  }
                },
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _card(width, Kategori kategori) {
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      children: kategori.data.map((data) {
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
        return CustomCard(data: value, where: "kategori");
      }).toList(),
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
          "Kategori",
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
