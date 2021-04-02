// All of the application routes are specified in the file

import 'package:shelf_router/shelf_router.dart';
import 'package:standalone_server/server.dart';
import 'package:standalone_server/src/apis/auth_api.dart';
import 'package:standalone_server/src/apis/dash_api.dart';
import 'package:standalone_server/src/apis/static_assets_api.dart';
import 'package:standalone_server/src/apis/validate_token.dart';
import 'package:standalone_server/src/configs/dot_env.dart';

Router routes() {
  var mySecret = Env.secretKey;
  var app = Router();

  app.mount('/assets/', StaticAssetsApi('public').router);

  app.mount('/auth/', AuthApi(mySecret).router);

  app.mount('/validate/', ValidateApi().router);

  app.mount('/dashboard/', DashApi().router);

  app.get('/', fallback('./public/landing.html'));

  return app;
}