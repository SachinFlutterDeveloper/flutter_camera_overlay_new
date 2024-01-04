import 'dart:io';

import 'package:digihealthcardapp/models/custom_border.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/components/round_button.dart';
import 'package:digihealthcardapp/views/subscription/view_invoice.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscribedPackage extends StatelessWidget {
  final String pkgName;
  final String pkgMode;
  final String pkgEnd;
  final String pkgStart;
  final String pkgMessage;
  final String pkgType;
  final String pkgAmount;
  const SubscribedPackage(
      {super.key,
      required this.pkgName,
      required this.pkgMode,
      required this.pkgEnd,
      required this.pkgStart,
      required this.pkgMessage,
      required this.pkgType,
      required this.pkgAmount});

  @override
  Widget build(BuildContext context) {
    var strtD = '';
    var endD = '';
    if (pkgStart != 'null' || pkgStart.isNotEmpty) {
      var dateFormat = DateFormat('yy/MM/dd');
      strtD = dateFormat.format(DateTime.parse(pkgStart));
      endD = dateFormat.format(DateTime.parse(pkgEnd));
    }
    if (kDebugMode) {
      print('$strtD $endD');
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .005,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Image(
              image: (Theme.of(context).brightness == Brightness.light)
                  ? const AssetImage('Assets/logo.png')
                  : const AssetImage('Assets/white_log.png')),
        ),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .03,
        ),
        Card(
          shape: const CustomShapeBorder(radius: 10),
          elevation: 5,
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your current Plan',
                      textScaleFactor: 1.0,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Package Name',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text(pkgName,
                                      textScaleFactor: 1.0,
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Subscription Start Date',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text(strtD,
                                      textScaleFactor: 1.0,
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Package Mode',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text(pkgMode,
                                      textScaleFactor: 1.0,
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Package Type',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text(pkgType,
                                      textScaleFactor: 1.0,
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Subscription End Date',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text(endD,
                                      textScaleFactor: 1.0,
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Package Amount',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text('US\$ $pkgAmount',
                                      textScaleFactor: 1.0,
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                          ],
                        ),
                      ],
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Message',
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 14),
                          ),
                          Text(pkgMessage,
                              textScaleFactor: 1.0,
                              style: const TextStyle(fontSize: 16)),
                        ]),
                  ],
                ),
              ],
            ),
          ),
        ),
        RoundButton(
            title: 'View Invoices',
            onPress: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const InvoicesPage()));
            }),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .02,
        ),
        RoundButtonBlack(
            title: (pkgType.toLowerCase() == 'code')
                ? 'Cancel Subscription'
                : 'Manage Subscription',
            onPress: () async {
              if (Platform.isIOS) {
                var url = "https://apps.apple.com/account/subscriptions";
                final uri = Uri.parse(url);
                if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
                  throw Exception('can not load $url');
                }
                //DialogBoxes.showConfirmCancelSubscription(context);
              } else if (pkgType.toLowerCase() == 'code') {
                DialogBoxes.showConfirmCancelSubscription(context);
              } else {
                var url = "https://play.google.com/store/account/subscriptions";
                final uri = Uri.parse(url);
                if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
                  throw Exception('can not load $url');
                }
              }
            })
      ],
    );
  }
}
