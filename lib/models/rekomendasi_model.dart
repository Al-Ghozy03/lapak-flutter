// To parse required this JSON data, do
//
//     final rekomendasi = rekomendasiFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators, unnecessary_null_comparison

import 'dart:convert';

Rekomendasi rekomendasiFromJson(String str) => Rekomendasi.fromJson(json.decode(str));

String rekomendasiToJson(Rekomendasi data) => json.encode(data.toJson());

class Rekomendasi {
    Rekomendasi({
        required this.data,
    });

    List<Datum> data;

    factory Rekomendasi.fromJson(Map<String, dynamic> json) => Rekomendasi(
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
        required this.beratBarang,
        required this.diskon,
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
    dynamic beratBarang;
    int diskon;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] == null ? null : json["id"],
        storeId: json["store_id"] == null ? null : json["store_id"],
        owner: json["owner"],
        namaToko: json["nama_toko"],
        daerah: json["daerah"],
        fotoToko: json["foto_toko"],
        namaBarang: json["nama_barang"] == null ? null : json["nama_barang"],
        harga: json["harga"] == null ? null : json["harga"],
        deskripsi: json["deskripsi"] == null ? null : json["deskripsi"],
        kategori: json["kategori"] == null ? null : json["kategori"],
        fotoBarang: json["foto_barang"] == null ? null : json["foto_barang"],
        beratBarang: json["berat_barang"],
        diskon: json["diskon"] == null ? null : json["diskon"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "store_id": storeId == null ? null : storeId,
        "owner": owner,
        "nama_toko": namaToko,
        "daerah": daerah,
        "foto_toko": fotoToko,
        "nama_barang": namaBarang == null ? null : namaBarang,
        "harga": harga == null ? null : harga,
        "deskripsi": deskripsi == null ? null : deskripsi,
        "kategori": kategori == null ? null : kategori,
        "foto_barang": fotoBarang == null ? null : fotoBarang,
        "berat_barang": beratBarang,
        "diskon": diskon == null ? null : diskon,
    };
}
