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
    //fetch user info in JSON
    router.get('/', fetchUserInfo);
    // update the name of user
    router.patch('/', handleUpdate);
    //delete user's account
    router.delete('/', handleDelete);

    final handler =
        Pipeline().addMiddleware(checkAuthorization()).addHandler(router);

    return handler;
  }

  //connect to local JSON database under database/users.json
  void init() {
    var dir = Directory('database');
    jsonFile = File(dir.path + '/users.json');
    jsonFileContent = json.decode(jsonFile.readAsStringSync());
    usersList = jsonFileContent['users'];
  }

  // returns a response with User Info in body
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

  // Updates the name of user(Edits username if requested)
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

  // Deletes user account
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
