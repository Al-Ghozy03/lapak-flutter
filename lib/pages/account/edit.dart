// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, depend_on_referenced_packages, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, sized_box_for_whitespace

import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/style/color.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final data;
  EditProfile({required this.data});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController alamat = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();

  final picker = ImagePicker();
  bool isLoading = false;
  bool hidden = true;
  File _image = File("");
  File path = File("");

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

  Future updateProfile(File imgFile) async {
    setState(() {
      isLoading = true;
    });
    Uri url = Uri.parse("$baseUrl/user/update");
    SharedPreferences storage = await SharedPreferences.getInstance();
    final req = http.MultipartRequest("PUT", url);
    if (_image.path.isNotEmpty) {
      var stream = http.ByteStream(DelegatingStream.typed(imgFile.openRead()));
      var length = await imgFile.length();
      var multipartFile = http.MultipartFile('photo_profile', stream, length,
          filename: basename(imgFile.path));
      req.files.add(multipartFile);
    }
    req.fields["name"] = name.text;
    req.fields["email"] = email.text;
    if (password.text.isNotEmpty) {
      req.fields["password"] = password.text;
    }
    req.fields["phone"] = phone.text;
    req.fields["alamat"] = alamat.text;
    req.headers["Authorization"] = "Bearer ${storage.getString("token")}";

    await req.send().then((result) async {
      http.Response.fromStream(result).then((res) {
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
          print(res.body);
          Get.snackbar("Gagal", "terjadi kesalahan, silahkan coba lagi",
              snackPosition: SnackPosition.BOTTOM,
              leftBarIndicatorColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.3));
        }
      });
    });
  }

  @override
  void initState() {
    name.text = widget.data.name;
    email.text = widget.data.email;
    phone.text = widget.data.phone.toString();
    alamat.text = widget.data.alamat;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(width / 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, width),
              SizedBox(
                height: width / 10,
              ),
              _label("Foto profile", width),
              SizedBox(
                height: width / 20,
              ),
              Center(
                  child: InkWell(
                onTap: () async => await getImage(),
                child: path.path.isEmpty
                    ? widget.data.photoProfile == null
                        ? CircleAvatar(
                            maxRadius: width / 6,
                            minRadius: width / 6,
                            backgroundColor: grayBorder,
                            child: Icon(
                              Iconsax.camera5,
                              color: Colors.white,
                              size: width / 7,
                            ),
                          )
                        : CircleAvatar(
                            maxRadius: width / 6,
                            minRadius: width / 6,
                            backgroundImage:
                                NetworkImage(widget.data.photoProfile),
                            child: Icon(
                              Iconsax.camera5,
                              color: Colors.white.withOpacity(0.7),
                              size: width / 7,
                            ))
                    : CircleAvatar(
                        maxRadius: width / 6,
                        minRadius: width / 6,
                        backgroundImage: FileImage(path),
                        child: Icon(
                          Iconsax.camera5,
                          color: Colors.white.withOpacity(0.7),
                          size: width / 7,
                        ),
                      ),
              )),
              SizedBox(
                height: width / 10,
              ),
              _label("Nama", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: name,
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
                height: width / 10,
              ),
              _label("Email", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: email,
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
                height: width / 10,
              ),
              _label("Password", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: password,
                style: TextStyle(fontSize: width / 33),
                obscureText: hidden,
                decoration: InputDecoration(
                  hintText: "*************",
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidden = !hidden;
                      });
                    },
                    icon: Icon(hidden ? Iconsax.eye : Iconsax.eye_slash),
                    iconSize: width / 20,
                    color: !hidden ? Color(0xff4C82F6) : Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                ),
              ),
              SizedBox(
                height: width / 10,
              ),
              _label("Phone", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: phone,
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
                height: width / 10,
              ),
              _label("Alamat", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: alamat,
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
                height: width / 15,
              ),
              Container(
                width: width,
                child: ElevatedButton(
                    onPressed: () {
                      updateProfile(_image);
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
                            "Simpan",
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
          "Edit",
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
