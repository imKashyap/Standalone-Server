import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

// handle CORS
Middleware handleCors() {
  var corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  };

  return createMiddleware(requestHandler: (Request request) {
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: corsHeaders);
    }
    return null;
  }, responseHandler: (Response response) {
    return response.change(headers: corsHeaders);
  });
}

// generate salt for password
String generateSalt() {
  final rand = Random.secure();
  var saltBytes = List<int>.generate(32, (index) => rand.nextInt(256));
  return base64.encode(saltBytes);
}

//hash password
String hashPassword(String password, String salt) {
  var key = utf8.encode(password);
  var bytes = utf8.encode(salt);

  var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
  var digest = hmacSha256.convert(bytes);
  return digest.toString();
}

// generate JWT Token
String generateJWT(String subject, String issuer, String secret) {
  final jwt = JWT({
    'iat': DateTime.now().millisecondsSinceEpoch,
  }, subject: subject, issuer: issuer);
  return jwt.sign(SecretKey(secret), expiresIn: Duration(days: 5));
}

// verify JWT Token
dynamic verifyJWT(String token, String secret) {
  try {
    final jwt = JWT.verify(token, SecretKey(secret));
    return jwt;
  } on JWTExpiredError {
    print('jwt expired');
  } on JWTError catch (ex) {
    print(ex.message.toString() + ' error'); // ex: invalid signature
  }
}


// check if JTW TOken is provided for requests
Middleware handleAuth(String secret) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      var token, jwt;

      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        token = authHeader.substring(7);
        jwt = verifyJWT(token, secret);
      }
      final updatedRequest = request.change(context: {
        'authDetails': jwt,
      });
      return await innerHandler(updatedRequest);
    };
  };
}

// check if it is a authorized request
Middleware checkAuthorization() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.context['authDetails'] == null) {
        return Response.forbidden(json.encode({'msg': 'Missing Authorization'}),
            headers: {'content-type': 'application/json'});
      }
      return null;
    },
  );
}

// fallback to landing page incase requested route is incorect
Handler fallback(String indexPath) => (Request request) {
      final indexFile = File(indexPath).readAsStringSync();
      return Response.ok(indexFile, headers: {'content-type': 'text/html'});
    };


  // look for a user in the json database under database/users.json
  dynamic findOne(File file, String email) {
    var jsonFileContent = json.decode(file.readAsStringSync());
    var usersList = jsonFileContent['users'];
    return usersList.firstWhere((user) => user['email'] == email,
        orElse: () => null);
  }