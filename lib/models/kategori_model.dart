// To parse required this JSON data, do
//
//     final kategori = kategoriFromJson(jsonString);

import 'dart:convert';

Kategori kategoriFromJson(String str) => Kategori.fromJson(json.decode(str));

String kategoriToJson(Kategori data) => json.encode(data.toJson());

class Kategori {
    Kategori({
        required this.data,
    });

    List<Datum> data;

    factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        required this.id,
        required this.storeId,
        required this.owner,
        required this.namaToko,
        required this.daerah,
        required this.fotoToko,
        required this.namaBarang,
        required this.harga,
        required this.deskripsi,
        required this.kategori,
        required this.fotoBarang,
    });

    int id;
    int storeId;
    int owner;
    String namaToko;
    String daerah;
    String fotoToko;
    String namaBarang;
    int harga;
    String deskripsi;
    String kategori;
    String fotoBarang;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        storeId: json["store_id"],
        owner: json["owner"],
        namaToko: json["nama_toko"],
        daerah: json["daerah"],
        fotoToko: json["foto_toko"],
        namaBarang: json["nama_barang"],
        harga: json["harga"],
        deskripsi: json["deskripsi"],
        kategori: json["kategori"],
        fotoBarang: json["foto_barang"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "store_id": storeId,
        "owner": owner,
        "nama_toko": namaToko,
        "daerah": daerah,
        "foto_toko": fotoToko,
        "nama_barang": namaBarang,
        "harga": harga,
        "deskripsi": deskripsi,
        "kategori": kategori,
        "foto_barang": fotoBarang,
    };
}
