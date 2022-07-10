// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable, sized_box_for_whitespace, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/models/info_model.dart';
import 'package:lapak/pages/auth/register.dart';
import 'package:lapak/pages/dashboard.dart';
import 'package:lapak/style/color.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isShow = true;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String errorMessage = "";
  bool isLoading = false;
  Future loginHandle() async {
    setState(() {
      isLoading = true;
    });
    Uri url = Uri.parse("$baseUrl/user/login");
    final res = await http.post(url,
        body: jsonEncode({"email": email.text, "password": password.text}),
        headers: {"Content-Type": "application/json"});

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
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
      print(res.body);
      setState(() {
        isLoading = false;
        errorMessage = jsonDecode(res.body)["message"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Login",
                style: TextStyle(
                    fontSize: width / 15,
                    fontFamily: "popinsemi",
                    color: blueTheme),
              ),
              LottieBuilder.asset("assets/json/72883-login-page.json"),
              _form(width),
              SizedBox(
                height: width / 30,
              ),
              Center(
                child: InkWell(
                  onTap: () =>
                      Get.to(Register(), transition: Transition.rightToLeft),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "popin",
                              fontSize: width / 35),
                          children: [
                        TextSpan(text: "Don't have an account?"),
                        TextSpan(
                            text: " Register",
                            style: TextStyle(color: blueTheme)),
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
          style: TextStyle(fontSize: width / 33),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: width / 40),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width / 30),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        Text(errorMessage == "password salah" ? "" : errorMessage,
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
            contentPadding: EdgeInsets.symmetric(horizontal: width / 40),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width / 30),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
        ),
        Text(errorMessage == "password salah" ? errorMessage : "",
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
                if (email.text.isEmpty || password.text.isEmpty) {
                  Dialogs.materialDialog(
                      context: context,
                      lottieBuilder:
                          LottieBuilder.asset("assets/json/94900-error.json"),
                      title: "Terjadi kesalahan",
                      titleStyle: TextStyle(
                          fontFamily: "popinsemi",
                          fontSize: MediaQuery.of(context).size.width / 20),
                      msg: "Semua field harus diisi",
                      msgStyle: TextStyle(color: grayText),
                      actions: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: blueTheme,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(width / 40))),
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("Ok"))
                      ]);
                  return;
                }
                loginHandle();
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary: blueTheme,
                  padding: EdgeInsets.symmetric(vertical: width / 67),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width / 50))),
              child: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      "Login",
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
