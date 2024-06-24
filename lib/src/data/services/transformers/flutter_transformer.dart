import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio has already implemented a [BackgroundTransformer ], and as the default
/// [Transformer]. If you want to custom the transformation of
/// request/response data, you can provide a [Transformer] by your self, and
/// replace the [BackgroundTransformer ] by setting the [dio.Transformer].
///
/// [FlutterTransformer] is especially for flutter, by which the json decoding
/// will be in background with [compute] function.
/// FlutterTransformer
class FlutterTransformer extends BackgroundTransformer {
  FlutterTransformer() : super();
}

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

/* _parseJson(String text) {
  return compute(_parseAndDecode, text);
} */
