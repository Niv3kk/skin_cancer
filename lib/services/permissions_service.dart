import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> requestCameraAndGallery() async {
    final cameraStatus = await Permission.camera.request();
    final galleryStatus = await Permission.photos.request();

    if (cameraStatus.isGranted && galleryStatus.isGranted) {
      return true;
    }

    if (cameraStatus.isPermanentlyDenied ||
        galleryStatus.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}
