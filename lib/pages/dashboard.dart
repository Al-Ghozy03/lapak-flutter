// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unused_local_variable, avoid_unnecessary_containers, sized_box_for_whitespace, unnecessary_new, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:badges/badges.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/service/api_service.dart';
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
import 'package:lapak/pages/search/search.dart';
import 'package:lapak/pages/store/empty_store.dart';
import 'package:lapak/pages/store/toko.dart';
import 'package:lapak/service/notification_service.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/attribute.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> kategori = [
    "elektronik",
    "makanan",
    "fashion",
    "aksesoris",
    "buku"
  ];
  late Future getRekomendasi;
  late Rekomendasi rekomendasi;
  late Future getProfile;
  int userId = 0;
  int lengthNotif = 0;

void newMessage()async{
  SharedPreferences storage = await SharedPreferences.getInstance();
  int id = Jwt.parseJwt(storage.getString("token").toString())["id"];
  socket.on("received_message", (data){
    print(data);
    if(data["to"] == id){
      NotificationService.showNotification(title: "Pesan baru dari ${data["sender"]}");
    }
  });
}


  void getUserId() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    setState(() {
      userId = Jwt.parseJwt(storage.getString("token").toString())["id"];
    });
  }

  Future notifLength() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    Uri url = Uri.parse(
        "$baseUrl/checkout/counter/${Jwt.parseJwt(storage.getString("token").toString())["id"]}");
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      var length = jsonDecode(res.body)["length"];
      setState(() {
        lengthNotif = length;
      });
      return length;
    } else {
      print(res.statusCode);
      return false;
    }
  }

  Future addToCart(id) async {
    Uri url = Uri.parse("$baseUrl/cart/add/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.post(url, headers: headers);
    if (res.statusCode == 200) {
      print("berhasil");
    } else {
      print(res.statusCode);
      print(jsonDecode(res.body));
    }
  }

  @override
  void initState() {
    newMessage();
    getUserId();
    getRekomendasi = ApiService().getRekomendasi();
    getProfile = ApiService().getProfile();
    notifLength();
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
                          return _loadingState(height, width);
                        },
                        separatorBuilder: (_, __) {
                          return SizedBox(
                            width: width / 18,
                          );
                        },
                        itemCount: 5),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    width: width,
                    height: width / 2,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          return _loadingState(height, width);
                        },
                        separatorBuilder: (_, __) {
                          return SizedBox(
                            width: width / 18,
                          );
                        },
                        itemCount: 5),
                  );
                } else {
                  if (snapshot.hasData) {
                    return Container(
                      width: width,
                      child: ListView.separated(
                          physics: BouncingScrollPhysics(),
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
              return Padding(
                padding: EdgeInsets.all(width / 25),
                child: Column(
                  children: [
                    Row(
                      children: [
                        FadeShimmer.round(
                          size: width / 5,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: width / 25),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeShimmer(
                              radius: width,
                              width: width / 2,
                              height: width / 36,
                              baseColor: Colors.grey.withOpacity(0.5),
                              highlightColor: Colors.grey.withOpacity(0.3),
                            ),
                            SizedBox(height: width / 40),
                            FadeShimmer(
                              radius: width,
                              width: width / 3,
                              height: width / 36,
                              baseColor: Colors.grey.withOpacity(0.5),
                              highlightColor: Colors.grey.withOpacity(0.3),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: width / 20),
                    Divider(),
                    SizedBox(height: width / 20),
                    Row(
                      children: [
                        FadeShimmer.round(
                          size: width / 20,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: width / 25),
                        FadeShimmer(
                          radius: width,
                          width: width / 3,
                          height: width / 36,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                      ],
                    ),
                    SizedBox(height: width / 20),
                    Row(
                      children: [
                        FadeShimmer.round(
                          size: width / 20,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: width / 25),
                        FadeShimmer(
                          radius: width,
                          width: width / 3,
                          height: width / 36,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                      ],
                    ),
                    SizedBox(height: width / 20),
                    Row(
                      children: [
                        FadeShimmer.round(
                          size: width / 20,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: width / 25),
                        FadeShimmer(
                          radius: width,
                          width: width / 3,
                          height: width / 36,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                      ],
                    ),
                    SizedBox(height: width / 20),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.all(width / 25),
                child: Column(
                  children: [
                    Row(
                      children: [
                        FadeShimmer.round(
                          size: width / 5,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: width / 25),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeShimmer(
                              radius: width,
                              width: width / 2,
                              height: width / 36,
                              baseColor: Colors.grey.withOpacity(0.5),
                              highlightColor: Colors.grey.withOpacity(0.3),
                            ),
                            SizedBox(height: width / 40),
                            FadeShimmer(
                              radius: width,
                              width: width / 3,
                              height: width / 36,
                              baseColor: Colors.grey.withOpacity(0.5),
                              highlightColor: Colors.grey.withOpacity(0.3),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: width / 20),
                    Divider(),
                    SizedBox(height: width / 20),
                    Row(
                      children: [
                        FadeShimmer.round(
                          size: width / 20,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: width / 25),
                        FadeShimmer(
                          radius: width,
                          width: width / 3,
                          height: width / 36,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                      ],
                    ),
                    SizedBox(height: width / 20),
                    Row(
                      children: [
                        FadeShimmer.round(
                          size: width / 20,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: width / 25),
                        FadeShimmer(
                          radius: width,
                          width: width / 3,
                          height: width / 36,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                      ],
                    ),
                    SizedBox(height: width / 20),
                    Row(
                      children: [
                        FadeShimmer.round(
                          size: width / 20,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: width / 25),
                        FadeShimmer(
                          radius: width,
                          width: width / 3,
                          height: width / 36,
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.grey.withOpacity(0.3),
                        ),
                      ],
                    ),
                    SizedBox(height: width / 20),
                  ],
                ),
              );
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
                                    backgroundColor: grayBorder,
                                    backgroundImage: NetworkImage(
                                        snapshot.data.data.photoProfile),
                                  )
                                : CircleAvatar(
                                    minRadius: width / 13,
                                    maxRadius: width / 13,
                                    backgroundColor: grayBorder,
                                    child: Icon(
                                      Iconsax.user,
                                      color: grayText,
                                      size: width / 15,
                                    ),
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
                    InkWell(
                      onTap: () {
                        Get.to(
                                snapshot.data.data.storeId == null
                                    ? EmptyStore()
                                    : Toko(
                                        storeId: snapshot.data.data?.storeId,
                                      ),
                                transition: Transition.rightToLeft)
                            ?.then((value) {
                          setState(() {
                            getProfile = ApiService().getProfile();
                          });
                        });
                      },
                      child: Row(
                        children: [
                          Icon(Iconsax.shop, size: width / 16),
                          SizedBox(
                            width: width / 25,
                          ),
                          Text(
                            "Toko kamu",
                            style: TextStyle(
                                fontFamily: "PopinMedium",
                                fontSize: width / 34),
                          ),
                        ],
                      ),
                    ),
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
                return Padding(
                  padding: EdgeInsets.all(width / 25),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          FadeShimmer.round(
                            size: width / 5,
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.grey.withOpacity(0.3),
                          ),
                          SizedBox(width: width / 25),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeShimmer(
                                radius: width,
                                width: width / 2,
                                height: width / 36,
                                baseColor: Colors.grey.withOpacity(0.5),
                                highlightColor: Colors.grey.withOpacity(0.3),
                              ),
                              SizedBox(height: width / 40),
                              FadeShimmer(
                                radius: width,
                                width: width / 3,
                                height: width / 36,
                                baseColor: Colors.grey.withOpacity(0.5),
                                highlightColor: Colors.grey.withOpacity(0.3),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: width / 20),
                      Divider(),
                      SizedBox(height: width / 20),
                      Row(
                        children: [
                          FadeShimmer.round(
                            size: width / 20,
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.grey.withOpacity(0.3),
                          ),
                          SizedBox(width: width / 25),
                          FadeShimmer(
                            radius: width,
                            width: width / 3,
                            height: width / 36,
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.grey.withOpacity(0.3),
                          ),
                        ],
                      ),
                      SizedBox(height: width / 20),
                      Row(
                        children: [
                          FadeShimmer.round(
                            size: width / 20,
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.grey.withOpacity(0.3),
                          ),
                          SizedBox(width: width / 25),
                          FadeShimmer(
                            radius: width,
                            width: width / 3,
                            height: width / 36,
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.grey.withOpacity(0.3),
                          ),
                        ],
                      ),
                      SizedBox(height: width / 20),
                      Row(
                        children: [
                          FadeShimmer.round(
                            size: width / 20,
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.grey.withOpacity(0.3),
                          ),
                          SizedBox(width: width / 25),
                          FadeShimmer(
                            radius: width,
                            width: width / 3,
                            height: width / 36,
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.grey.withOpacity(0.3),
                          ),
                        ],
                      ),
                      SizedBox(height: width / 20),
                    ],
                  ),
                );
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
                  width: width / 9,
                  height: width / 9,
                  decoration: BoxDecoration(
                      color: blueTheme,
                      borderRadius: BorderRadius.circular(width / 30)),
                  child: IconButton(
                    onPressed: () => Get.to(SearchPage(),
                        transition: Transition.rightToLeft),
                    icon: Icon(
                      Iconsax.search_normal_1,
                      color: Colors.white,
                      size: width / 20,
                    ),
                  ),
                ),
                Badge(
                  showBadge: lengthNotif == 0 ? false : true,
                  position:
                      BadgePosition.topEnd(top: width / 67, end: width / 60),
                  child: IconButton(
                      onPressed: () {
                        socket.emit("see_notif", userId);
                        Get.to(Notifikasi(),
                            transition: Transition.rightToLeft);
                      },
                      icon: Icon(
                        Iconsax.notification,
                        size: width / 20,
                      )),
                ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            getRekomendasi = ApiService().getRekomendasi();
            getProfile = ApiService().getProfile();
          }); 
          notifLength();
        },
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            SafeArea(
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
                    style: TextStyle(
                        fontSize: width / 18, fontFamily: "popinsemi"),
                  ),
                  SizedBox(
                    height: width / 20,
                  ),
                  _rekomendasiBuilder(),
                  SizedBox(
                    height: width / 10,
                  ),
                  Attribute()
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _card(width, Rekomendasi data, int i) {
    if (data.data.isNotEmpty) {
      return OpenContainer(
        openElevation: 0,
        closedElevation: 0,
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
                            onPressed: () {
                              addToCart(data.data[i].id);
                            },
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
                          minRadius: width / 25,
                          maxRadius: width / 25,
                          backgroundImage: NetworkImage(data.data[0].fotoToko),
                        ),
                        SizedBox(
                          width: width / 40,
                        ),
                        Text(
                          data.data[i].namaToko.length >= 10
                              ? "${data.data[i].namaToko.substring(0, 9)}..."
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
                          data.data[i].namaBarang,
                          style: TextStyle(
                              fontSize: width / 23, fontFamily: "popinsemi"),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                              data.data[i].diskon == 0
                                  ? data.data[i].harga
                                  : (0.5 * data.data[i].harga) -
                                      data.data[i].diskon,
                              0),
                          style:
                              TextStyle(fontSize: width / 35, color: grayText),
                        ),
                        data.data[i].diskon == 0
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
                                            BorderRadius.circular(width / 90),
                                        color: Colors.blue.withOpacity(0.7)),
                                    child: Text(
                                      "${data.data[i].diskon}%",
                                      style: TextStyle(
                                          fontSize: width / 35,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: width / 40),
                                  Text(
                                    CurrencyFormat.convertToIdr(
                                        data.data[i].harga, 0),
                                    style: TextStyle(
                                        fontSize: width / 35,
                                        color: Colors.grey.withOpacity(0.6),
                                        decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              ),
                        Text(
                          data.data[i].daerah,
                          style:
                              TextStyle(fontSize: width / 35, color: grayText),
                        ),
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
                elevation: 0, backgroundColor: Colors.white,
                side: BorderSide(width: 1, color: Color(0xff898989)),
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
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular((width / 40))),
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 18, vertical: width / 90)),
                  onPressed: () =>
                      Get.to(DiskonPage(), transition: Transition.rightToLeft),
                  child: Text("Get now",
                      style: TextStyle(
                          color: blueTheme,
                          fontFamily: "popinsemi",
                          fontSize: width / 25)))
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

  Widget _loadingState(height, width) {
    return Container(
      padding: EdgeInsets.all(width / 40),
      margin:
          EdgeInsets.symmetric(horizontal: width / 50, vertical: width / 40),
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
          FadeShimmer(
            width: width,
            height: height / 6,
            radius: width / 50,
            baseColor: Colors.grey.withOpacity(0.2),
            highlightColor: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(
            height: width / 30,
          ),
          FadeShimmer(
            width: width,
            height: height / 75,
            radius: width,
            baseColor: Colors.grey.withOpacity(0.2),
            highlightColor: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(
            height: width / 50,
          ),
          FadeShimmer(
            width: width / 5,
            height: height / 75,
            radius: width,
            baseColor: Colors.grey.withOpacity(0.2),
            highlightColor: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
