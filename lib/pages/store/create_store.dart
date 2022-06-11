// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, await_only_futures, deprecated_member_use, depend_on_referenced_packages, invalid_return_type_for_catch_error, avoid_print, sized_box_for_whitespace

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/pages/store/toko.dart';
import 'package:lapak/style/color.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateStore extends StatefulWidget {
  const CreateStore({Key? key}) : super(key: key);

  @override
  State<CreateStore> createState() => _CreateStoreState();
}

class _CreateStoreState extends State<CreateStore> {
  File? path;
  bool isLoading = false;
  TextEditingController namaToko = TextEditingController();
  TextEditingController daerah = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        path = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future createStore(File imgFile, BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    var stream = http.ByteStream(DelegatingStream.typed(imgFile.openRead()));
    var length = await imgFile.length();
    Uri url = Uri.parse("$baseUrl/store/create");
    SharedPreferences storage = await SharedPreferences.getInstance();

    final req = http.MultipartRequest("POST", url);
    req.fields["nama_toko"] = namaToko.text;
    req.fields["daerah"] = daerah.text;
    req.headers["Authorization"] = "Bearer ${storage.getString("token")}";
    var multipartFile = http.MultipartFile('photo_profile', stream, length,
        filename: basename(imgFile.path));
    req.files.add(multipartFile);

    await req.send().then((result) async {
      http.Response.fromStream(result)
          .then((res) {
            if (res.statusCode == 200) {
              setState(() {
                isLoading = false;
              });
              Get.off(Toko(storeId: jsonDecode(res.body)["data"]["id"]),
                  transition: Transition.rightToLeft);
              return true;
            } else {
              setState(() {
                isLoading = false;
              });
              print(res.statusCode);
              print(res.body);
              return false;
            }
          })
          .catchError((err) => print(err.toString()))
          .whenComplete(() {});
    });
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
              _header(context, width),
              SizedBox(
                height: width / 15,
              ),
              _label("Nama toko", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: namaToko,
                style: TextStyle(fontSize: width / 33),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                ),
              ),
              SizedBox(
                height: width / 35,
              ),
              _label("Daerah", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: daerah,
                style: TextStyle(fontSize: width / 33),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  InkWell(
                    onTap: () async => await getImage(),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: width / 10),
                      height: width / 1.5,
                      decoration: BoxDecoration(
                          image: path != null
                              ? DecorationImage(image: FileImage(path!))
                              : DecorationImage(
                                  image: AssetImage("assets/08973278.png"))),
                    ),
                  ),
                  Positioned(
                    top: width / 1.3,
                    child: Center(
                      child: path == null
                          ? Text(
                              "Masukan foto toko",
                              style: TextStyle(
                                  color: grayText,
                                  fontFamily: "popinmedium",
                                  fontSize: width / 25),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.red, width: width / 300),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width / 25)),
                              onPressed: () {
                                setState(() {
                                  path = null;
                                });
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    fontSize: width / 20, color: Colors.red),
                              )),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: width / 20,
              ),
              Container(
                width: width,
                child: ElevatedButton(
                    onPressed: () {
                      createStore(_image!, context);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: blueTheme,
                        padding: EdgeInsets.symmetric(
                          vertical: width / 55,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width / 50))),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "Buat toko",
                            style: TextStyle(
                                fontSize: width / 20, fontFamily: "popinsemi"),
                          )),
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _label(String text, width) {
    return Text(
      text,
      style: TextStyle(fontSize: width / 22, fontFamily: "popinmedium"),
    );
  }

  Widget _header(BuildContext context, width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Iconsax.arrow_left)),
        Text(
          "Toko",
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
