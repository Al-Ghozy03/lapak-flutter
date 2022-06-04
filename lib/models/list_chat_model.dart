// To parse required this JSON data, do
//
//     final listChat = listChatFromJson(jsonString);

import 'dart:convert';

ListChat listChatFromJson(String str) => ListChat.fromJson(json.decode(str));

String listChatToJson(ListChat data) => json.encode(data.toJson());

class ListChat {
    ListChat({
        required this.data,
    });

    List<Datum> data;

    factory ListChat.fromJson(Map<String, dynamic> json) => ListChat(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        required this.idList,
        required this.receiver,
        required this.roomCode,
        required this.name,
        required this.photoProfile,
    });

    int idList;
    int receiver;
    String roomCode;
    String name;
    dynamic photoProfile;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        idList: json["id_list"],
        receiver: json["receiver"],
        roomCode: json["room_code"],
        name: json["name"],
        photoProfile: json["photo_profile"],
    );

    Map<String, dynamic> toJson() => {
        "id_list": idList,
        "receiver": receiver,
        "room_code": roomCode,
        "name": name,
        "photo_profile": photoProfile,
    };
}
