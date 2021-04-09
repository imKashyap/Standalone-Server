import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;

void main(List<String> args) {
  querySelector('.btn').onClick.listen(submitHandler);
}

//handle login user request on frontend
// returns a JWT token on successful login
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
  if (response.statusCode == 200) {
    var token = json.decode(response.body)['token'];
    event.preventDefault();
    document.cookie = 'token=$token; path=/';
    document.window.location.href = 'http://localhost:4040/dashboard/';
  } else {
    var errors = json.decode(response.body)['errors'];
    var errMsg;
    if (errors.length > 1) {
      errMsg = 'User credentials are missing.';
    } else {
      errMsg = errors[0]['msg'];
    }
    document.querySelector('.alert-title').innerText = errMsg;
    document.querySelector('.alert').style.display = 'flex';
  }
}
