import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<int> justAudioCache() async {
  final path = await getApplicationCacheDirectory();
  String cachePath = join(path.path, "just_audio_cache", "remote");
  int size = await getCacheSize(Directory(cachePath));
  return size;
}

Future<int> getCacheSize(Directory cacheDir) async {
  int totalSize = 0;

  if (cacheDir.existsSync()) {
    cacheDir.listSync().forEach((file) {
      if (file is File) {
        totalSize += file.lengthSync();
      }
    });
  }

  return totalSize;
}

String formatBytes(int bytes, [int decimals = 2]) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  int i = (math.log(bytes) / math.log(1024)).floor();
  double size = bytes / math.pow(1024, i);
  return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
}
