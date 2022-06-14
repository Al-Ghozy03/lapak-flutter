// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, await_only_futures, deprecated_member_use, depend_on_referenced_packages, must_be_immutable, use_key_in_widget_constructors, use_build_context_synchronously, prefer_const_constructors_in_immutables, prefer_typing_uninitialized_variables, avoid_print, sized_box_for_whitespace

import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/style/color.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateBarang extends StatefulWidget {
  final data;
  UpdateBarang({required this.data});
  @override
  State<UpdateBarang> createState() => _UpdateBarangState();
}

class _UpdateBarangState extends State<UpdateBarang> {
  File? path;
  bool isLoading = false;
  TextEditingController namaBarang = TextEditingController();
  TextEditingController harga = TextEditingController();
  TextEditingController deskripsi = TextEditingController();
  TextEditingController diskon = TextEditingController();
  File _image = File("");
  String? selectedValue;
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

  Future updateBarang(File imgFile, BuildContext context, int id) async {
    setState(() {
      isLoading = true;
    });

    Uri url = Uri.parse("$baseUrl/barang/update/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    final req = http.MultipartRequest("PUT", url);
    if (_image.path.isNotEmpty) {
      var stream = http.ByteStream(DelegatingStream.typed(imgFile.openRead()));
      var length = await imgFile.length();
      var multipartFile = http.MultipartFile('foto_barang', stream, length,
          filename: basename(imgFile.path));
      req.files.add(multipartFile);
    }
    req.fields["store_id"] = widget.data.storeId.toString();
    req.fields["nama_barang"] = namaBarang.text;
    req.fields["harga"] = harga.text;
    req.fields["deskripsi"] = deskripsi.text;
    req.fields["diskon"] = diskon.text.isEmpty ? 0.toString() : diskon.text;
    req.fields["kategori"] = selectedValue.toString();
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
          return false;
        }
      });
    });
  }

  @override
  void initState() {
    namaBarang.text = widget.data.namaBarang;
    harga.text = widget.data.harga.toString();
    deskripsi.text = widget.data.deskripsi;
    diskon.text =
        widget.data.diskon == null ? "" : widget.data.diskon.toString();
    selectedValue = widget.data.kategori;
    super.initState();
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
              _label("Nama barang", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: namaBarang,
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
              _label("Harga", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: harga,
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
              _label("Deskripsi", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                maxLines: 10,
                controller: deskripsi,
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
              _label("Diskon", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: diskon,
                style: TextStyle(fontSize: width / 33),
                decoration: InputDecoration(
                  hintText: "Opsional",
                  suffix: Padding(
                    padding: EdgeInsets.only(right: width / 20),
                    child: Text(
                      "%",
                      style: TextStyle(fontSize: width / 30),
                    ),
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
                height: width / 35,
              ),
              _label("Kategori", width),
              SizedBox(
                height: width / 35,
              ),
              DropdownButton(
                hint: Text("Pilih kategori"),
                value: selectedValue,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
                items: [
                  "elektronik",
                  "makanan",
                  "fashion",
                  "aksesoris",
                  "buku",
                  "hiburan"
                ].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: width / 10),
                    height: width / 1.8,
                    decoration: BoxDecoration(
                        image: path != null
                            ? DecorationImage(image: FileImage(path!))
                            : DecorationImage(
                                image: NetworkImage(widget.data.fotoBarang))),
                  ),
                  Positioned(
                    top: width / 1.5,
                    child: Center(
                      child: widget.data.fotoBarang == null
                          ? Text(
                              "Masukan foto barang",
                              style: TextStyle(
                                  color: grayText,
                                  fontFamily: "popinmedium",
                                  fontSize: width / 25),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: blueTheme, width: width / 300),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width / 25)),
                              onPressed: () async {
                                await getImage();
                              },
                              child: Text(
                                "Ganti foto barang",
                                style: TextStyle(
                                    fontSize: width / 20, color: blueTheme),
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
                      updateBarang(_image, context, widget.data.id);
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
