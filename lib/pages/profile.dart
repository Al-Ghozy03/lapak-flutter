// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/profile_model.dart';
import 'package:lapak/style/color.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? selectedValue;
  CustomPopupMenuController controller = CustomPopupMenuController();

  late Profile profile;
  late Future getProfile;

  @override
  void initState() {
    getProfile = ApiService().getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: FutureBuilder(
        future: getProfile,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Text("loading");
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Terjadi kesalahan"),
            );
          } else {
            if (snapshot.hasData) {
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
                                children: [
                                  Text(
                                    "Edit",
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
                    title: Text("Profile"),
                    centerTitle: true,
                    elevation: 0,
                    snap: true,
                    backgroundColor: Colors.white,
                    floating: true,
                    titleTextStyle: TextStyle(
                        fontFamily: "popinsemi", fontSize: width / 15),
                    expandedHeight: width / 1.3,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        "assets/5559852.jpg",
                        fit: BoxFit.cover,
                      ),
                      title: Container(
                        margin: EdgeInsets.only(bottom: width / 7),
                        child: snapshot.data.data.photoProfile != null
                            ? CircleAvatar(
                                minRadius: width / 9,
                                maxRadius: width / 9,
                                backgroundImage: NetworkImage(
                                    snapshot.data.data.photoProfile),
                              )
                            : CircleAvatar(
                                minRadius: width / 9,
                                maxRadius: width / 9,
                                backgroundColor:
                                    Color.fromARGB(255, 196, 196, 196),
                              ),
                      ),
                      centerTitle: true,
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(height / 30),
                      child: Transform.translate(
                        offset: Offset(0, 1),
                        child: Container(
                          padding: EdgeInsets.only(top: width / 25),
                          height: width / 5.5,
                          width: width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(width / 15),
                                  topRight: Radius.circular(width / 15)),
                              color: Colors.white),
                          child: Center(
                              child: Text(
                            snapshot.data.data.name,
                            style: TextStyle(
                                fontSize: width / 18, fontFamily: "popinsemi"),
                          )),
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate.fixed([
                    SingleChildScrollView(
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.all(width / 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                thickness: 2,
                              ),
                              SizedBox(
                                height: width / 20,
                              ),
                              _info(width, "Nama", snapshot.data.data.name),
                              SizedBox(
                                height: width / 40,
                              ),
                              _info(width, "Email", snapshot.data.data.email),
                              SizedBox(
                                height: width / 40,
                              ),
                              _info(
                                  width, "Nomer HP", snapshot.data.data.phone.toString()),
                              SizedBox(
                                height: width / 40,
                              ),
                              _info(width, "Alamat", snapshot.data.data.alamat),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]))
                ],
              ));
            } else {
              return Center(
                child: Text("kosong"),
              );
            }
          }
        },
      ),
    );
  }

  Widget _info(width, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontFamily: "popinsemi", fontSize: width / 25),
        ),
        SizedBox(
          height: width / 100,
        ),
        Text(
          value,
          style: TextStyle(color: grayText, fontSize: width / 25),
        )
      ],
    );
  }
}
