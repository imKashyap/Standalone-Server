import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;

class FileApi {
  Router get router {
    final router = Router();
// serves static files to client side
    router.get('/<file|.*>', (Request req) async {
      List temp = req.requestedUri.path.split('/');
      String userId = temp[2];
      print(userId);
      try {
        var dir = Directory('database');
        var jsonFile = File(dir.path + '/users.json');
        var jsonFileContent = json.decode(jsonFile.readAsStringSync());
        List usersList = jsonFileContent['users'];
        var index = usersList.indexWhere((user) => user['uuid'] == userId);
        if (index == -1) {
          return Response.notFound('not found');
        }
        final assetPath = p.join('resources', temp[3]);
        print(assetPath);
        return await createFileHandler(assetPath, url: req.url.toFilePath())(
            req);
      } catch (e) {
        return Response.notFound('not found');
      }
    });

    return router;
  }
}
