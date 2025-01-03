String safeSubString(String str, int len) {
  int lenOfStr = str.length;
  if (lenOfStr > len) {
    return "${str.substring(0, len)}...";
  } else {
    return str;
  }
}
