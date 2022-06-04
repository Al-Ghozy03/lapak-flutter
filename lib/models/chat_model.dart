class ChatModel {
  ChatModel({
    this.id,
    required this.from,
    required this.to,
    required this.message,
    required this.roomCode,
     this.createdAt,
     this.updatedAt,
  });

  int? id;
  int from;
  int to;
  String message;
  String roomCode;
  DateTime? createdAt;
  DateTime? updatedAt;
}
