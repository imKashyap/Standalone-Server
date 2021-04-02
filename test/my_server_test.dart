import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  test('It should return a 200 response', () async {
    final response = await http.get('http://localhost:4040');

    expect(response.statusCode, HttpStatus.ok);
  });
}
