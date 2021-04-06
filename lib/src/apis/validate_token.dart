import 'dart:io';
import 'package:shelf_router/shelf_router.dart';
import 'package:standalone_server/server.dart';

class ValidateApi {
  Handler get router {
    final router = Router();
    router.get('/', (Request request) {
      //final dashboardFile = File('./public/dashboard.html').readAsStringSync();
      return Response.ok(
        'valid',
      );
    });
    final handler =
        Pipeline().addMiddleware(checkAuthorization()).addHandler(router);
    return handler;
  }
}
