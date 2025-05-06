import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrUtils {
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      if (context.mounted) {
        _showSnackBar(context, "Camera permission is required", Colors.red);
      }
    }
    return status.isGranted;
  }

  static Future<String?> scanQRFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image == null) return null;

      final MobileScannerController controller = MobileScannerController();
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);

      await controller.dispose();

      if (capture != null && capture.barcodes.isNotEmpty) {
        return capture.barcodes.first.rawValue;
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, "Error: $e", Colors.red);
      }
      return null;
    }
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
