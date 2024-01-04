import 'package:device_info_plus/device_info_plus.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/viewModel/home_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({Key? key}) : super(key: key);

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  @override
  Widget build(BuildContext context) {
    final permissions = Provider.of<HomeModel>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
            child: Column(
              children: [
                const Text(
                  'Camera:',
                  textScaleFactor: 1,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const Text(
                  "The application needs access to your device's camera to scan OR take a picture of your health / ID card. In order to save/store your health / ID card, both front and back pictures of your card are required. We store your information securely on the AWS S3 servers and only you can access/view your card's images and information.",
                  textAlign: TextAlign.justify,
                  textScaleFactor: 1.0,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Storage:',
                  textScaleFactor: 1,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "The application needs permission to access your device storage files in case if you upload a picture of your health / ID card from your device pictures gallery. In order to save store your health ID card, both front and back pictures of your card are required. We store your information securely on the AWS S3 servers and only you can access view your card's images and information. When you add your test reports to the application and you want to select your report pictures from the gallery, this permission is required. The application will write images taken from the camera to your device storage.",
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.primaryColor),
                      onPressed: () async {
                        // Request camera and storage permissions
                        final androidInfo =
                            await DeviceInfoPlugin().androidInfo;
                        final Map<Permission, PermissionStatus> statuses;

                        if (androidInfo.version.sdkInt <= 32) {
                          statuses = await [
                            Permission.storage,
                            Permission.camera
                          ].request();
                        } else {
                          statuses = await [
                            Permission.photos,
                            Permission.camera,
                          ].request();
                        }
                        // Check if all permissions are granted
                        bool allGranted = statuses.values.every(
                          (permissionStatus) =>
                              permissionStatus == PermissionStatus.granted,
                        );
                        if (!context.mounted) {
                          return;
                        }
                        if (allGranted) {
                          permissions.setPermission(allGranted);
                          Navigator.pop(context);
                        } else {
                          permissions.setPermission(allGranted);
                          // Display message to user that the requested permissions are necessary
                        }
                      },
                      child: const Text(
                        'Review & Allow Permissions',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
