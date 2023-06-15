
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_overlay_new/flutter_camera_overlay.dart';
import 'package:flutter_camera_overlay_new/model.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ExampleCameraOverlay(),
  );
}

class ExampleCameraOverlay extends StatefulWidget {
  @override
  State<ExampleCameraOverlay> createState() => _ExampleCameraOverlayState();
}

class _ExampleCameraOverlayState extends State<ExampleCameraOverlay> {
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    initializeCameras();
  }

  Future<void> initializeCameras() async {
    // await Permission.camera.request();
    cameras = await availableCameras();
    setState(() {}); // Refresh the widget tree after obtaining cameras
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cameras.isEmpty
          ? const Center(
              child: Text(
                'No camera found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : CameraOverlay(
              cameras.first,
              CardOverlay.byFormat(OverlayFormat.cardID2),
              loadingWidget: Container(
                color: Colors.white,
              ),
              (XFile file) {},
              info: 'Position your business ID card within the rectangle and ensure the image is perfectly readable.',
              label: 'Scanning Business Card',
            ),
    );
  }
}
