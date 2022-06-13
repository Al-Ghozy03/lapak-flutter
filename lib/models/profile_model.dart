// To parse required this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
    Profile({
        required this.data,
    });

    Data data;

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
    };
}

class Data {
    Data({
        required this.id,
        required this.name,
        required this.email,
        required this.password,
        required this.phone,
        required this.alamat,
        required this.photoProfile,
        required this.hasStore,
        required this.storeId,
        required this.createdAt,
        required this.updatedAt,
    });

    int id;
    String name;
    String email;
    String password;
    String phone;
    String alamat;
    dynamic photoProfile;
    bool hasStore;
    dynamic storeId;
    DateTime createdAt;
    DateTime updatedAt;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        password: json["password"],
        phone: json["phone"],
        alamat: json["alamat"],
        photoProfile: json["photo_profile"],
        hasStore: json["hasStore"],
        storeId: json["store_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "alamat": alamat,
        "photo_profile": photoProfile,
        "hasStore": hasStore,
        "store_id": storeId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}
