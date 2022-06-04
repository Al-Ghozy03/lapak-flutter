class Notif {
  Notif(
      {required this.from,
      this.id,
      this.photoProfile,
      required this.message,
      required this.to,
      required this.name});
  int? id;
  int from;
  String message;
  dynamic photoProfile;
  String name;
  int to;
}
