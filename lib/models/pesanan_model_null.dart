// To parse required this JSON data, do
//
//     final pesananModelNull = pesananModelNullFromJson(jsonString);

import 'dart:convert';

PesananModelNull pesananModelNullFromJson(String str) => PesananModelNull.fromJson(json.decode(str));

String pesananModelNullToJson(PesananModelNull data) => json.encode(data.toJson());

class PesananModelNull {
    PesananModelNull({
        required this.data,
    });

    List<Datum> data;

    factory PesananModelNull.fromJson(Map<String, dynamic> json) => PesananModelNull(
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
    dynamic item;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        owner: json["owner"],
        namaToko: json["nama_toko"],
        daerah: json["daerah"],
        fotoToko: json["foto_toko"],
        item: json["item"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "owner": owner,
        "nama_toko": namaToko,
        "daerah": daerah,
        "foto_toko": fotoToko,
        "item": item,
    };
}
