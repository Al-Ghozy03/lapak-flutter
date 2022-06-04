// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unused_local_variable, avoid_unnecessary_containers, sized_box_for_whitespace, unnecessary_new

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/chat/list_chat.dart';
import 'package:lapak/models/rekomendasi_model.dart';
import 'package:lapak/pages/auth/login.dart';
import 'package:lapak/pages/detail.dart';
import 'package:lapak/pages/diskon.dart';
import 'package:lapak/pages/kategori.dart';
import 'package:lapak/pages/keranjang.dart';
import 'package:lapak/pages/notification/notifikasi.dart';
import 'package:lapak/pages/pesanan.dart';
import 'package:lapak/pages/account/profile.dart';
import 'package:lapak/pages/search.dart';
import 'package:lapak/pages/store/empty_store.dart';
import 'package:lapak/pages/store/toko.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> kategori = [
    "Elektronik",
    "Makanan",
    "Fashion",
    "Aksesoris",
    "Buku"
  ];
  late Future getRekomendasi;
  late Rekomendasi rekomendasi;
  late Future getProfile;
  @override
  void initState() {
    getRekomendasi = ApiService().getRekomendasi();
    getProfile = ApiService().getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    bool hasStore = false;
    GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

    Widget _rekomendasiBuilder() {
      return Container(
        height: width / 1.3,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FutureBuilder(
              future: getRekomendasi,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container(
                    width: width,
                    height: width / 2,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          return _emptyState(height, width);
                        },
                        separatorBuilder: (_, __) {
                          return SizedBox(
                            width: width / 18,
                          );
                        },
                        itemCount: 5),
                  );
                } else if (snapshot.hasError) {
                  return Text("error");
                } else {
                  if (snapshot.hasData) {
                    return Container(
                      width: width,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, i) {
                            return _card(width, snapshot.data, i);
                          },
                          separatorBuilder: (context, i) {
                            return SizedBox(
                              width: width / 18,
                            );
                          },
                          itemCount: snapshot.data.data.length),
                    );
                  } else {
                    return Text("kosong");
                  }
                }
              },
            )),
      );
    }

    Widget _drawer() {
      return SafeArea(
        child: FutureBuilder(
          future: getProfile,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return CircleAvatar(
                backgroundColor: Colors.grey,
              );
            } else if (snapshot.hasError) {
              return Text("Error");
            } else {
              if (snapshot.hasData) {
                return ListView(
                  padding: EdgeInsets.all(width / 25),
                  children: [
                    Container(
                      child: InkWell(
                        onTap: () {
                          Get.to(ProfilePage(),
                              transition: Transition.rightToLeft);
                        },
                        child: Row(
                          children: [
                            snapshot.data.data.photoProfile != null
                                ? CircleAvatar(
                                    maxRadius: width / 13,
                                    minRadius: width / 13,
                                    backgroundImage: NetworkImage(
                                        snapshot.data.data.photoProfile),
                                  )
                                : CircleAvatar(
                                    minRadius: width / 13,
                                    maxRadius: width / 13,
                                    backgroundColor:
                                        Color.fromARGB(255, 196, 196, 196),
                                  ),
                            SizedBox(
                              width: width / 25,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data.data.name.length >= 22
                                      ? "${snapshot.data.data.name.substring(0, 20)}..."
                                      : snapshot.data.data.name,
                                  style: TextStyle(
                                      fontFamily: "popinsemi",
                                      fontSize: width / 25),
                                ),
                                Text(
                                  snapshot.data.data.email.length >= 29
                                      ? "${snapshot.data.data.email.substring(0, 30)}"
                                      : snapshot.data.data.email,
                                  style: TextStyle(
                                    fontSize: width / 35,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: width / 20,
                    ),
                    Divider(),
                    SizedBox(
                      height: width / 20,
                    ),
                    _choice(
                        width,
                        Iconsax.shop,
                        "Toko kamu",
                        snapshot.data.data.storeId == null
                            ? EmptyStore()
                            : Toko(
                                storeId: snapshot.data.data?.storeId,
                              ),
                        context),
                    SizedBox(
                      height: width / 40,
                    ),
                    _choice(width, Iconsax.shopping_bag, "Keranjang",
                        Keranjang(), context),
                    SizedBox(
                      height: width / 40,
                    ),
                    _choice(width, Iconsax.bag_timer, "Pesanan", PesananPage(),
                        context),
                    SizedBox(
                      height: height / 40,
                    ),
                    InkWell(
                      onTap: () async {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.remove("token");
                        preferences.remove("info");
                        Get.off(Login(), transition: Transition.rightToLeft);
                      },
                      child: Row(
                        children: [
                          Icon(Iconsax.logout, size: width / 16),
                          SizedBox(
                            width: width / 25,
                          ),
                          Text(
                            "Logout",
                            style: TextStyle(
                                fontFamily: "PopinMedium",
                                fontSize: width / 34),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              } else {
                return Text("kosong");
              }
            }
          },
        ),
      );
    }

    Widget _header() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                scaffoldState.currentState?.openDrawer();
              },
              icon: Icon(Iconsax.menu_1)),
          Container(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: blueTheme,
                      borderRadius: BorderRadius.circular(13)),
                  child: IconButton(
                    onPressed: () => Get.to(SearchPage(),
                        transition: Transition.rightToLeft),
                    icon: Icon(
                      Iconsax.search_normal_1,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Get.to(Notifikasi(), transition: Transition.rightToLeft);
                    },
                    icon: Icon(
                      Iconsax.notification,
                      size: width / 20,
                    )),
                IconButton(
                    onPressed: () {
                      Get.to(ListChatPage(),
                          transition: Transition.rightToLeft);
                    },
                    icon: Icon(
                      Iconsax.message,
                      size: width / 20,
                    ))
              ],
            ),
          )
        ],
      );
    }

    return Scaffold(
      key: scaffoldState,
      drawer: Drawer(
        width: width / 1.2,
        child: _drawer(),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width / 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              SizedBox(
                height: width / 10,
              ),
              _discount(width),
              SizedBox(
                height: width / 20,
              ),
              Container(
                height: width / 15,
                width: width,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: kategori
                      .map((e) => _kategori(width, e, context))
                      .toList(),
                ),
              ),
              SizedBox(
                height: width / 20,
              ),
              Text(
                "Rekomendasi untuk mu",
                style: TextStyle(fontSize: width / 18, fontFamily: "popinsemi"),
              ),
              SizedBox(
                height: width / 20,
              ),
              Container(
                height: width / 1.4,
                child: _rekomendasiBuilder(),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _card(width, Rekomendasi data, int i) {
    if (data.data.isNotEmpty) {
      return OpenContainer(
        openBuilder: (context, action) {
          return Detail(
            data: data.data[i],
          );
        },
        closedBuilder: (context, action) {
          return Container(
              width: width / 2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width / 25),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
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
                                image: NetworkImage(data.data[i].fotoBarang),
                                fit: BoxFit.cover)),
                      ),
                      Positioned(
                        top: width / 50,
                        left: width / 2.6,
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
                        CircleAvatar(
                          backgroundImage: NetworkImage(data.data[0].fotoToko),
                        ),
                        SizedBox(
                          width: width / 40,
                        ),
                        Text(
                          data.data[i].namaToko.length >= 15
                              ? "${data.data[i].namaToko.substring(0, 14)}..."
                              : data.data[i].namaToko,
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
                          data.data[i].namaBarang.length >= 28
                              ? "${data.data[i].namaBarang.substring(0, 27)}..."
                              : data.data[i].namaBarang,
                          style: TextStyle(
                              fontSize: width / 23, fontFamily: "popinsemi"),
                        ),
                        Row(
                          children: [
                            Text(
                              "${CurrencyFormat.convertToIdr(data.data[i].harga, 0)} . ${data.data[i].daerah}",
                              style: TextStyle(
                                  fontSize: width / 35, color: grayText),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ));
        },
      );
    } else {
      return Center(
        child: Text("kosong"),
      );
    }
  }

  Widget _kategori(width, data, context) {
    return Row(
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.white,
                side: BorderSide(width: 2, color: Color(0xff898989)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width)),
                padding: EdgeInsets.symmetric(horizontal: width / 27)),
            onPressed: () {
              Get.to(
                  KategoriPage(
                    kategori: data,
                  ),
                  transition: Transition.rightToLeft);
            },
            child: Text(
              data,
              style: TextStyle(fontSize: width / 28, color: Color(0xff898989)),
            )),
        SizedBox(
          width: width / 30,
        )
      ],
    );
  }

  Widget _discount(width) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: width / 20, vertical: width / 25),
      width: width,
      height: width / 2.3,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width / 20),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff46BCFF), Color(0xff008BD9)])),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Get Discount \n30%",
                style: TextStyle(
                    fontSize: width / 15,
                    fontFamily: "popinsemi",
                    color: Colors.white),
              ),
              SizedBox(
                height: width / 55,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular((10))),
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 30, vertical: width / 80)),
                  onPressed: () =>
                      Get.to(Diskon(), transition: Transition.rightToLeft),
                  child: Text("Get now",
                      style: TextStyle(
                          color: blueTheme,
                          fontFamily: "popinsemi",
                          fontSize: width / 30)))
            ],
          ),
          Image.asset(
            "assets/discount.png",
            height: width / 3.5,
          )
        ],
      ),
    );
  }

  Widget _choice(width, icon, text, route, BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(route, transition: Transition.rightToLeft);
      },
      child: Row(
        children: [
          Icon(icon, size: width / 16),
          SizedBox(
            width: width / 25,
          ),
          Text(
            text,
            style: TextStyle(fontFamily: "PopinMedium", fontSize: width / 34),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(height, width) {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: width / 40, vertical: width / 40),
      height: height / 3,
      width: width / 2,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(width / 20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 10,
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 3),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height / 5,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      width / 20,
                    ),
                    topRight: Radius.circular(width / 20))),
          ),
          SizedBox(
            height: width / 30,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width / 30),
            height: height / 50,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(width)),
          )
        ],
      ),
    );
  }
}
