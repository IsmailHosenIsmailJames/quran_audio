import 'dart:convert';
import 'package:crypto/crypto.dart';

String urlToHash(String url) {
  List<int> bytes = utf8.encode(url);
  Digest sha256Hash = sha256.convert(bytes);
  String hexDigest = sha256Hash.toString();
  return hexDigest;
}
