// To parse required this JSON data, do
//
//     final pesananModel = pesananModelFromJson(jsonString);

import 'dart:convert';

PesananModel pesananModelFromJson(String str) => PesananModel.fromJson(json.decode(str));

String pesananModelToJson(PesananModel data) => json.encode(data.toJson());

class PesananModel {
    PesananModel({
        required this.data,
    });

    List<Datum> data;

    factory PesananModel.fromJson(Map<String, dynamic> json) => PesananModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        required this.id,
        required this.owner,
        required this.namaToko,
        required this.daerah,
        required this.fotoToko,
        required this.item,
    });

    int id;
    int owner;
    String namaToko;
    String daerah;
    String fotoToko;
    Item item;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        owner: json["owner"],
        namaToko: json["nama_toko"],
        daerah: json["daerah"],
        fotoToko: json["foto_toko"],
        item: Item.fromJson(json["item"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "owner": owner,
        "nama_toko": namaToko,
        "daerah": daerah,
        "foto_toko": fotoToko,
        "item": item.toJson(),
    };
}

class Item {
    Item({
        required this.id,
        required this.storeId,
        required this.namaBarang,
        required this.harga,
        required this.deskripsi,
        required this.kategori,
        required this.diskon,
        required this.fotoBarang,
        required this.orderBarang,
    });

    int id;
    int storeId;
    String namaBarang;
    int harga;
    String deskripsi;
    String kategori;
    int diskon;
    String fotoBarang;
    OrderBarang orderBarang;

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        storeId: json["store_id"],
        namaBarang: json["nama_barang"],
        harga: json["harga"],
        deskripsi: json["deskripsi"],
        kategori: json["kategori"],
        diskon: json["diskon"],
        fotoBarang: json["foto_barang"],
        orderBarang: OrderBarang.fromJson(json["order_barang"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "store_id": storeId,
        "nama_barang": namaBarang,
        "harga": harga,
        "deskripsi": deskripsi,
        "kategori": kategori,
        "diskon": diskon,
        "foto_barang": fotoBarang,
        "order_barang": orderBarang.toJson(),
    };
}

class OrderBarang {
    OrderBarang({
        required this.id,
        required this.userId,
        required this.totalBarang,
        required this.totalHarga,
        required this.alamat,
        required this.isPaid,
    });

    int id;
    int userId;
    int totalBarang;
    String totalHarga;
    String alamat;
    bool isPaid;

    factory OrderBarang.fromJson(Map<String, dynamic> json) => OrderBarang(
        id: json["id"],
        userId: json["user_id"],
        totalBarang: json["total_barang"],
        totalHarga: json["total_harga"],
        alamat: json["alamat"],
        isPaid: json["is_paid"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "total_barang": totalBarang,
        "total_harga": totalHarga,
        "alamat": alamat,
        "is_paid": isPaid,
    };
}
