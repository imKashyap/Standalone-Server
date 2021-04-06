import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:http/http.dart' as http;

void main(List<String> args) {
  querySelector('.btn').onClick.listen(submitHandler);
}

void submitHandler(MouseEvent event) async {
  var email = (querySelector('#email-input') as InputElement).value;
  var pass = (querySelector('#pass-input') as InputElement).value;
  event.preventDefault();
  final url = 'http://localhost:4040/auth/login';
  final response = await http.post(
    url,
    body: json.encode({
      'email': email,
      'password': pass,
    }),
  );
  var token = json.decode(response.body)['token'];
  event.preventDefault();
  final validate = 'http://localhost:4040/validate/';
  var res = await http.get(validate,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
  event.preventDefault();
  if (res.statusCode == 200) {
    document.cookie = 'token=$token; path=/';
    document.window.location.href = 'http://localhost:4040/dashboard/';
  } else {
    document.window.location.href = '/';
  }
}
