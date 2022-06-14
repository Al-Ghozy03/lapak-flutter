// To parse required this JSON data, do
//
//     final notification = notificationFromJson(jsonString);

import 'dart:convert';

Notification notificationFromJson(String str) => Notification.fromJson(json.decode(str));

String notificationToJson(Notification data) => json.encode(data.toJson());

class Notification {
    Notification({
        required this.data,
    });

    List<Datum> data;

    factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        required this.notifId,
        required this.from,
        required this.name,
        required this.message,
        required this.to,
        required this.createdAt,
        required this.photoProfile,
        required this.isRead
    });

    int notifId;
    int from;
    int to;
    String message;
    String name;
    DateTime createdAt;
    dynamic photoProfile;
    bool isRead;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        notifId: json["notif_id"],
        from: json["from"],
        name: json["name"],
        message: json["message"],
        to: json["to"],
        createdAt: DateTime.parse(json["created_at"]),
        photoProfile: json["photo_profile"],
        isRead: json["is_read"]
    );

    Map<String, dynamic> toJson() => {
        "notif_id": notifId,
        "from": from,
        "name": name,
        "message": message,
        "to": to,
        "is_read": isRead,
        "created_at": createdAt.toIso8601String(),
        "photo_profile": photoProfile,
    };
}
