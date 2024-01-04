import 'dart:io';

import 'package:camera/camera.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_overlay_new/flutter_camera_overlay.dart';
import 'package:flutter_camera_overlay_new/model.dart';
import 'package:image_crop_plus/image_crop_plus.dart';
import 'package:path_provider/path_provider.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({
    super.key,
  });

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  OverlayFormat format = OverlayFormat.cardID1;

  int tab = 0;

  final cropKey = GlobalKey<CropState>();

  File? _file;

  File? sample;

  File? croppedImg;

  String? img;
  CardOverlay? overlay;

  @override
  void dispose() {
    _file?.delete();
    croppedImg?.delete();
    sample?.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (img == null || img!.isEmpty)
          ? Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: tab,
                onTap: (value) {
                  setState(() {
                    tab = value;
                  });
                  switch (value) {
                    case (0):
                      setState(() {
                        format = OverlayFormat.cardID1;
                      });
                      break;
                    case (1):
                      setState(() {
                        format = OverlayFormat.cardID3;
                      });
                      break;
                    case (2):
                      setState(() {
                        format = OverlayFormat.simID000;
                      });
                      break;
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.credit_card),
                    label: 'Bankcard',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.contact_mail), label: 'US ID'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.sim_card), label: 'Sim'),
                ],
              ),
              backgroundColor: Colors.white,
              body: FutureBuilder<List<CameraDescription>?>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == null) {
                      return const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'No camera found',
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Colors.black),
                          ));
                    }
                    return CameraOverlay(
                        snapshot.data!.first, CardOverlay.byFormat(format),
                        (XFile file) async {
                      DialogBoxes.showLoading();
                      img = await convertXFileToPath(file);
                      setState(() {
                        overlay = CardOverlay.byFormat(format);
                        _file = File(img!);
                      });
                    },
                        info:
                            'Position your ID card within the rectangle and ensure the image is perfectly readable.',
                        label: 'Scanning ID Card');
                  } else {
                    return const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Fetching cameras',
                          textScaleFactor: 1.0,
                          style: TextStyle(color: Colors.black),
                        ));
                  }
                },
              ),
            )
          : Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Crop.file(
                    _file!,
                    key: cropKey,
                    aspectRatio: overlay?.ratio,
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.deepOrange,
                    ),
                    iconSize: 80,
                    onPressed: () {
                      _file?.delete();
                      setState(() {
                        img = null;
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    iconSize: 80,
                    onPressed: () async {
                      DialogBoxes.showLoading();
                      final cropped = await _cropImage(File(img!));
                      setState(() {});
                      if (!context.mounted) return;
                      Navigator.pop(context, cropped);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<String> _cropImage(File image) async {
    final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return '';
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: image,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    croppedImg?.delete();
    croppedImg = file;

    debugPrint('$file');
    return croppedImg!.path;
  }
}

Future<String> convertXFileToPath(XFile xFile) async {
  try {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$tempPath/$fileName.png';

    final File file = File(filePath);
    await file.writeAsBytes(await xFile.readAsBytes());
    return filePath;
  } catch (e) {
    if (kDebugMode) {
      print('Error converting XFile to path: $e');
    }
    return ''; // Handle the error gracefully in your app
  }
}
