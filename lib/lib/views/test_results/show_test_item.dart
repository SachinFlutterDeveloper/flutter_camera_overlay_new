import 'package:cached_network_image/cached_network_image.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowTestItem extends StatelessWidget {
  final dynamic testItem;
  final AsyncCallback removeTest;

  const ShowTestItem({super.key, this.testItem, required this.removeTest});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned(
                right: 10,
                top: 10,
                child: IconButton(
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('test_id', testItem['id']);
                    if (!context.mounted) {
                      return;
                    }
                    DialogBoxes.showConfirmDialogDel(context, () {
                      Navigator.of(context).pop();
                      removeTest();
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
                  SizedBox(
                    height: height * .020,
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
                    Text(testItem['dateof'],
                        textScaleFactor: 1.0,
                        style: const TextStyle(fontSize: 16)),
                  ]),
                  SizedBox(
                    height: height * .020,
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
                    Text(testItem['name'],
                        textScaleFactor: 1.0,
                        style: const TextStyle(fontSize: 16)),
                  ]),
                  SizedBox(
                    height: height * .020,
                  ),
                  Row(children: [
                    Text(
                      'Relation',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    const Text(':',
                        textScaleFactor: 1.0, style: TextStyle(fontSize: 16)),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(testItem['relation'],
                        textScaleFactor: 1.0,
                        style: const TextStyle(fontSize: 16)),
                  ]),
                  SizedBox(
                    height: height * .020,
                  ),
                  Row(children: [
                    Text(
                      'Result',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(width: 27),
                    const Text(':',
                        textScaleFactor: 1.0, style: TextStyle(fontSize: 16)),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(testItem['result'],
                        textScaleFactor: 1.0,
                        style: const TextStyle(fontSize: 16)),
                  ]),
                  SizedBox(
                    height: height * .020,
                  ),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: testItem['frontpic'],
                          progressIndicatorBuilder: (context, url, progress) =>
                              Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Loading',
                                    textScaleFactor: 1.0,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CircularProgressIndicator(
                                    value: progress.progress,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          errorWidget: (context, error, stackTrace) {
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .020,
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
