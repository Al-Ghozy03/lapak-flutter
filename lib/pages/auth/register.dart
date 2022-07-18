// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable, sized_box_for_whitespace, avoid_print, use_build_context_synchronously, prefer_if_null_operators

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/models/info_model.dart';
import 'package:lapak/pages/dashboard.dart';
import 'package:lapak/style/color.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController alamat = TextEditingController();
  bool isLoading = false;
  String errorName = "";
  String errorPassword = "";
  String errorAlamat = "";
  String errorEmail = "";
  String errorPhone = "";
  Future registerHandle() async {
    setState(() {
      isLoading = true;
    });
    Uri url = Uri.parse("$baseUrl/user/register");
    final res = await http.post(url,
        body: jsonEncode({
          "name": name.text,
          "email": email.text,
          "password": password.text,
          "phone": phone.text,
          "alamat": alamat.text
        }),
        headers: {"Content-Type": "application/json"});
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (name.text.isEmpty) {
        errorName = "Nama wajib diisi";
      } else if (password.text.isEmpty) {
        errorPassword = "Password wajib diisi";
      } else if (alamat.text.isEmpty) {
        errorAlamat = "Alamat wajib diisi";
      }
    });
    if (res.statusCode == 200) {
      setState(() {
        isLoading = false;
        sharedPreferences.setString("token", jsonDecode(res.body)["token"]);
        final Info info = Info.fromJson({
          "name": jsonDecode(res.body)["data"]["name"],
          "alamat": jsonDecode(res.body)["data"]["alamat"],
          "photo_profile": jsonDecode(res.body)["data"]["photo_profile"],
        });
        sharedPreferences.setString("info", jsonEncode(info));
        Get.off(Dashboard(), transition: Transition.rightToLeft);
      });
    } else {
      var data = jsonDecode(res.body);
      setState(() {
        isLoading = false;
        print(data["message"]);
        if (data["message"] == "email sudah digunakan") {
          errorEmail = data["message"];
          errorPhone = "";
        } else {
          errorPhone = data["message"];
          errorEmail = "";
        }
      });
      return false;
    }
  }

  bool isShow = true;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width / 20),
          child: Column(
            children: [
              Row(children: [
                IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Iconsax.arrow_left)),
                SizedBox(
                  width: width / 15,
                ),
                Text(
                  "Register",
                  style: TextStyle(
                      fontSize: width / 15,
                      fontFamily: "popinsemi",
                      color: blueTheme),
                ),
              ]),
              LottieBuilder.asset("assets/json/63787-secure-login.json"),
              _form(width),
              SizedBox(
                height: width / 30,
              ),
              Center(
                child: InkWell(
                  onTap: () => Get.back(),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "popin",
                              fontSize: width / 35),
                          children: [
                        TextSpan(text: "Already have an account?"),
                        TextSpan(
                            text: " Login", style: TextStyle(color: blueTheme)),
                      ])),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _form(width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Email", width),
        SizedBox(
          height: width / 30,
        ),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontSize: width / 33),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width / 30),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
        ),
        Text(errorEmail,
            style: TextStyle(
                color: Colors.red,
                fontSize: width / 33,
                fontStyle: FontStyle.italic)),
        SizedBox(
          height: width / 30,
        ),
        _label("Nama", width),
        SizedBox(
          height: width / 30,
        ),
        TextField(
          controller: name,
          style: TextStyle(fontSize: width / 33),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width / 30),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
          keyboardType: TextInputType.name,
        ),
        Text(errorName,
            style: TextStyle(
                color: Colors.red,
                fontSize: width / 33,
                fontStyle: FontStyle.italic)),
        SizedBox(
          height: width / 30,
        ),
        _label("Password", width),
        SizedBox(
          height: width / 30,
        ),
        TextField(
          controller: password,
          style: TextStyle(fontSize: width / 33),
          obscureText: isShow,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isShow = !isShow;
                });
              },
              icon: Icon(isShow ? Iconsax.eye : Iconsax.eye_slash),
              iconSize: width / 20,
              color: !isShow ? Color(0xff4C82F6) : Colors.grey,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width / 30),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
        ),
        Text(errorPassword,
            style: TextStyle(
                color: Colors.red,
                fontSize: width / 33,
                fontStyle: FontStyle.italic)),
        SizedBox(
          height: width / 15,
        ),
        _label("Phone", width),
        SizedBox(
          height: width / 30,
        ),
        TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          maxLength: 12,
          style: TextStyle(fontSize: width / 33),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width / 30),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
        ),
        Text(errorPhone,
            style: TextStyle(
                color: Colors.red,
                fontSize: width / 33,
                fontStyle: FontStyle.italic)),
        SizedBox(
          height: width / 40,
        ),
        _label("Alamat", width),
        SizedBox(
          height: width / 30,
        ),
        TextField(
          controller: alamat,
          style: TextStyle(fontSize: width / 33),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width / 30),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
        ),
        Text(errorAlamat,
            style: TextStyle(
                color: Colors.red,
                fontSize: width / 33,
                fontStyle: FontStyle.italic)),
        SizedBox(
          height: width / 15,
        ),
        Container(
          width: width,
          child: ElevatedButton(
              onPressed: () {
                if (email.text.isEmpty ||
                    name.text.isEmpty ||
                    password.text.isEmpty ||
                    phone.text.isEmpty ||
                    alamat.text.isEmpty) {
                  Dialogs.materialDialog(
                      context: context,
                      lottieBuilder:
                          LottieBuilder.asset("assets/json/94900-error.json"),
                      title: "Terjadi kesalahan",
                      titleStyle: TextStyle(
                          fontFamily: "popinsemi",
                          fontSize: MediaQuery.of(context).size.width / 20),
                      msg: "Semua field harus diisi",
                      msgStyle:
                          TextStyle(color: grayText, fontSize: width / 30),
                      actions: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: blueTheme,
                                padding:
                                    EdgeInsets.symmetric(vertical: width / 67),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(width / 50))),
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              "Ok",
                              style: TextStyle(fontSize: width / 30),
                            ))
                      ]);
                  return;
                }
                registerHandle();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: blueTheme,
                  padding: EdgeInsets.symmetric(vertical: width / 67),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width / 50))),
              child: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      "Register",
                      style: TextStyle(
                          fontSize: width / 21,
                          fontFamily: "popinsemi",
                          color: Colors.white),
                    )),
        )
      ],
    );
  }
}

Widget _label(String text, width) {
  return Text(
    text,
    style: TextStyle(fontSize: width / 22, fontFamily: "popinmedium"),
  );
}
