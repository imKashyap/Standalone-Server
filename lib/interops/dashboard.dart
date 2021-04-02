import 'dart:html';

void main(List<String> args) {
  var cookieValue = document.cookie
      .split('; ')
      .firstWhere((row) => row.startsWith('token='), orElse: () => null);
  if (cookieValue == null) document.window.location.href = '/';

   else window.console.log(cookieValue.split('=')[1]);
}
