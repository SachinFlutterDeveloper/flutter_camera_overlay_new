import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/views/print_and_preview/preview_webview.dart.dart';
import 'package:digihealthcardapp/views/print_and_preview/print_preview_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowCardItem extends StatelessWidget {
  final dynamic cardItem;
  final AsyncCallback removeCard;
  final String printUrl;
  const ShowCardItem(
      {super.key,
      this.cardItem,
      required this.removeCard,
      required this.printUrl});

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
                right: 5,
                top: 10,
                child: IconButton(
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('Card_id', cardItem['id']);
                    if (!context.mounted) return;
                    DialogBoxes.showConfirmDialogDel(context, () {
                      removeCard();
                      Navigator.pop(context);
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
                    const SizedBox(width: 40),
                    const Text(':',
                        textScaleFactor: 1.0, style: TextStyle(fontSize: 16)),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(cardItem['date'],
                        textScaleFactor: 1.0,
                        style: const TextStyle(fontSize: 16)),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(children: [
                    Text(
                      'Name',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(width: 30),
                    const Text(':',
                        textScaleFactor: 1.0, style: TextStyle(fontSize: 16)),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(cardItem['name'],
                        textScaleFactor: 1.0,
                        style: const TextStyle(fontSize: 16)),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(children: [
                    Text(
                      'Type of\nCard',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(width: 20),
                    const Text(':',
                        textScaleFactor: 1.0, style: TextStyle(fontSize: 16)),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(cardItem['card_type'],
                        textScaleFactor: 1.0,
                        style: const TextStyle(fontSize: 16)),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(children: [
                    Text(
                      'Relation',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    const Text(':',
                        textScaleFactor: 1.0, style: TextStyle(fontSize: 16)),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(cardItem['relation'],
                        textScaleFactor: 1.0,
                        style: const TextStyle(fontSize: 16)),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('Card_id', cardItem['id']);
                          if (!context.mounted) return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrintScreen(
                                        cardObject: cardItem,
                                        appUrl: printUrl,
                                      )));
                        },
                        child: Container(
                          width: width * .4,
                          height: height * .15,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(cardItem['front_pic']))),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('Card_id', cardItem['id']);
                          if (!context.mounted) return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrintScreen(
                                        cardObject: cardItem,
                                        appUrl: printUrl,
                                      )));
                        },
                        child: Container(
                          width: width * .4,
                          height: height * .15,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(cardItem['back_pic']))),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('Card_id', cardItem['id']);
                          if (!context.mounted) return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrintScreen(
                                        cardObject: cardItem,
                                        appUrl: printUrl,
                                      )));
                        },
                        child: Ink(
                          width: width * .4,
                          height: height * .05,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('Print',
                                textScaleFactor: 1.0,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PreviewCard(
                                previewUrl: cardItem['code_url'],
                              ),
                            ),
                          );
                        },
                        child: Ink(
                          width: width * .4,
                          height: height * .05,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                              child: Text(
                            'Preview',
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          )),
                        ),
                      ),
                    ],
                  ),
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
