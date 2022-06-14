class Notif {
  Notif(
      {required this.from,
      this.id,
      this.photoProfile,
      required this.createdAt,
      required this.message,
      required this.to,
      required this.name,
      required this.isRead});
  int? id;
  int from;
  String message;
  dynamic photoProfile;
  String name;
  DateTime createdAt;
  int to;
  bool isRead;
}
