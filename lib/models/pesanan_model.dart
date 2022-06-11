// To parse required this JSON data, do
//
//     final pesanan = pesananFromJson(jsonString);

import 'dart:convert';

Pesanan pesananFromJson(String str) => Pesanan.fromJson(json.decode(str));

String pesananToJson(Pesanan data) => json.encode(data.toJson());

class Pesanan {
    Pesanan({
        required this.data,
    });

    List<Datum> data;

    factory Pesanan.fromJson(Map<String, dynamic> json) => Pesanan(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        required this.id,
        required this.userId,
        required this.barangId,
        required this.storeId,
        required this.totalBarang,
        required this.totalHarga,
        required this.alamat,
        required this.isPaid,
        required this.namaBarang,
        required this.harga,
        required this.daerah,
        required this.deskripsi,
        required this.kategori,
        required this.diskon,
        required this.fotoBarang,
        required this.owner,
        required this.namaToko,
        required this.fotoToko,
    });

    int id;
    int userId;
    int barangId;
    int storeId;
    int totalBarang;
    int totalHarga;
    String alamat;
    int isPaid;
    String namaBarang;
    int harga;
    String daerah;
    String deskripsi;
    String kategori;
    int diskon;
    String fotoBarang;
    int owner;
    String namaToko;
    String fotoToko;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        userId: json["user_id"],
        barangId: json["barang_id"],
        storeId: json["store_id"],
        totalBarang: json["total_barang"],
        totalHarga: json["total_harga"],
        alamat: json["alamat"],
        isPaid: json["is_paid"],
        namaBarang: json["nama_barang"],
        harga: json["harga"],
        daerah: json["daerah"],
        deskripsi: json["deskripsi"],
        kategori: json["kategori"],
        diskon: json["diskon"],
        fotoBarang: json["foto_barang"],
        owner: json["owner"],
        namaToko: json["nama_toko"],
        fotoToko: json["foto_toko"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "barang_id": barangId,
        "store_id": storeId,
        "total_barang": totalBarang,
        "total_harga": totalHarga,
        "alamat": alamat,
        "is_paid": isPaid,
        "nama_barang": namaBarang,
        "harga": harga,
        "daerah": daerah,
        "deskripsi": deskripsi,
        "kategori": kategori,
        "diskon": diskon,
        "foto_barang": fotoBarang,
        "owner": owner,
        "nama_toko": namaToko,
        "foto_toko": fotoToko,
    };
}
