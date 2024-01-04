import 'dart:io';

import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/views/profile/widgets/appbar_leading.dart';
import 'package:digihealthcardapp/views/scan_health_card/card_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanTestResult extends StatefulWidget {
  const ScanTestResult({Key? key}) : super(key: key);

  @override
  State<ScanTestResult> createState() => _ScanTestResultState();
}

class _ScanTestResultState extends State<ScanTestResult> {
  List<String> result = <String>[
    'Select Result',
    'Positive',
    'Negative',
    'Other'
  ];
  String defaultResult = 'Select Result';

  TextEditingController? otherController;
  TextEditingController? nameController;
  TextEditingController? relationController;
  FocusNode? nameFocus;
  FocusNode? relationFocus;
  FocusNode? otherFocusNode;

  @override
  void initState() {
    otherController = TextEditingController();
    nameController = TextEditingController();
    relationController = TextEditingController();
    nameFocus = FocusNode();
    relationFocus = FocusNode();
    otherFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    otherFocusNode?.dispose();
    otherController?.dispose();
    nameController?.dispose();
    nameFocus?.dispose();
    relationController?.dispose();
    relationFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final double scaleFactor = MediaQuery.of(context).textScaleFactor;
    final cameraService = Provider.of<CameraHelper>(context);

    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Add Test Results',
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              // backgroundColor: Theme.of(context).primaryColor,
              leadingWidth: 100,
              leading: AppbarLeading(
                  backCallBack: () => Navigator.pop(context, '1122')),
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
                    ))
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Please add the front and back pictures of your health/ID card.',
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      // color: Colors.grey[200],
                      shadowColor: Colors.grey,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: width * .25,
                            ),
                            InkWell(
                              onTap: () {
                                cameraService.getFrontImage(
                                    context, ImageSource.gallery);
                              },
                              child: Container(
                                height: height * .40,
                                width: width * .80,
                                color: Theme.of(context).primaryColor,
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      cameraService.frontImage != null
                                          ? Image.file(
                                              File(cameraService
                                                      .frontImage!.path)
                                                  .absolute,
                                              height: height * .38,
                                              width: width * .78,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'Assets/add_pic.png',
                                              height: 50,
                                              width: 50,
                                            ),
                                      if (cameraService.frontImage != null)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () => DialogBoxes
                                                .showConfirmDialogDel(context,
                                                    () {
                                              Navigator.pop(context);
                                              cameraService.removeFrontImage();
                                            }),
                                            child: const CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.red,
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        )
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * .040,
                    ),
                    Stack(
                      children: [
                        const Positioned(
                            top: 15,
                            left: 0,
                            child: Text(
                              'Name',
                              textScaleFactor: 1.0,
                            )),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 100.0, right: 10),
                          child: TextFormField(
                            controller: nameController,
                            focusNode: nameFocus,
                            style: TextStyle(fontSize: 16 / scaleFactor),
                            decoration: InputDecoration(
                              hintText: 'Enter Name',
                              hintStyle: TextStyle(fontSize: 14 / scaleFactor),
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                              contentPadding: const EdgeInsets.all(5),
                              disabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xffE4E7EB)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xffE4E7EB)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(
                                  context, nameFocus!, relationFocus!);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * .015,
                    ),
                    Stack(
                      children: [
                        const Positioned(
                            top: 15,
                            left: 0,
                            child: Text(
                              'Relation',
                              textScaleFactor: 1.0,
                            )),
                        Padding(
                            padding:
                                const EdgeInsets.only(left: 100.0, right: 10),
                            child: TextFormField(
                              controller: relationController,
                              focusNode: relationFocus,
                              style: TextStyle(fontSize: 16 / scaleFactor),
                              decoration: InputDecoration(
                                hintText: 'Enter Relationship',
                                hintStyle:
                                    TextStyle(fontSize: 14 / scaleFactor),
                                contentPadding: const EdgeInsets.all(5),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xffE4E7EB)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                fillColor: Theme.of(context).cardColor,
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xffE4E7EB)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: height * .015,
                    ),
                    Stack(
                      children: [
                        const Positioned(
                            top: 15,
                            left: 0,
                            child: Text(
                              'Result',
                              textScaleFactor: 1.0,
                            )),
                        Padding(
                            padding:
                                const EdgeInsets.only(left: 100.0, right: 10),
                            child: DropdownButtonFormField<String>(
                                dropdownColor: Theme.of(context).cardColor,
                                style: TextStyle(
                                    fontSize: 16 / scaleFactor,
                                    color: (Theme.of(context).brightness ==
                                            Brightness.light)
                                        ? Colors.black
                                        : Colors.white),
                                alignment: Alignment.centerLeft,
                                decoration: InputDecoration(
                                  fillColor: Theme.of(context).cardColor,
                                  filled: true,
                                  contentPadding: const EdgeInsets.all(5),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.primaryColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xffE4E7EB)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                value: defaultResult,
                                items: result.map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        textScaleFactor: 1.0,
                                      ),
                                    );
                                  },
                                ).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    defaultResult = newValue!;
                                  });
                                })),
                      ],
                    ),
                    SizedBox(
                      height: height * .015,
                    ),
                    (defaultResult == 'Other')
                        ? Stack(
                            children: [
                              const Positioned(
                                  top: 12,
                                  left: 2,
                                  child: Text(
                                    'Description',
                                    textScaleFactor: 1.0,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10, left: 100.0, right: 10),
                                child: TextFormField(
                                  focusNode: otherFocusNode,
                                  controller: otherController,
                                  style: TextStyle(fontSize: 16 / scaleFactor),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(5),
                                    hintText: 'Enter Other Description',
                                    hintStyle:
                                        TextStyle(fontSize: 16 / scaleFactor),
                                    fillColor: Theme.of(context).cardColor,
                                    filled: true,
                                    focusColor: Theme.of(context).cardColor,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppColors.primaryColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xffE4E7EB)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: height * .030,
                          ),
                    SizedBox(
                      height: height * .01,
                    ),
                    SizedBox(
                      height: height * .068,
                      width: width * .88,
                      child: CupertinoButton(
                          minSize: 10,
                          color: AppColors.primaryColor,
                          child: const Center(
                            child: Text(
                              'Save Card',
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                          onPressed: () async {
                            if (!context.mounted) return;
                            if (defaultResult == 'Select Result') {
                              Utils.snackBarMessage(
                                  'Please select the result type', context);
                            } else if (defaultResult == 'Other' &&
                                otherController!.text.isEmpty) {
                              Utils.snackBarMessage(
                                  'Please enter your other result type',
                                  context);
                            } else if (cameraService.frontImage?.path == null ||
                                cameraService.frontImage!.path.isEmpty) {
                              Utils.snackBarMessage(
                                  'Please add scan of your result', context);
                            } else {
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              if (!context.mounted) return;
                              final String? userId = prefs.getString('id');
                              final resultBody = {
                                "patient_id": userId.toString(),
                                "name": nameController!.text.toString(),
                                "relation": relationController!.text.toString(),
                                "result": (defaultResult == 'Other')
                                    ? otherController!.text.toString()
                                    : defaultResult.toString(),
                                "frontpic": await MultipartFile.fromFile(
                                    context
                                        .read<CameraHelper>()
                                        .frontImage!
                                        .path,
                                    filename: "front_image.jpg"),
                              };
                              if (!context.mounted) return;
                              final cardVM = Provider.of<CardViewModel>(context,
                                  listen: false);
                              if (!context.read<CardViewModel>().isLoading) {
                                cardVM.saveCard(context, resultBody, false,
                                    true, false, false, false, false);
                              } else {
                                Utils.snackBarMessage('Please wait!', context);
                              }
                            }
                          }),
                    ),
                    SizedBox(
                      height: height * .01,
                    ),
                    SizedBox(
                      height: height * .068,
                      width: width * .88,
                      child: CupertinoButton(
                          minSize: 20,
                          color: AppColors.black,
                          child: const Center(
                            child: Text(
                              'Not Now',
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
