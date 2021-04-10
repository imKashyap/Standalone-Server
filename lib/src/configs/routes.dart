// All of the application routes are specified in the file

import 'package:shelf_router/shelf_router.dart';
import 'package:standalone_server/server.dart';
import 'package:standalone_server/src/apis/auth_api.dart';
import 'package:standalone_server/src/apis/dash_api.dart';
import 'package:standalone_server/src/apis/static_assets_api.dart';
import 'package:standalone_server/src/apis/user_api.dart';
import 'package:standalone_server/src/apis/file_api.dart';

Router routes() {
  var mySecret = 'myJWTSecret';
  var app = Router();

// serve static files from disk
  app.mount('/assets/', StaticAssetsApi('public').router);

//authenticate the user(login, register, logout) 
  app.mount('/auth/', AuthApi(mySecret).router);

//show dashboard page on successful authentication
  app.mount('/dashboard/', DashApi().router);

//api related to user are handled here like fetching user info, deleting account, edit name
  app.mount('/user/', UserApi().router);

  app.mount('/file/', FileApi().router);

// fallback to landing page if routes are invalid 
  app.all('/<name|.*>', fallback('./public/landing.html'));

  return app;
}
