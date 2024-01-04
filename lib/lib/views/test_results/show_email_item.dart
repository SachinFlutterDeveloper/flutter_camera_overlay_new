import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowEmailItem extends StatelessWidget {
  final dynamic emailItem;
  final AsyncCallback removeTestEmail;
  const ShowEmailItem(
      {super.key, this.emailItem, required this.removeTestEmail});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('test_id', emailItem['id']);
                    if (!context.mounted) {
                      return;
                    }
                    DialogBoxes.showConfirmDialogDel(context, () async {
                      Navigator.pop(context);
                      removeTestEmail;
                    });
                  },
                  iconSize: 30,
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                )),
            Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(children: [
                    Text(
                      'Date',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(width: 29),
                    const Text(':',
                        textScaleFactor: 1.0, style: TextStyle(fontSize: 16)),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(emailItem['dateof'],
                        textScaleFactor: 1.0,
                        style: const TextStyle(fontSize: 16)),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(children: [
                    Text(
                      'Info',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(width: 36),
                    const Text(':',
                        textScaleFactor: 1.0, style: TextStyle(fontSize: 16)),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                        'This is your test report sent to the\n email testresults@digihealthcard.com',
                        textScaleFactor: 1.0,
                        style: TextStyle(fontSize: 12)),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(children: [
                    Text(
                      'Report',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(width: 15),
                    const Text(':',
                        textScaleFactor: 1.0, style: TextStyle(fontSize: 16)),
                    const SizedBox(
                      width: 15,
                    ),
                    InkWell(
                      onTap: () async {
                        var url = emailItem['bodyhtml'];
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          throw 'Cannot load';
                        }
                      },
                      child: Ink(
                        width: width * .25,
                        height: height * .05,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('View Detail',
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300)),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
