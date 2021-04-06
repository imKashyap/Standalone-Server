import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:http/http.dart' as http;

void main(List<String> args) {
  querySelector('.btn-register').onClick.listen(submitHandler);
}

void submitHandler(MouseEvent event) async {
  var name = (querySelector('#name-input') as InputElement).value;
  var email = (querySelector('#email-input') as InputElement).value;
  var pass = (querySelector('#pass-input') as InputElement).value;
  event.preventDefault();
  final url = 'http://localhost:4040/auth/register';
  final response = await http.post(
    url,
    body: json.encode({
      'name': name,
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
