import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/views/print_and_preview/front_pic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/widgets/appbar_leading.dart';
import '../profile/widgets/material_btn.dart';

class PrintScreen extends StatefulWidget {
  final String appUrl;
  final dynamic cardObject;

  const PrintScreen({Key? key, required this.appUrl, required this.cardObject})
      : super(key: key);

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  String? profileIMG;

  Future<void> fetchImg() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userImg = prefs.getString('image');
    setState(() {
      profileIMG = userImg;
    });
  }

  Future<dynamic> cardFormApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('access_token');

    try {
      var response =
          await http.post(Uri.parse(widget.appUrl), headers: <String, String>{
        'Oauthtoken': 'Bearer $userToken',
      }, body: {
        "id": widget.cardObject['id'].toString(),
      });
      // API call was successful, handle response data here
      if (!context.mounted) return [];
      var responseData = Utils.returnResponse(context, response);
      var cardData = responseData['data'];
      return cardData;
      // API call failed, handle error here
    } on SocketException {
      throw 'Please check your internet';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<dynamic>? cardData;

  @override
  void initState() {
    fetchImg();
    cardData = cardFormApi();
    super.initState();
  }

  Future<Uint8List?> _captureImage() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<Uint8List> generatePdf(Uint8List imageBytes) async {
    final pdf = pw.Document();

    final imageProvider = pw.MemoryImage(
      imageBytes,
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Image(imageProvider);
        },
      ),
    );

    return pdf.save();
  }

  Future<void> savePdf(Uint8List pdfBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/example.pdf';

      final file = File(filePath);
      await file.writeAsBytes(pdfBytes, flush: true);

      await Printing.layoutPdf(
        onLayout: (format) => file.readAsBytes(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to print PDF: $e');
      }
    }
  }

  void _shareImage() async {
    Uint8List? bytes = await _captureImage();
    await Share.shareXFiles([XFile.fromData(bytes!, mimeType: 'image/png')],
        subject: 'Share Image Subject');
  }

  void _print() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.image,
                ),
                title: const Text(
                  'Print as Image',
                  textScaleFactor: 1.0,
                ),
                onTap: () {
                  _shareImage();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                ),
                title: const Text(
                  'Print as PDF',
                  textScaleFactor: 1.0,
                ),
                onTap: () async {
                  final image = await _captureImage();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (image != null) {
                    final pdfBytes = await generatePdf(image);
                    await savePdf(pdfBytes);
                    // openPDFViewer(context, path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.close_rounded,
                ),
                title: const Text(
                  'Not Now',
                  textScaleFactor: 1.0,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    return DrawerWidget(
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            widget.cardObject['name'],
            textScaleFactor: 1.0,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          leadingWidth: 80,
          leading:
              AppbarLeading(backCallBack: () => Navigator.of(context).pop()),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RoutesName.home, (route) => false);
                },
                icon: const ImageIcon(
                  AssetImage(
                    'Assets/home.png',
                  ),
                  color: AppColors.primaryColor,
                )),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<dynamic>(
                  future: cardData,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            Text(
                              '${snapshot.error}',
                              textScaleFactor: 1.0,
                            ),
                          ]);
                    }
                    return RepaintBoundary(
                      key: _globalKey,
                      child: Card(
                        margin: const EdgeInsets.all(20.0),
                        shadowColor: Colors.grey[500],
                        borderOnForeground: true,
                        elevation: 5,
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: height * .20,
                                    width: width * .35,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: FadeInImage(
                                        image: NetworkImage('$profileIMG'),
                                        placeholder: const AssetImage(
                                          "Assets/profile_.png",
                                        ),
                                        imageErrorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                              'Assets/profile_.png',
                                              fit: BoxFit.cover);
                                        },
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: height * .20,
                                    width: width * .35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                snapshot.data['qrcode']),
                                            fit: BoxFit.cover)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .030,
                              ),
                              Text(
                                snapshot.data['name'],
                                textScaleFactor: 1.0,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                    fontSize: 24),
                              ),
                              const Divider(
                                thickness: 1,
                                color: Colors.black,
                                endIndent: 5,
                              ),
                              SizedBox(
                                height: height * .015,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date',
                                    textScaleFactor: 1.0,
                                  ),
                                  SizedBox(
                                    width: width * 0.1,
                                  ),
                                  const Text(
                                    ':',
                                    textScaleFactor: 1.0,
                                  ),
                                  SizedBox(
                                    width: width * 0.040,
                                  ),
                                  Text(
                                    snapshot.data['date'],
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .015,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Name',
                                    textScaleFactor: 1.0,
                                  ),
                                  SizedBox(
                                    width: width * .078,
                                  ),
                                  const Text(
                                    ':',
                                    textScaleFactor: 1.0,
                                  ),
                                  SizedBox(
                                    width: width * .040,
                                  ),
                                  Text(
                                    snapshot.data['name'],
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .015,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Type of\nCard',
                                    textScaleFactor: 1.0,
                                  ),
                                  SizedBox(
                                    width: width * .054,
                                  ),
                                  const Text(
                                    ':',
                                    textScaleFactor: 1.0,
                                  ),
                                  SizedBox(
                                    width: width * .050,
                                  ),
                                  Text(
                                    snapshot.data['card_type'],
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .015,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Relation',
                                    textScaleFactor: 1.0,
                                  ),
                                  SizedBox(
                                    width: width * .040,
                                  ),
                                  const Text(
                                    ':',
                                    textScaleFactor: 1.0,
                                  ),
                                  SizedBox(
                                    width: width * .040,
                                  ),
                                  Text(
                                    snapshot.data['relation'],
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .015,
                              ),
                              const Divider(
                                thickness: 1,
                                color: Colors.black,
                                endIndent: 5,
                              ),
                              SizedBox(
                                height: height * .015,
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PhotoViewer(
                                            fImageUrl:
                                                snapshot.data['front_pic'],
                                            bImageUrl:
                                                snapshot.data['back_pic']))),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data['front_pic'],
                                      progressIndicatorBuilder:
                                          (context, url, progress) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: progress.progress,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        );
                                      },
                                      errorWidget: (context, url, error) {
                                        return Column(
                                          children: [
                                            Text(
                                              error.toString(),
                                              textScaleFactor: 1.0,
                                            ),
                                            const Icon(Icons.error),
                                          ],
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * .015,
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PhotoViewer(
                                            fImageUrl:
                                                snapshot.data['front_pic'],
                                            bImageUrl:
                                                snapshot.data['back_pic']))),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data['back_pic'],
                                      progressIndicatorBuilder:
                                          (context, url, progress) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: progress.progress,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        );
                                      },
                                      errorWidget: (context, url, error) {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              error.toString(),
                                              textScaleFactor: 1.0,
                                            ),
                                            const Icon(Icons.error),
                                          ],
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: MaterialBtn(
                      title: 'Print',
                      color: AppColors.primaryColor,
                      materialCallBack: () => _print()),
                ),
                SizedBox(
                  height: height * .005,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: MaterialBtn(
                      title: 'Not Now',
                      color: Colors.black,
                      materialCallBack: () => Navigator.pop(context)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
