import 'dart:io';

import 'package:shelf_router/shelf_router.dart';
import 'package:standalone_server/server.dart';

class DashApi {
  Router get router {
    final router = Router();
    router.get('/', (Request request) {
      final dashboardFile = File('./public/dashboard.html').readAsStringSync();
      return Response.ok(dashboardFile, headers: {'content-type': 'text/html'});
    });
    // final handler =
    //     Pipeline().addMiddleware(checkAuthorisation()).addHandler(router);
    return router;
  }
}
