// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, must_be_immutable, use_key_in_widget_constructors, library_prefixes, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/chat/chat.dart';
import 'package:lapak/models/detail_model.dart';
import 'package:lapak/models/store_model.dart';
import 'package:lapak/pages/detail.dart';
import 'package:lapak/pages/store/create_barang.dart';
import 'package:lapak/pages/store/edit_barang.dart';
import 'package:lapak/pages/store/edit_toko.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/error.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:lapak/widget/skeleton.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as Io;

class Toko extends StatefulWidget {
  int storeId;
  Toko({required this.storeId});
  @override
  State<Toko> createState() => _TokoState();
}

class _TokoState extends State<Toko> {
  String? selectedValue;
  CustomPopupMenuController controller = CustomPopupMenuController();
  late Future getStore;
  Io.Socket socket = Io.io(baseUrl, <String, dynamic>{
    "transports": ["websocket"],
  });
  bool isLoading = false;

  Future deleteBarang(int id) async {
    setState(() {
      isLoading = true;
    });
    Uri url = Uri.parse("$baseUrl/barang/delete/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.delete(url, headers: headers);
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
      print("gagal");
      Get.snackbar(
        "Gagal",
        "terjadi kesalahan, silahkan coba lagi",
        snackPosition: SnackPosition.BOTTOM,
        leftBarIndicatorColor: Colors.red,
      );
    }
  }

  int userId = 0;
  void getUserId() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    var token = storage.getString("token");
    setState(() {
      userId = Jwt.parseJwt(token.toString())["id"];
    });
  }

  String orderBy = "";

  Future generateCode(int to) async {
    Uri url = Uri.parse("$baseUrl/chat/generate-code/$to");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      if (jsonDecode(res.body)["code"]["room_code"] != null) {
        socket.emit("join_room", {
          "room_code": jsonDecode(res.body)["code"]["room_code"],
          "from": userId
        });
        Get.to(
            ChatPage(
                to: to, roomCode: jsonDecode(res.body)["code"]["room_code"]),
            transition: Transition.rightToLeft);
      } else {
        socket.emit("join_room", {
          "room_code": jsonDecode(res.body)["code"]["code"],
          "from": userId
        });
        Get.to(ChatPage(to: to, roomCode: jsonDecode(res.body)["code"]["code"]),
            transition: Transition.rightToLeft);
      }
    } else {
      print(res.statusCode);
      print(res.body);
    }
  }

  @override
  void initState() {
    getUserId();
    getStore = ApiService().getStoreInfo(widget.storeId, orderBy);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
              store.data.owner != userId
                  ? Text("")
                  : PopupMenuButton(
                      onSelected: (value) {
                        if (value == 1) {
                          Get.to(CreateBarang(id: store.data.id),
                                  transition: Transition.rightToLeft)
                              ?.then((value) {
                            setState(() {
                              getStore = ApiService()
                                  .getStoreInfo(widget.storeId, orderBy);
                            });
                          });
                        }
                        if (value == 2) {
                          Get.to(
                                  EditToko(
                                    data: store.data,
                                  ),
                                  transition: Transition.rightToLeft)
                              ?.then((value) {
                            setState(() {
                              getStore = ApiService()
                                  .getStoreInfo(widget.storeId, orderBy);
                            });
                          });
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 1, child: Text("Buat barang")),
                        PopupMenuItem(value: 2, child: Text("Edit toko")),
                      ],
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                          userId == store.data.owner
                              ? Container()
                              : IconButton(
                                  onPressed: () =>
                                      generateCode(store.data.owner),
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
                                        "daerah": store.data.daerah
                                      }))
                                  .toList(),
                            )
                          : Center(
                              child: LottieBuilder.asset(
                                  "assets/json/93134-not-found.json"),
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

    return Scaffold(
      body: FutureBuilder(
        future: getStore,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _loadingState(width, height);
          } else if (snapshot.hasError) {
            return Error();
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
    var value = DetailModel(
        id: data.id,
        storeId: data.storeId,
        owner: info["owner"],
        namaToko: info["nama_toko"],
        fotoToko: info["foto_toko"],
        namaBarang: data.namaBarang,
        harga: data.harga,
        deskripsi: data.deskripsi,
        kategori: data.kategori,
        fotoBarang: data.fotoBarang,
        daerah: info["daerah"],
        diskon: data.diskon);
    return OpenContainer(
      openElevation: 0,
      closedElevation: 0,
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
                    info["owner"] != userId
                        ? Text("")
                        : Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: width / 10,
                              width: width / 10,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(width)),
                              child: PopupMenuButton(
                                onSelected: (val) {
                                  if (val == 1) {
                                    Get.to(
                                            UpdateBarang(
                                              data: value,
                                            ),
                                            transition: Transition.rightToLeft)
                                        ?.then((value) {
                                      setState(() {
                                        getStore = ApiService().getStoreInfo(
                                            widget.storeId, orderBy);
                                      });
                                    });
                                  } else {
                                    _dialogDelete(context, width, data.id);
                                  }
                                },
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: width / 20,
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                      value: 1,
                                      child: Text(
                                        "Edit barang",
                                        style: TextStyle(fontSize: width / 30),
                                      )),
                                  PopupMenuItem(
                                      value: 2,
                                      child: Text(
                                        "Delete barang",
                                        style: TextStyle(fontSize: width / 30),
                                      )),
                                ],
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
                        data.namaBarang,
                        style: TextStyle(
                            fontSize: width / 23, fontFamily: "popinsemi"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        CurrencyFormat.convertToIdr(data.harga, 0),
                        style: TextStyle(fontSize: width / 35, color: grayText),
                      ),
                      Text(
                        info["daerah"],
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

  Future<void> _dialogDelete(BuildContext context, width, int id) {
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
              onPressed: () {
                deleteBarang(id).then((value) {
                  setState(() {
                    getStore =
                        ApiService().getStoreInfo(widget.storeId, orderBy);
                  });
                });
              },
              child: Text(
                "Hapus",
                style: TextStyle(fontSize: width / 25, color: Colors.white),
              )),
        ]);
  }

  Widget _loadingState(width, height) {
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
            Icon(Icons.more_vert),
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
                backgroundColor: grayBorder,
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
                        FadeShimmer(
                          width: width / 1.5,
                          height: height / 50,
                          radius: width,
                          baseColor: Colors.grey.withOpacity(0.3),
                          highlightColor: Colors.grey.withOpacity(0.5),
                        ),
                        SizedBox(
                          height: width / 40,
                        ),
                        FadeShimmer(
                          width: width / 2,
                          height: height / 60,
                          radius: width,
                          baseColor: Colors.grey.withOpacity(0.3),
                          highlightColor: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                    )),
                    SizedBox(
                      height: width / 20,
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.withOpacity(0.5),
                        ),
                        Text(
                          "Produk",
                          style:
                              TextStyle(fontSize: width / 40, color: grayText),
                        ),
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
