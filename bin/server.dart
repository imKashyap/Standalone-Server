// This file refers to the main server
// Server is automatically reloaded using nodemon when the source code changes

import 'package:standalone_server/server.dart';

const _hostname = 'localhost';
const _port = 4040;
Future<void> main(List<String> args) async {
  final app = routes();
  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth('myJWTSecret'))
      .addHandler(app);
  var server = await serve(handler, _hostname, _port);
  print('Serving at http://${server.address.host}:${server.port}');
}
