// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, use_key_in_widget_constructors

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/kategori_model.dart';
import 'package:lapak/pages/detail.dart';
import 'package:lapak/widget/custom_card.dart';
import 'package:lapak/widget/skeleton.dart';

class KategoriPage extends StatefulWidget {
  String kategori;
  KategoriPage({required this.kategori});
  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  String? selectedValue;
  List<String> dropDownChoice = ["Harga tertinggi", "Harga terendah"];
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
                  DropdownButton(
                    hint: Text("Select by"),
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                      if(selectedValue == "Harga terendah"){
                        changeFilter("asc");
                      }else{
                        changeFilter("desc");
                      }
                    },
                    items: dropDownChoice.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                  )
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
                        Skeleton(
                        )
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("terjadi kesalahan");
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data.data.length == 0) {
                        return Center(
                          child: Text(
                            "Kosong",
                            style: TextStyle(fontSize: width / 20),
                          ),
                        );
                      }
                      return _card(width, snapshot.data);
                    } else {
                      return Text("kosong");
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

  Widget _card(width, Kategori kategori) {
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      children: kategori.data.map((data) {
        return OpenContainer(
          openBuilder: (context, action) {
            return Detail(
              data: data,
            );
          },
          closedBuilder: (context, action) {
            return CustomCard(data: data,where: "");
          },
        );
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
