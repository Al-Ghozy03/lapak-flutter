// To parse required this JSON data, do
//
//     final cart = cartFromJson(jsonString);

import 'dart:convert';

Cart cartFromJson(String str) => Cart.fromJson(json.decode(str));

String cartToJson(Cart data) => json.encode(data.toJson());

class Cart {
    Cart({
        required this.data,
    });

    List<Datum> data;

    factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        required this.id,
        required this.barangId,
        required this.userId,
        required this.storeId,
        required this.namaBarang,
        required this.harga,
        required this.daerah,
        required this.deskripsi,
        required this.kategori,
        required this.diskon,
        required this.fotoBarang,
        required this.namaToko,
        required this.fotoToko,
    });

    int id;
    int barangId;
    int userId;
    int storeId;
    String namaBarang;
    int harga;
    String daerah;
    String deskripsi;
    String kategori;
    dynamic diskon;
    String fotoBarang;
    String namaToko;
    String fotoToko;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        barangId: json["barang_id"],
        userId: json["user_id"],
        storeId: json["store_id"],
        namaBarang: json["nama_barang"],
        harga: json["harga"],
        daerah: json["daerah"],
        deskripsi: json["deskripsi"],
        kategori: json["kategori"],
        diskon: json["diskon"],
        fotoBarang: json["foto_barang"],
        namaToko: json["nama_toko"],
        fotoToko: json["foto_toko"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "barang_id": barangId,
        "user_id": userId,
        "store_id": storeId,
        "nama_barang": namaBarang,
        "harga": harga,
        "daerah": daerah,
        "deskripsi": deskripsi,
        "kategori": kategori,
        "diskon": diskon,
        "foto_barang": fotoBarang,
        "nama_toko": namaToko,
        "foto_toko": fotoToko,
    };
}
