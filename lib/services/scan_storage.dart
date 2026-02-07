import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ScanStorage {
  static Future<String> copyOriginalToAppDir(String originalPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final scansDir = Directory(p.join(dir.path, 'scans'));
    if (!await scansDir.exists()) await scansDir.create(recursive: true);

    final ext = p.extension(originalPath).isNotEmpty ? p.extension(originalPath) : '.jpg';
    final filename = 'scan_${DateTime.now().millisecondsSinceEpoch}$ext';
    final newPath = p.join(scansDir.path, filename);

    await File(originalPath).copy(newPath);
    return newPath;
  }

  static Future<Uint8List> makeThumbnailBytes(String imagePath,
      {int size = 160, int quality = 75}) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('No se pudo decodificar la imagen para thumbnail.');

    final oriented = img.bakeOrientation(decoded);
    final thumb = img.copyResize(oriented, width: size, height: size);

    final jpg = img.encodeJpg(thumb, quality: quality);
    return Uint8List.fromList(jpg);
  }
}
