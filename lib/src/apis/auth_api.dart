import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shelf_router/shelf_router.dart';
import 'package:standalone_server/server.dart';
import 'package:standalone_server/src/apis/validators/input_validator.dart';
import 'package:standalone_server/src/models/user.dart';

class AuthApi with InputValidator {
  String secret;
  AuthApi(this.secret);

  File jsonFile;
  bool fileExists = false;
  Router get router {
    final router = Router();
    // Show login page on client side
    router.get('/login', (Request request) async {
      final loginFile = File('./public/login.html').readAsStringSync();
      return Response.ok(loginFile, headers: {'content-type': 'text/html'});
    });

    // POST request to login user
    router.post('/login', handleLogin);

     // Show register page on client side
    router.get('/register', (Request request) async {
      final registerFile = File('./public/register.html').readAsStringSync();
      return Response.ok(registerFile, headers: {'content-type': 'text/html'});
    });

// POST request to register user
    router.post('/register', handleRegister);

// POST request to signout user
    router.post('/logout', (Request req) async {
      if (req.context['authDetails'] == null) {
        Response.forbidden(
            json.encode({
              'errors': [
                {'msg': 'Missing Authorization'}
              ]
            }),
            headers: {'content-type': 'application/json'});
      }
      return Response.ok('Successfully logged out');
    });
    return router;
  }

  Future<Response> handleRegister(Request request) async {
    final payload = await request.readAsString();
    final userInfo = json.decode(payload);
    var uuid = await http.get('https://www.uuidgenerator.net/api/version4');
    var user = User(
        uuid: uuid.body,
        name: userInfo['name'],
        email: userInfo['email'],
        password: userInfo['password']);
    var errors = [];

    // Enusure all inputs are in valid format
    var isBadRequest = checkValidation(
        name: user.name,
        email: user.email,
        pass: user.password,
        errors: errors,
        authState: 'REGISTER');

    if (isBadRequest) {
      return Response(400,
          body: json.encode({'errors': errors}),
          headers: {'content-type': 'application/json'});
    }
    // Ensure user has already not registered
    try {
      var dir = Directory('database');
      jsonFile = File(dir.path + '/users.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && findOne(jsonFile, user.email) != null) {
        return Response(400,
            body: json.encode({
              'errors': [
                {'msg': 'User already exists.'}
              ]
            }),
            headers: {'content-type': 'application/json'});
      }
      //create hashed password
      var salt = generateSalt();
      var hashedPassword = hashPassword(user.password, salt);
      writeToFile({
        'uuid': user.uuid,
        'email': user.email,
        'name': user.name,
        'password': hashedPassword,
        'salt': salt,
        'createdAt': user.created
      });
      final userId = user.uuid;
      // Generate JWT Token
      final token = generateJWT(userId, 'http://localhost', secret);
      return Response.ok(json.encode({'token': token}), headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.authorizationHeader: 'Bearer $token'
      });
    } catch (e) {
      print(e);
      return Response(500,
          body: json.encode({
            'errors': [
              {'msg': 'Something went wrong. Try Again.'},
            ]
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  Future<Response> handleLogin(Request request) async {
    final payload = await request.readAsString();
    final userInfo = json.decode(payload);
    var user = User(email: userInfo['email'], password: userInfo['password']);
    var errors = [];
  // Enusure all inputs are in valid format
    var isBadRequest = checkValidation(
        email: user.email,
        pass: user.password,
        errors: errors,
        authState: 'LOGIN');
    if (isBadRequest) {
      return Response(400,
          body: json.encode({'errors': errors}),
          headers: {'content-type': 'application/json'});
    }
    try {
      // Ensure user is already registered
      var dir = Directory('database');
      jsonFile = File(dir.path + '/users.json');
      fileExists = jsonFile.existsSync();
      var persistedUser = findOne(jsonFile, user.email);
      if (!fileExists || (fileExists && persistedUser == null)) {
        return Response.forbidden(
            json.encode({
              'errors': [
                {'msg': 'User is not registered.'}
              ]
            }),
            headers: {'content-type': 'application/json'});
      }
      //Verifying password
      var isCorrect = persistedUser['password'] ==
          hashPassword(user.password, persistedUser['salt']);
      if (!isCorrect) {
        return Response.forbidden(
            json.encode({
              'errors': [
                {'msg': 'The password is not correct.'}
              ]
            }),
            headers: {'content-type': 'application/json'});
      }
      final userId = persistedUser['uuid'];
      final token = generateJWT(userId, 'http://localhost', secret);

      return Response.ok(json.encode({'token': token}), headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.authorizationHeader: 'Bearer $token',
      });
    } catch (e) {
      print(e);
      return Response(500,
          body: json.encode({
            'errors': [
              {'msg': 'Something went wrong. Try Again.'},
            ]
          }),
          headers: {'content-type': 'application/json'});
    }
  }

  // create users,json file
  void createFile() {
    var dir = Directory('database');
    var file = File(dir.path + '/users.json');
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode({'users': []}));
    jsonFile = file;
  }

  //add new registered user to database
  void writeToFile(Map<String, String> content) {
    if (!fileExists) {
      createFile();
    }
    var jsonFileContent = json.decode(jsonFile.readAsStringSync());
    var usersList = jsonFileContent['users'];
    usersList.add(content);
    jsonFileContent = {'users': usersList};
    jsonFile.writeAsStringSync(json.encode(jsonFileContent));
  }

  // check if the inputs are valid or not
  bool checkValidation(
      {String name, String email, String pass, var errors, String authState}) {
    var isBadRequest = false;
    if (authState == 'LOGIN') {
      if (!emailValidator.isValid(email)) {
        isBadRequest = true;
        errors.add({'msg': emailError});
      }
      if (!passValidator.isValid(pass)) {
        isBadRequest = true;
        errors.add({'msg': passError});
      }
    } else {
      if (!nonEmptyTextValidator.isValid(name)) {
        isBadRequest = true;
        errors.add({'msg': emptyname});
      }
      if (!emailValidator.isValid(email)) {
        isBadRequest = true;
        errors.add({'msg': emailError});
      }
      if (!passValidator.isValid(pass)) {
        isBadRequest = true;
        errors.add({'msg': passError});
      }
    }
    return isBadRequest;
  }

}
