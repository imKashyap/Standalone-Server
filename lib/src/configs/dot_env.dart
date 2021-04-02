import 'package:envify/envify.dart';

part 'dot_env.g.dart';

@Envify()
abstract class Env {
  static const secretKey = _Env.secretKey;
}
