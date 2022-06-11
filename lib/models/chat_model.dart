class ChatModel {
  ChatModel(
      {required this.id,
      required this.from,
      required this.to,
      required this.message,
      required this.roomCode,
      required this.createdAt,
      required this.updatedAt,
      required this.isRead});

  int id;
  int from;
  int to;
  String message;
  String roomCode;
  bool isRead;
  DateTime createdAt;
  DateTime updatedAt;
}
