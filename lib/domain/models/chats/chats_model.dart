class Comment {
  final int commentId;
  final int userId;
  final String message;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? firstName;
  final String? email;

  Comment({
    required this.commentId,
    required this.userId,
    required this.message,
    required this.isEdited,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.firstName,
    this.email,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    commentId: json["comment_id"] ?? 0,
    userId: json["user_id"] ?? 0,
    message: json["message"] ?? '',
    isEdited: json["is_edited"] ?? false,
    isDeleted: json["is_deleted"] ?? false,
    createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
    firstName: json["first_name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}
