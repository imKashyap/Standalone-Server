import 'dart:html';

void main(List<String> args) {
  // window.console.log(document.cookie);
  // var decodedCookie = Uri.decodeComponent(document.cookie);
  // window.console.log(decodedCookie);
  // var cookieValue = decodedCookie
  //     .split('; ')
  //     .firstWhere((row) => row.startsWith('token='), orElse: () => null);
  var storageValue = window.localStorage.containsKey('token');
  if (!storageValue) {
    document.window.location.href = '/';
  } else {
    window.console.log(window.localStorage['token']);
  }
}
