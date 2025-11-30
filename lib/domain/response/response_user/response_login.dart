import '../../models/user/user_model.dart';

class ResponseLogin {
  final bool resp;
  final String msg;
  final User user;
  final String token;
  final String refreshToken;

  ResponseLogin({
    required this.resp,
    required this.msg,
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  factory ResponseLogin.fromJson(Map<String, dynamic> json) => ResponseLogin(
    resp: json["success"] ?? false,
    msg: json["message"] ?? '',
    user: User.fromJson(json["data"]["user"] ?? {}),
    token: json["data"]?["token"] ?? '',
    refreshToken: json["data"]?["refreshToken"] ?? '',
  );
}
