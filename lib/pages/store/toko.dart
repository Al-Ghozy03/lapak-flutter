// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, must_be_immutable, use_key_in_widget_constructors

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/chat/chat.dart';
import 'package:lapak/models/model_store.dart';
import 'package:lapak/models/store_model.dart';
import 'package:lapak/pages/detail.dart';
import 'package:lapak/pages/store/create_barang.dart';
import 'package:lapak/pages/store/edit_barang.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/custom_route.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:lapak/widget/skeleton.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Toko extends StatefulWidget {
  int storeId;
  Toko({required this.storeId});
  @override
  State<Toko> createState() => _TokoState();
}

class _TokoState extends State<Toko> {
  String? selectedValue;
  CustomPopupMenuController controller = CustomPopupMenuController();
  late Stream getStore;
  @override
  void initState() {
    getStore = Stream.periodic(Duration(seconds: 3))
        .asyncMap((event) => ApiService().getStoreInfo(widget.storeId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Future deleteBarang(int id) async {
      Uri url = Uri.parse("$baseUrl/barang/delete/$id");
      SharedPreferences storage = await SharedPreferences.getInstance();
      headers["Authorization"] = "Bearer ${storage.getString("token")}";
      final res = await http.delete(url, headers: headers);
      if(res.statusCode == 200){
        print("berhasil hapus");
        return true;
      }else{
        print(res.statusCode);
        print("gagal");
      }
    }

    Widget _builder(Store store) {
      return SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Iconsax.arrow_left)),
            actions: [
              CustomPopupMenu(
                menuBuilder: () => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.all(width / 50),
                    color: Colors.white,
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).push(
                                CustomPageRoute(
                                    child: CreateBarang(id: store.data.id))),
                            child: Text(
                              "Buat barang",
                              style: TextStyle(fontSize: width / 40),
                            ),
                          ),
                          SizedBox(height: width / 60),
                          Text(
                            "Laporkan",
                            style: TextStyle(fontSize: width / 40),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                pressType: PressType.singleClick,
                controller: controller,
                barrierColor: Colors.white.withOpacity(0),
                child: Icon(Iconsax.more),
              ),
            ],
            title: Text("Toko"),
            centerTitle: true,
            elevation: 0,
            snap: true,
            backgroundColor: Colors.white,
            floating: true,
            titleTextStyle:
                TextStyle(fontFamily: "popinsemi", fontSize: width / 15),
            expandedHeight: width / 1.3,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                "assets/5559852.jpg",
                fit: BoxFit.cover,
              ),
              title: Container(
                margin: EdgeInsets.only(bottom: width / 10),
                child: CircleAvatar(
                  minRadius: width / 9,
                  maxRadius: width / 9,
                  backgroundImage: NetworkImage(store.data.photoProfile),
                ),
              ),
              centerTitle: true,
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(height / 30),
              child: Container(
                padding: EdgeInsets.only(top: width / 25),
                height: width / 20,
                width: width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(width / 15),
                        topRight: Radius.circular(width / 15)),
                    color: Colors.white),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate.fixed([
            SingleChildScrollView(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(width / 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.data.namaToko,
                            style: TextStyle(
                                fontSize: width / 18, fontFamily: "popinsemi"),
                          ),
                          Text(
                            store.data.daerah,
                            style: TextStyle(
                                color: grayText, fontSize: width / 35),
                          ),
                        ],
                      )),
                      SizedBox(
                        height: width / 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                store.data.barang.length.toString(),
                                style: TextStyle(
                                    fontFamily: "popinsemi",
                                    fontSize: width / 30),
                              ),
                              Text(
                                "Produk",
                                style: TextStyle(
                                    fontSize: width / 40, color: grayText),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () =>
                                Navigator.of(context).push(CustomPageRoute(
                                    child: ChatPage(
                              to: 1,
                              roomCode: "",
                            ))),
                            icon: Icon(Iconsax.message),
                            iconSize: width / 20,
                          )
                        ],
                      ),
                      SizedBox(
                        height: width / 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Produk",
                            style: TextStyle(
                              fontSize: width / 25,
                            ),
                          ),
                          DropdownButton(
                            hint: Text("Urutkan"),
                            value: selectedValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedValue = newValue!;
                              });
                            },
                            items: ["Harga terendah", "Harga tertinggi"]
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: width / 85,
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      SizedBox(
                        height: width / 80,
                      ),
                      store.data.barang.isNotEmpty
                          ? StaggeredGrid.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 2,
                              children: store.data.barang
                                  .map((data) => _card(width, data, {
                                        "nama_toko": store.data.namaToko,
                                        "owner": store.data.owner,
                                        "foto_toko": store.data.photoProfile,
                                      }))
                                  .toList(),
                            )
                          : Center(
                              child: Text(
                              "Belum memiliki produk",
                              style: TextStyle(
                                  fontSize: width / 20, color: grayText),
                            ))
                    ],
                  ),
                ),
              ),
            )
          ]))
        ],
      ));
    }

    return Scaffold(
      body: StreamBuilder(
        stream: getStore,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return _emptyState(width, height);
          } else if (snapshot.hasError) {
            return Text("terjadi kesalahan");
          } else {
            if (snapshot.hasData) {
              return _builder(snapshot.data);
            } else {
              return Text("kosong");
            }
          }
        },
      ),
    );
  }

  Widget _card(width, data, Map info) {
    var value = MoreStore(
        beratBarang: data.beratBarang,
        id: data.id,
        storeId: data.storeId,
        owner: info["owner"],
        namaToko: info["nama_toko"],
        daerah: data.daerah,
        fotoToko: info["foto_toko"],
        namaBarang: data.namaBarang,
        harga: data.harga,
        deskripsi: data.deskripsi,
        kategori: data.kategori,
        fotoBarang: data.fotoBarang,
        diskon: data.diskon);
    return OpenContainer(
      openBuilder: (context, action) {
        return Detail(
          data: value,
        );
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
                              image: NetworkImage(data.fotoBarang),
                              fit: BoxFit.cover)),
                    ),
                    Positioned(
                      top: width / 50,
                      left: width / 3.2,
                      child: CustomPopupMenu(
                          barrierColor: Colors.black.withOpacity(0),
                          menuBuilder: () => ClipRRect(
                                borderRadius: BorderRadius.circular(width / 50),
                                child: Container(
                                  padding: EdgeInsets.all(width / 50),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 245, 245, 245),
                                  ),
                                  child: IntrinsicWidth(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () => Navigator.of(context)
                                              .push(CustomPageRoute(
                                                  child: UpdateBarang(
                                            data: value,
                                          ))),
                                          child: Text(
                                            "Edit",
                                            style:
                                                TextStyle(fontSize: width / 40),
                                          ),
                                        ),
                                        SizedBox(height: width / 60),
                                        InkWell(
                                          onTap: () =>
                                              _dialogDelete(context, width),
                                          child: Text(
                                            "Hapus",
                                            style:
                                                TextStyle(fontSize: width / 40),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          pressType: PressType.singleClick,
                          child: Container(
                            height: width / 12,
                            width: width / 12,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(width),
                                color: Colors.black.withOpacity(0.5)),
                            child: Icon(
                              Iconsax.more4,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width / 30, vertical: width / 50),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(value.fotoToko),
                      ),
                      SizedBox(
                        width: width / 40,
                      ),
                      Text(
                        info["nama_toko"].length >= 12
                            ? "${info["nama_toko"].substring(0, 10)}..."
                            : info["nama_toko"],
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
                        data.namaBarang.length >= 15
                            ? "${data.namaBarang.substring(0, 12)}..."
                            : data.namaBarang,
                        style: TextStyle(
                            fontSize: width / 23, fontFamily: "popinsemi"),
                      ),
                      Text(
                        CurrencyFormat.convertToIdr(data.harga, 0),
                        style: TextStyle(fontSize: width / 35, color: grayText),
                      ),
                      Text(
                        data.daerah,
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

  Future<void> _dialogDelete(BuildContext context, width) {
    return Dialogs.materialDialog(
        context: context,
        msg: "Apakah anda yakin ingin menghapus nya?",
        msgStyle: TextStyle(fontSize: width / 25),
        msgAlign: TextAlign.center,
        title: "Delete",
        titleStyle: TextStyle(fontSize: width / 20, fontFamily: "popinsemi"),
        actions: [
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 1.5, color: grayBorder),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width / 60)),
                  padding: EdgeInsets.symmetric(vertical: width / 80)),
              onPressed: () {
                Get.back();
              },
              child: Text(
                "Batal",
                style: TextStyle(fontSize: width / 25, color: grayText),
              )),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width / 60)),
                  padding: EdgeInsets.symmetric(vertical: width / 80),
                  primary: blueTheme),
              onPressed: () {},
              child: Text(
                "Hapus",
                style: TextStyle(fontSize: width / 25, color: Colors.white),
              )),
        ]);
  }

  Widget _emptyState(width, height) {
    return SafeArea(
        child: CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Iconsax.arrow_left)),
          actions: [
            CustomPopupMenu(
              menuBuilder: () => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(width / 50),
                  color: Colors.white,
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          child: Text(
                            "Buat barang",
                            style: TextStyle(fontSize: width / 40),
                          ),
                        ),
                        SizedBox(height: width / 60),
                        Text(
                          "Laporkan",
                          style: TextStyle(fontSize: width / 40),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              pressType: PressType.singleClick,
              controller: controller,
              barrierColor: Colors.white.withOpacity(0),
              child: Icon(Iconsax.more),
            ),
          ],
          title: Text("Toko"),
          centerTitle: true,
          elevation: 0,
          snap: true,
          backgroundColor: Colors.white,
          floating: true,
          titleTextStyle:
              TextStyle(fontFamily: "popinsemi", fontSize: width / 15),
          expandedHeight: width / 1.3,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              "assets/5559852.jpg",
              fit: BoxFit.cover,
            ),
            title: Container(
              margin: EdgeInsets.only(bottom: width / 10),
              child: CircleAvatar(
                minRadius: width / 9,
                maxRadius: width / 9,
                backgroundColor: Colors.grey,
              ),
            ),
            centerTitle: true,
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(height / 30),
            child: Container(
              padding: EdgeInsets.only(top: width / 25),
              height: width / 20,
              width: width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(width / 15),
                      topRight: Radius.circular(width / 15)),
                  color: Colors.white),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate.fixed([
          SingleChildScrollView(
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(width / 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: width / 40),
                          height: height / 50,
                          width: width / 1.5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width),
                              color: Colors.grey.withOpacity(0.5)),
                        ),
                        Container(
                          height: height / 60,
                          width: width / 2,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width),
                              color: Colors.grey.withOpacity(0.5)),
                        ),
                      ],
                    )),
                    SizedBox(
                      height: width / 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey.withOpacity(0.5),
                            ),
                            Text(
                              "Produk",
                              style: TextStyle(
                                  fontSize: width / 40, color: grayText),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.of(context).push(CustomPageRoute(
                                  child: ChatPage(
                            to: 1,
                            roomCode: "",
                          ))),
                          icon: Icon(Iconsax.message),
                          iconSize: width / 20,
                        )
                      ],
                    ),
                    SizedBox(
                      height: width / 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Produk",
                          style: TextStyle(
                            fontSize: width / 25,
                          ),
                        ),
                        DropdownButton(
                          hint: Text("Urutkan"),
                          value: selectedValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue = newValue!;
                            });
                          },
                          items: ["Harga terendah", "Harga tertinggi"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: width / 85,
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    SizedBox(
                      height: width / 80,
                    ),
                    StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2,
                      children: [
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                        Skeleton(),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ]))
      ],
    ));
  }
}
