class User {

  final int user_id;
  final int role_id;
  final String first_name;
  final String paternal_surname;
  final String maternal_surname;
  final String email;
  final String? image_user;
  final bool configured_plot;
  final bool is_active;

  User({
    required this.user_id,
    required this.role_id,
    required this.first_name,
    required this.paternal_surname,
    required this.maternal_surname,
    required this.email,
    this.image_user,
    required this.configured_plot,
    required this.is_active,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    user_id: json["user_id"] ?? 0,
    role_id: json["role_id"] ?? 2,
    first_name: json["first_name"] ?? '',
    paternal_surname: json["paternal_surname"] ?? '',
    maternal_surname: json["maternal_surname"] ?? '',
    email: json["email"] ?? '',
    image_user: json["image_user"],
    configured_plot: json["configured_plot"] ?? false,
    is_active: json["is_active"] ?? true,
  );

  String get fullName => '$first_name $paternal_surname $maternal_surname'.trim();
}