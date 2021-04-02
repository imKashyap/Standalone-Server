import 'dart:convert';
import 'dart:html';
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
  print(json.decode(response.body)['token']);
  window.console.log(json.decode(response.body)['token']);
}