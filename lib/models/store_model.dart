// To parse required this JSON data, do
//
//     final store = storeFromJson(jsonString);

// ignore_for_file: unnecessary_null_in_if_null_operators, prefer_if_null_operators

import 'dart:convert';

Store storeFromJson(String str) => Store.fromJson(json.decode(str));

String storeToJson(Store data) => json.encode(data.toJson());

class Store {
  Store({
    required this.data,
  });

  Data data;

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.id,
    required this.owner,
    required this.namaToko,
    required this.daerah,
    required this.photoProfile,
    required this.createdAt,
    required this.updatedAt,
    required this.barang,
  });

  int id;
  int owner;
  String namaToko;
  String daerah;
  String photoProfile;
  DateTime createdAt;
  DateTime updatedAt;
  List<Barang> barang;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        owner: json["owner"],
        namaToko: json["nama_toko"],
        daerah: json["daerah"],
        photoProfile: json["photo_profile"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        barang:
            List<Barang>.from(json["barang"].map((x) => Barang.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner": owner,
        "nama_toko": namaToko,
        "daerah": daerah,
        "photo_profile": photoProfile,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "barang": List<dynamic>.from(barang.map((x) => x.toJson())),
      };
}

class Barang {
  Barang({
    required this.id,
    required this.storeId,
    required this.namaBarang,
    required this.harga,
    required this.deskripsi,
    required this.kategori,
    required this.diskon,
    required this.fotoBarang,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int? storeId;
  String namaBarang;
  int harga;
  String deskripsi;
  String kategori;
  int? diskon;
  String fotoBarang;
  DateTime createdAt;
  DateTime updatedAt;

  factory Barang.fromJson(Map<String, dynamic> json) => Barang(
        id: json["id"],
        storeId: json["store_id"],
        namaBarang: json["nama_barang"],
        harga: json["harga"],
        deskripsi: json["deskripsi"],
        kategori: json["kategori"],
        diskon: json["diskon"] ?? null,
        fotoBarang: json["foto_barang"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "store_id": storeId,
        "nama_barang": namaBarang,
        "harga": harga,
        "deskripsi": deskripsi,
        "kategori": kategori,
        "diskon": diskon == null ? null : diskon,
        "foto_barang": fotoBarang,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
