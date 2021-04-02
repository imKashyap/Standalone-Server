class User {
  final String name;
  final String email;
  final String password;
  final String created = DateTime.now().toIso8601String();

  User({this.name, this.email, this.password});
}
