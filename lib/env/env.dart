// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'webGoogleClientId', obfuscate: true)
  static String webGoogleClientId = _Env.webGoogleClientId;
}
