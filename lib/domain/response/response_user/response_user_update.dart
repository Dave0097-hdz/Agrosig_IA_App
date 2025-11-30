
class UserUpdatedResponse {

  final bool resp;
  final String msg;
  final UserUpdated user;

  UserUpdatedResponse({
    required this.resp,
    required this.msg,
    required this.user,
  });

  factory UserUpdatedResponse.fromJson(Map<String, dynamic> json) => UserUpdatedResponse(
    resp: json["resp"],
    msg: json["msg"],
    user: UserUpdated.fromJson(json["user"]),
  );
}

class UserUpdated {

  final int id_user;
  final String firstName;
  final String lastName;
  final String image_user;
  final String email;
  final String phone;
  final int id_rol;
  final String notificationToken;
  final bool parcela_configurada;

  UserUpdated({
    required this.id_user,
    required this.firstName,
    required this.lastName,
    required this.image_user,
    required this.email,
    required this.phone,
    required this.id_rol,
    required this.notificationToken,
    required this.parcela_configurada
  });

  factory UserUpdated.fromJson(Map<String, dynamic> json) => UserUpdated(
      id_user: json["id_user"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      image_user: json["image_user"],
      email: json["email"],
      phone: json["phone"],
      id_rol: json["id_rol"],
      notificationToken: json["notificationToken"],
      parcela_configurada: json["parcela_configurada"]
  );
}
