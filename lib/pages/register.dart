// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable, sized_box_for_whitespace, avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/pages/dashboard.dart';
import 'package:lapak/style/color.dart';
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
  String? errorEmail = "";
  String? errorName = "";
  String? errorPassword = "";
  String? errorPhone = "";
  String? errorAlamat = "";
  bool isLoading = false;

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
      errorEmail = "";
      errorName = "";
      errorPassword = "";
      errorPhone = "";
      errorAlamat = "";
    });
    if (res.statusCode == 200) {
      setState(() {
        isLoading = false;
        sharedPreferences.setString("token", jsonDecode(res.body)["token"]);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
      });
    } else {
      print(jsonDecode(res.body));
      setState(() {
        isLoading = false;
        if (jsonDecode(res.body)["error"]["email"]["msg"] == null) {
          errorEmail = jsonDecode(res.body)["error"]["email"]["msg"];
        }
        // errorName = jsonDecode(res.body)["error"]["name"]["msg"]!;
        // errorPassword = jsonDecode(res.body)["error"]["password"]["msg"]!;
        // errorPhone = jsonDecode(res.body)["error"]["phone"]["msg"]!;
        // errorAlamat = jsonDecode(res.body)["error"]["alamat"]["msg"]!;
      });
    }
  }

  bool isShow = true;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width / 20),
          child: Column(
            children: [
              Row(children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
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
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/register.jpg"))),
                width: width,
                height: height / 2.6,
              ),
              _form(width),
              SizedBox(
                height: width / 30,
              ),
              Center(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
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
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: grayBorder, width: 3)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
        ),
        Text(errorEmail!,
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
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: grayBorder, width: 3)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
        ),
        Text(errorName!,
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
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: grayBorder, width: 3)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: grayBorder, width: 3)),
          ),
        ),
        Text(errorPassword!,
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
        Text(errorPhone!,
            style: TextStyle(
                color: Colors.red,
                fontSize: width / 33,
                fontStyle: FontStyle.italic)),
        SizedBox(
          height: width / 15,
        ),
        _label("Alamat", width),
        SizedBox(
          height: width / 30,
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
        Text(errorAlamat!,
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
                registerHandle();
              },
              style: ElevatedButton.styleFrom(
                  primary: blueTheme,
                  padding: EdgeInsets.symmetric(vertical: width / 67),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
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
