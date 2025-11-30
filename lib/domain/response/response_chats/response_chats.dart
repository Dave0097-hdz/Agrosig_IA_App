import '../../models/chats/chats_model.dart';

class CommentResponse {
  final bool success;
  final String message;
  final Comment? data;

  CommentResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) => CommentResponse(
    success: json["success"] ?? false,
    message: json["message"] ?? '',
    data: json["data"] != null ? Comment.fromJson(json["data"]) : null,
  );
}

class CommentsListResponse {
  final bool success;
  final String message;
  final List<Comment> data;

  CommentsListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CommentsListResponse.fromJson(Map<String, dynamic> json) => CommentsListResponse(
    success: json["success"] ?? false,
    message: json["message"] ?? '',
    data: json["data"] != null
        ? List<Comment>.from(json["data"].map((x) => Comment.fromJson(x)))
        : [],
  );
}