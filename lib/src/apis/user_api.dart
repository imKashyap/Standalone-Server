import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../server.dart';

class UserApi {
  File jsonFile;
  Map jsonFileContent;
  List usersList;
  Handler get router {
    final router = Router();
    router.get('/', fetchUserInfo);
    router.patch('/', handleUpdate);
    router.delete('/', handleDelete);

    final handler =
        Pipeline().addMiddleware(checkAuthorization()).addHandler(router);

    return handler;
  }

  void init() {
    var dir = Directory('database');
    jsonFile = File(dir.path + '/users.json');
    jsonFileContent = json.decode(jsonFile.readAsStringSync());
    usersList = jsonFileContent['users'];
  }

  Future<Response> fetchUserInfo(Request request) async {
    init();
    final authDetails = request.context['authDetails'] as JWT;
    var index =
        usersList.indexWhere((user) => user['uuid'] == authDetails.subject);
    if (index > -1) {
      var user = usersList[index];
      return Response.ok(json.encode(user),
          headers: {'content-type': 'application/json'});
    }
    return Response.notFound('User not found');
  }

  Future<Response> handleUpdate(Request request) async {
    init();
    final payload = await request.readAsString();
    final name = json.decode(payload)['name'];
    final authDetails = request.context['authDetails'] as JWT;
    var index =
        usersList.indexWhere((user) => user['uuid'] == authDetails.subject);
    if (index > -1) {
      var user = usersList[index];
      var updatedUser = {
        'uuid': user['uuid'],
        'email': user['email'],
        'name': name,
        'password': user['password'],
        'salt': user['salt'],
        'createdAt': user['createdAt']
      };
      usersList[index] = updatedUser;
      jsonFileContent = {'users': usersList};
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      return Response.ok('User updated');
    }
    return Response.notFound('User not found');
  }

  Future<Response> handleDelete(Request request) async {
    init();
    final authDetails = request.context['authDetails'] as JWT;
    usersList.removeWhere((user) => user['uuid'] == authDetails.subject);
    jsonFileContent = {'users': usersList};
    jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    return Response.ok(json.encode({'msg': 'user deleted'}),
        headers: {'content-type': 'application/json'});
  }
}
