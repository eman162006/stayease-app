class AppUser {
  final String name;
  final String email;

  AppUser({required this.name, required this.email});

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: json["name"],
        email: json["email"],
      );
}