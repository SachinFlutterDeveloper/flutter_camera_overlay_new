import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/viewModel/services/camera_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as pPath;
import 'package:permission_handler/permission_handler.dart';

class CameraHelper extends ChangeNotifier {
  static Future<File> compressedImage(String path) async {
    File img = File(path);

    final data = await img.readAsBytes();
    final sizeInKbBefore = data.length / 1024;
    if (kDebugMode) {
      print('Before Compress $sizeInKbBefore kb');
    }
    var result = await FlutterImageCompress.compressWithFile(img.absolute.path,
        quality: 40, autoCorrectionAngle: true);
    if (kDebugMode) {
      print(img.lengthSync());
      print(result?.length);
    }

    final directory = await pPath.getTemporaryDirectory();
    final filePath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.bin';
    final file = File(filePath);
    await file.writeAsBytes(Uint8List.fromList(result!));

    final beforeData = await file.readAsBytes();

    final sizeInKbAfter = beforeData.length / 1024;
    if (kDebugMode) {
      print('After Compress $sizeInKbAfter kb');
    }
    return file;
  }

  static Future<File?> cropImage(File? imageFile) async {
    DialogBoxes.showLoading();
    final data = await File(imageFile!.path).readAsBytes();
    final sizeInKbBefore = data.length / 1024;
    debugPrint('Before Cropped $sizeInKbBefore');
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      // compressQuality: 0,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Edit Profile Image',
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: AppColors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Edit Profile Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );
    if (croppedFile == null) return null;
    final afterData = await File(croppedFile.path).readAsBytes();
    final sizeInKbAfter = afterData.length / 1024;
    debugPrint('After Cropped $sizeInKbAfter');
    return File(croppedFile.path);
  }

  final ImagePicker _picker = ImagePicker();

  File? _frontImage;

  File? get frontImage => _frontImage;

  File? _backImage;

  File? get backImage => _backImage;

  Future<File> saveFileTemp(String imagePath) async {
    final directory = await pPath.getTemporaryDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');
    return File(imagePath).copy(image.path);
  }

  Future getFrontImage(BuildContext context, ImageSource source) async {
    var status = await Permission.photos.status;
    if (Platform.isIOS) {
      status = await Permission.photos.status;
    } else {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
      } else {
        status = await Permission.photos.status;
      }
    }
    if (status.isDenied) {
      // Request permission
      await Permission.photos.request();
      // Check if permission is granted after the request
      status = await Permission.photos.status;
    }
    try {
      if (status.isGranted || status.isLimited) {
        final imageFront = await _picker.pickImage(source: source);
        if (imageFront != null) {
          final imgFront = File(imageFront.path);
          File compressed = await compressedImage(imgFront.path.toString());
          DialogBoxes.showLoading();
          //final imageFrontTemp = File(compressed.path);
          _frontImage = compressed;
          notifyListeners();
        } else {
          if (kDebugMode) {
            print('no image is picked');
          }
        }
      } else if (status.isDenied || status.isPermanentlyDenied) {
        // Permission denied
        if (kDebugMode) {
          print("Permission denied $status");
        }
        if (!context.mounted) return;
        // Display a SnackBar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photo access is required to pick an image.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                // Open app settings so the user can grant permission
                openAppSettings();
              },
            ),
          ),
        );
      }
    } on PlatformException catch (e) {
      // Handle platform-specific exception (iOS in this case)
      if (kDebugMode) {
        print("Error: ${e.message}");
      }
      // Provide user feedback, e.g., show a snackbar or dialog
      // with a message explaining the need for photo access.
    } catch (e) {
      // Handle other exceptions
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  Future<void> onCaptureFront(BuildContext context) async {
    String imageFront;
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // Request permission
      await Permission.camera.request();
      // Check if permission is granted after the request
      status = await Permission.camera.status;
    }
    if (status.isGranted || status.isLimited) {
      try {
        if (!context.mounted) return;
        imageFront = await Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ViewImage()));
        // Call the method to get pictures from selected source
        if (imageFront != null || imageFront.isNotEmpty) {
          final imgFront = File(imageFront);
          File compressed = await compressedImage(imgFront.path.toString());
          DialogBoxes.showLoading();
          // final imageFrontTemp = File(compressed.path);
          _frontImage = compressed;
          notifyListeners();
        }
      } catch (e) {
        // Handle exception here.
        if (kDebugMode) {
          print('no image Picked $e');
        }
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Permission denied
      if (kDebugMode) {
        print("Permission denied");
      }
      if (!context.mounted) return;
      // Display a SnackBar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Camera access is required to scan a card image.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              // Open app settings so the user can grant permission
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  Future getBackImage(BuildContext context, ImageSource source) async {
    var status = await Permission.photos.status;
    if (Platform.isIOS) {
      status = await Permission.photos.status;
    } else {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
      } else {
        status = await Permission.photos.status;
      }
    }
    if (status.isDenied) {
      // Request permission
      await Permission.photos.request();
      // Check if permission is granted after the request
      status = await Permission.photos.status;
    }
    if (status.isGranted || status.isLimited) {
      final imageBack =
          await _picker.pickImage(source: source, imageQuality: 100);
      if (imageBack != null) {
        final imgBack = File(imageBack.path);
        File compressed = await compressedImage(imgBack.path.toString());
        DialogBoxes.showLoading();
        //final imageBackTemp = compressed;
        _backImage = compressed;
        notifyListeners();
      } else {
        if (kDebugMode) {
          print('no image Picked');
        }
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Permission denied
      if (kDebugMode) {
        print("Permission denied $status");
      }
      if (!context.mounted) return;
      // Display a SnackBar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo access is required to pick an image.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              // Open app settings so the user can grant permission
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  Future<void> onScanBack(BuildContext context) async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // Request permission
      await Permission.camera.request();
      // Check if permission is granted after the request
      status = await Permission.camera.status;
    }
    String imageBack;
    if (status.isGranted || status.isLimited) {
      try {
        if (!context.mounted) return;
        // Call the method to get pictures from selected source
        imageBack = await Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ViewImage()));
        if (imageBack != null || imageBack.isNotEmpty) {
          final imgBack = File(imageBack);
          File compressed = await compressedImage(imgBack.path.toString());
          DialogBoxes.showLoading();
          //final imageBackTemp = compressed;
          // Update the pictures list
          _backImage = compressed;
          notifyListeners();
        }
      } catch (e) {
        // Handle exception here.
        if (kDebugMode) {
          print('no image Picked $e');
        }
      }
    } else {
      // Permission denied
      if (kDebugMode) {
        print("Permission denied $status");
      }
      // Request permission
      await Permission.camera.request();
      // Check if permission is granted after the request
      status = await Permission.camera.status;
      if (!context.mounted) return;
      // Display a SnackBar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Camera access is required to scan a card image.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              // Open app settings so the user can grant permission
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  void removeFrontImage() {
    if (_frontImage != null) {
      // Delete the front image file
      File(_frontImage!.path).deleteSync();
      _frontImage = null;
      notifyListeners();
    }
  }

  void removeBackImage() {
    if (_backImage != null) {
      // Delete the back image file
      File(_backImage!.path).deleteSync();
      _backImage = null;
      notifyListeners();
    }
  }
}
