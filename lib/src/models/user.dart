class User {
  final String uuid;
  final String name;
  final String email;
  final String password;
  final String created = DateTime.now().toIso8601String();

  User({this.uuid, this.name, this.email, this.password});
}
