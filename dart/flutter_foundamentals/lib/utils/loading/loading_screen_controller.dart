import 'package:flutter/foundation.dart';

typedef CloseLoadingScreen = void Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreen close;
  final UpdateLoadingScreen updated;

  const LoadingScreenController({
    required this.close,
    required this.updated,
  });
}
