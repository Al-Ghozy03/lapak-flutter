// To parse required this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'dart:convert';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {
  Message({
    required this.data,
  });

  List<Datum> data;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.from,
    required this.to,
    required this.message,
    required this.roomCode,
    required this.createdAt,
    required this.updatedAt,
    required this.isRead
  });

  int id;
  int from;
  int to;
  String message;
  String roomCode;
  bool isRead;
  DateTime createdAt;
  DateTime updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        from: json["from"],
        to: json["to"],
        message: json["message"],
        roomCode: json["room_code"],
        isRead: json["is_read"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "from": from,
        "to": to,
        "message": message,
        "room_code": roomCode,
        "is_read": isRead,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
