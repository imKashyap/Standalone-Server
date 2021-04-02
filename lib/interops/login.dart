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
  final url = 'http://localhost:4040/auth/login';
  final response = await http.post(
    url,
    body: json.encode({
      'email': email,
      'password': pass,
    }),
  );
  event.preventDefault();
  var token = json.decode(response.body)['token'];
  window.console.log(token);
  final validate = 'http://localhost:4040/validate/';
  var res = await http.get(validate,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
  if (res.statusCode == 200) {
    window.console.log('yes');
    document.cookie = 'token=$token';
    document.window.location.href = 'http://localhost:4040/dashboard/';
  } else {
    window.console.log('no');
    document.window.location.href = '/';
  }
}
