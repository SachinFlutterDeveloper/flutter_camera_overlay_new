import 'dart:async';
import 'dart:io';

import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/viewModel/user_view_model.dart';
import 'package:digihealthcardapp/views/scan_health_card/card_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../viewModel/home_view_model.dart';
import '../profile/widgets/appbar_leading.dart';

class ScanIDScreen extends StatefulWidget {
  const ScanIDScreen({Key? key}) : super(key: key);

  @override
  State<ScanIDScreen> createState() => _ScanIDScreenState();
}

class _ScanIDScreenState extends State<ScanIDScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController otherIDController = TextEditingController();
  late TextEditingController nameController;
  late TextEditingController relationController;

  List<String> _cardIDTypes = [];
  String userToken = '';
  FocusNode otherFocusNode = FocusNode();

  List<String> user = <String>['For Personal Use'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text:
            '${OnePref.getString('first_name')} ${OnePref.getString('last_name')}');
    relationController = TextEditingController(text: 'self');
    if (OnePref.getString('sub_mode')?.toLowerCase() == 'self') {
      user = <String>['For Personal Use'];
    } else if (OnePref.getString('sub_mode')?.toLowerCase() == 'family') {
      user = <String>['For Personal Use', 'For Family Use'];
    }
    fetchIDCardTypes();
  }

  Future<void> fetchIDCardTypes() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    _cardIDTypes = await homeViewModel.fetchIdCardTypes();
    setState(() {});
  }

  String? selectedItem;

  @override
  void dispose() {
    otherFocusNode.dispose();
    otherIDController.dispose();
    super.dispose();
  }

  String defaultUser = 'For Personal Use';

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).textScaleFactor;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final userPrefs = Provider.of<User_view_model>(context);
    final cameraService = Provider.of<CameraHelper>(context);

    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Scan ID Card',
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
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
                    SizedBox(
                      height: height * .020,
                    ),
                    const Text(
                      'Please add the front and back pictures of your health/ID card.',
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: height * .020,
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      // color: Colors.grey[200],
                      shadowColor: Colors.grey,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  'Front Image',
                                  textScaleFactor: 1.0,
                                ),
                                SizedBox(
                                  width: width * .16,
                                ),
                                const Text(
                                  'Back Image',
                                  textScaleFactor: 1.0,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height * .015,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    DialogBoxes.showPickImageDialog(context,
                                        () async {
                                      Navigator.of(context).pop();
                                      cameraService.onCaptureFront(context);
                                    }, () async {
                                      Navigator.of(context).pop();
                                      cameraService.getFrontImage(
                                          context, ImageSource.gallery);
                                    });
                                  },
                                  child: Container(
                                    height: height * .16,
                                    width: width * .40,
                                    color: Theme.of(context).primaryColor,
                                    child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          cameraService.frontImage != null
                                              ? Image.file(
                                                  File(cameraService
                                                          .frontImage!.path)
                                                      .absolute,
                                                  height: height * .15,
                                                  width: width * .38,
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
                                                onTap: () {
                                                  DialogBoxes
                                                      .showConfirmDialogDel(
                                                          context, () {
                                                    Navigator.of(context).pop();
                                                    cameraService
                                                        .removeFrontImage();
                                                  });
                                                },
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
                                SizedBox(
                                  width: width * .030,
                                ),
                                InkWell(
                                  onTap: () {
                                    DialogBoxes.showPickImageDialog(context,
                                        () async {
                                      Navigator.of(context).pop();
                                      cameraService.onScanBack(context);
                                    }, () async {
                                      Navigator.of(context).pop();
                                      cameraService.getBackImage(
                                          context, ImageSource.gallery);
                                    });
                                  },
                                  child: Container(
                                    height: height * .16,
                                    width: width * .40,
                                    color: Theme.of(context).primaryColor,
                                    child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          cameraService.backImage != null
                                              ? Image.file(
                                                  File(cameraService
                                                          .backImage!.path)
                                                      .absolute,
                                                  height: height * .15,
                                                  width: width * .38,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  'Assets/add_pic.png',
                                                  height: 50,
                                                  width: 50,
                                                ),
                                          if (cameraService.backImage != null)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  DialogBoxes
                                                      .showConfirmDialogDel(
                                                          context, () {
                                                    Navigator.of(context).pop();
                                                    cameraService
                                                        .removeBackImage();
                                                  });
                                                },
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
                            SizedBox(
                              height: height * .015,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (cameraService.frontImage != null)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size.fromHeight(10),
                                        backgroundColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Colors.white
                                                : Colors.grey[800],
                                      ),
                                      onPressed: () =>
                                          DialogBoxes.showPickImageDialog(
                                              context, () async {
                                        Navigator.of(context).pop();
                                        cameraService.onCaptureFront(context);
                                      }, () async {
                                        Navigator.of(context).pop();
                                        cameraService.getFrontImage(
                                            context, ImageSource.gallery);
                                      }),
                                      child: const Text(
                                        'Retake Image',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  SizedBox(
                                    width: width * .10,
                                  ),
                                  if (cameraService.backImage != null)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size.fromHeight(10),
                                        backgroundColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Colors.white
                                                : Colors.grey[800],
                                      ),
                                      onPressed: () =>
                                          DialogBoxes.showPickImageDialog(
                                              context, () async {
                                        Navigator.of(context).pop();
                                        cameraService.onScanBack(context);
                                      }, () async {
                                        Navigator.of(context).pop();
                                        cameraService.getBackImage(
                                            context, ImageSource.gallery);
                                      }),
                                      child: const Text(
                                        'Retake Image',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                ]),
                            SizedBox(
                              height: height * .015,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * .030,
                    ),
                    Stack(
                      children: [
                        const Positioned(
                            top: 8,
                            left: 0,
                            child: Text(
                              'Type of\nCard',
                              textScaleFactor: 1.0,
                            )),
                        Padding(
                            padding:
                                const EdgeInsets.only(left: 100.0, right: 10),
                            child: DropdownButtonFormField<String>(
                                dropdownColor: Theme.of(context).cardColor,
                                alignment: Alignment.centerLeft,
                                style: TextStyle(
                                    fontSize: 16 / scaleFactor,
                                    color: (Theme.of(context).brightness ==
                                            Brightness.light)
                                        ? Colors.black
                                        : Colors.white),
                                decoration: buildInputDecoration(
                                    context, 'Select the type of card'),
                                value: selectedItem,
                                items:
                                    _cardIDTypes.map<DropdownMenuItem<String>>(
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
                                    selectedItem = newValue;
                                  });
                                })),
                      ],
                    ),
                    SizedBox(
                      height: height * .015,
                    ),
                    (selectedItem == 'Other')
                        ? Stack(
                            children: [
                              const Positioned(
                                  top: 8,
                                  left: 0,
                                  child: Text(
                                    'Enter Type\nof Card',
                                    textScaleFactor: 1.0,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 100.0, right: 10),
                                child: TextFormField(
                                    focusNode: otherFocusNode,
                                    enabled: true,
                                    style:
                                        TextStyle(fontSize: 16 / scaleFactor),
                                    controller: otherIDController,
                                    decoration: buildInputDecoration(context,
                                        'Please Enter Your Other Card Type')),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: height * 0.0,
                          ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Stack(
                      children: [
                        const Positioned(
                            top: 15,
                            left: 0,
                            child: Text(
                              'Purpose',
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
                              alignment: Alignment.centerRight,
                              decoration: InputDecoration(
                                fillColor: Theme.of(context).cardColor,
                                filled: true,
                                focusColor: Theme.of(context).cardColor,
                                contentPadding: const EdgeInsets.all(5),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(
                                          (Theme.of(context).brightness ==
                                                  Brightness.light)
                                              ? 0xffE4E7EB
                                              : 0xff263238)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              value: defaultUser,
                              //value: defaultUser == null ? null : user[defaultUser],
                              items: user.map<DropdownMenuItem<String>>(
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
                                  defaultUser = newValue!;
                                  if (newValue.toLowerCase() ==
                                      'for family use') {
                                    nameController = TextEditingController();
                                    relationController =
                                        TextEditingController();
                                  } else {
                                    nameController = TextEditingController(
                                        text:
                                            '${OnePref.getString('first_name')} ${OnePref.getString('last_name')}');
                                    relationController =
                                        TextEditingController(text: 'self');
                                  }
                                  //user.indexOf(value!);
                                  //userselectedvalue = value!;
                                });
                              }),
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
                              'Name',
                              textScaleFactor: 1.0,
                            )),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 100.0, right: 10),
                          child: FutureBuilder(
                              future: userPrefs.getUser(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade100,
                                    highlightColor: Colors.grey.shade500,
                                    child: Container(
                                      height: 5,
                                      width: width * .5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                } else {
                                  final fName =
                                      snapshot.data!.firstName.toString();
                                  final lName =
                                      snapshot.data!.lastName.toString();
                                  return TextFormField(
                                    controller: nameController,
                                    enabled: defaultUser.toLowerCase() !=
                                        'for personal use',
                                    style:
                                        TextStyle(fontSize: 16 / scaleFactor),
                                    decoration:
                                        buildInputDecoration(context, ''),
                                  );
                                }
                              }),
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
                              style: TextStyle(fontSize: 16 / scaleFactor),
                              enabled: defaultUser.toLowerCase() !=
                                  'for personal use',
                              decoration: buildInputDecoration(context, ''),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: height * .03,
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
                            if (selectedItem == null || selectedItem!.isEmpty) {
                              Utils.snackBarMessage(
                                  'Please select the card type', context);
                            } else if (selectedItem == 'Other' &&
                                otherIDController.text.isEmpty) {
                              Utils.snackBarMessage(
                                  'Please enter your other card type', context);
                            } else if (cameraService.frontImage?.path == null ||
                                cameraService.frontImage!.path.isEmpty) {
                              Utils.snackBarMessage(
                                  'Please add front scan of your card',
                                  context);
                            } else if (cameraService.backImage?.path == null ||
                                cameraService.backImage!.path.isEmpty) {
                              Utils.snackBarMessage(
                                  'Please add back scan of your card', context);
                            } else if (nameController.text.isEmpty) {
                              Utils.snackBarMessage(
                                  'Please Enter Name', context);
                            } else if (relationController.text.isEmpty) {
                              Utils.snackBarMessage(
                                  'Please Enter Relation', context);
                            } else {
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              if (!context.mounted) return;
                              final String? userId = prefs.getString('id');
                              final String? fName =
                                  prefs.getString('first_name');
                              final String? lName =
                                  prefs.getString('last_name');
                              final cardBody = {
                                "patient_id": userId.toString(),
                                "name": nameController.text.trim().toString(),
                                "relation":
                                    relationController.text.trim().toString(),
                                "card_type": (selectedItem == 'Other')
                                    ? otherIDController.text.toString()
                                    : selectedItem.toString(),
                                "card_for": defaultUser.toString(),
                                "additional_card_type":
                                    otherIDController.text.toString(),
                                "front_pic": MultipartFile.fromFileSync(
                                    context
                                        .read<CameraHelper>()
                                        .frontImage!
                                        .path,
                                    filename: "front_image.jpg"),
                                "back_pic": MultipartFile.fromFileSync(
                                    context
                                        .read<CameraHelper>()
                                        .backImage!
                                        .path,
                                    filename: "back_image.jpg"),
                              };
                              final cardVM = Provider.of<CardViewModel>(context,
                                  listen: false);
                              if (!context.read<CardViewModel>().isLoading) {
                                cardVM.saveCard(context, cardBody, false, false,
                                    false, false, false, false);
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
                            Navigator.pushNamed(context, RoutesName.home);
                          }),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }

  InputDecoration buildInputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(fontSize: 16 / MediaQuery.of(context).textScaleFactor),
      enabled: false,
      fillColor: Theme.of(context).cardColor,
      filled: true,
      contentPadding: const EdgeInsets.all(5),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Color((Theme.of(context).brightness == Brightness.light)
                ? 0xffE4E7EB
                : 0xff263238)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Color((Theme.of(context).brightness == Brightness.light)
                ? 0xffE4E7EB
                : 0xff263238)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
