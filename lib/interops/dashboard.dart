import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:http/http.dart' as http;

String token;
void main(List<String> args) async {
  var tokenCookie = document.cookie
      .split('; ')
      .firstWhere((row) => row.startsWith('token='), orElse: () => null);
  if (tokenCookie == null || tokenCookie.split('=')[1].isEmpty) {
    document.window.location.href = '/';
  } else {
    token = tokenCookie.split('=')[1];
    window.console.log(token);
    final url = 'http://localhost:4040/user/';
    var res = await http
        .get(url, headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    document.getElementById('user').innerHtml =
        '<i class="fas fa-user"></i> &nbsp ${json.decode(res.body)['name']}';
    querySelector('.sign-out').onClick.listen(logouthandler);
    querySelector('.delete-user').onClick.listen(deleteUserHandler);
    querySelector('.edit-name').onClick.listen(editNameHandler);
  }
}

void logouthandler(MouseEvent event) async {
  event.preventDefault();
  final logout = 'http://localhost:4040/auth/logout';
  var res = await http.post(logout,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
  if (res.statusCode == 200) {
    document.cookie.split(';').forEach((c) {
      var eqPos = c.indexOf('=');
      var name = eqPos > -1 ? c.substring(0, eqPos) : c;
      document.cookie =
          name + '=;expires=' + DateTime.now().toUtc().toString() + ';path=/';
    });
    window.localStorage.clear();
    document.window.location.href = '/';
  }
}

Future<void> deleteUserHandler(MouseEvent event) async {
  event.preventDefault();
  final url = 'http://localhost:4040/user/';
  var res = await http
      .delete(url, headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
  if (res.statusCode == 200) {
    document.cookie.split(';').forEach((c) {
      var eqPos = c.indexOf('=');
      var name = eqPos > -1 ? c.substring(0, eqPos) : c;
      document.cookie =
          name + '=;expires=' + DateTime.now().toUtc().toString() + ';path=/';
    });
    window.localStorage.clear();
    document.window.location.href = '/';
  }
}

void editNameHandler(MouseEvent event) async {
//   event.preventDefault();
//   final url = 'http://localhost:4040/user/';
//   var res = await http.post(url,
//       body: json.encode({
//         'name': newName,
//       }),
//       headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
}
