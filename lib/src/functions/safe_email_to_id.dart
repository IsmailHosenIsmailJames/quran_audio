import 'dart:convert';
import 'package:al_quran_audio/src/functions/safe_substring.dart';
import 'package:crypto/crypto.dart';

String encodeEmailForId(String email) {
  return safeSubString(md5.convert(utf8.encode(email)).toString(), 36);
}
