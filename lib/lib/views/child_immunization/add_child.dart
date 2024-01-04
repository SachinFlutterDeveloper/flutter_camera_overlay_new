import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:digihealthcardapp/models/child_model.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/components/round_button_light.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/viewModel/child_view_model.dart';
import 'package:digihealthcardapp/views/child_immunization/data/immunization_data.dart';
import 'package:digihealthcardapp/views/scan_health_card/card_viewmodel.dart';
import 'package:digihealthcardapp/views/scan_health_card/scan_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../profile/widgets/appbar_leading.dart';

class AddChildProfile extends StatefulWidget {
  final int index;
  const AddChildProfile({super.key, this.index = -1});

  @override
  State<AddChildProfile> createState() => _AddChildProfileState();
}

class _AddChildProfileState extends State<AddChildProfile> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  var fName = '';
  var lName = '';
  var dob = '';
  // var gender = '';
  var weight = '';
  var childHeight = '';

  late FocusNode firstNameFocusNode;
  late FocusNode lastNameFocusNode;
  late FocusNode genderFN;
  late FocusNode dobFocusNode;
  late FocusNode stateFocusNode;
  late FocusNode countryNode;
  late FocusNode weightFocusNode;
  late FocusNode heightFocusNode;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController genderET;
  late TextEditingController dobController;
  late TextEditingController stateController;
  late TextEditingController countryController;
  late TextEditingController weightController;
  late TextEditingController heightController;

  Child? childData;
  var dateFormat = DateFormat('MM/dd/yyyy');
  String? selectedGender;
  String? selectedCountry;
  String? selectedState;
  @override
  void initState() {
    super.initState();
    if (widget.index != -1) {
      childData = context.read<ChildVM>().children[widget.index];
      dob = dateFormat.format(DateTime.parse(childData!.dob));
      selectedGender = childData?.gender.toString();
      selectedCountry = childData?.country.toString() ?? '';
      selectedState = childData?.state.toString();
    }
    firstNameFocusNode = FocusNode();
    lastNameFocusNode = FocusNode();
    genderFN = FocusNode();
    dobFocusNode = FocusNode();
    stateFocusNode = FocusNode();
    countryNode = FocusNode();
    weightFocusNode = FocusNode();
    heightFocusNode = FocusNode();
    firstNameController = TextEditingController(text: childData?.name ?? '');
    lastNameController = TextEditingController(text: childData?.lname ?? '');
    genderET = TextEditingController(text: childData?.gender ?? '');

    dobController = TextEditingController(
        text: (widget.index != -1)
            ? DateFormat.yMMMMd()
                .format(DateTime.parse(childData!.dob.toString()))
            : '');
    stateController =
        TextEditingController(text: childData?.state.toString() ?? '');
    countryController =
        TextEditingController(text: childData?.country.toString() ?? '');
    weightController =
        TextEditingController(text: childData?.weight.toString() ?? '');
    heightController =
        TextEditingController(text: childData?.height.toString() ?? '');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderET.dispose();
    dobController.dispose();
    stateController.dispose();
    weightController.dispose();
    heightController.dispose();
    countryController.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    genderFN.dispose();
    dobFocusNode.dispose();
    stateFocusNode.dispose();
    countryNode.dispose();
    weightFocusNode.dispose();
    heightFocusNode.dispose();
    super.dispose();
  }

  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  Future getFrontImage(ImageSource source) async {
    var status = await Permission.photos.status;
    if (source == ImageSource.gallery) {
      if (Platform.isIOS) {
        status = await Permission.photos.status;
      } else {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          status = await Permission.storage.status;
        } else {
          status = await Permission.photos.status;
        }
      }
      if (status.isDenied) {
        // Request permission
        await Permission.photos.request();
        // Check if permission is granted after the request
        status = await Permission.photos.status;
      }
    } else {
      status = await Permission.camera.status;
      if (status.isDenied) {
        // Request permission
        await Permission.camera.request();
        // Check if permission is granted after the request
        status = await Permission.camera.status;
      }
    }
    if (status.isGranted || status.isLimited) {
      final imageFront =
          await _picker.pickImage(source: source, imageQuality: 100);
      if (imageFront != null) {
        File? image = File(imageFront.path);
        final compressed =
            await CameraHelper.compressedImage(image.path.toString());
        image = await CameraHelper.cropImage(File(compressed.path));
        setState(() {
          profileImage = image;
        });
        if (profileImage != null) {
          if (!context.mounted) return;
        }
      } else {
        if (kDebugMode) {
          print('no image is picked');
        }
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Permission denied
      if (kDebugMode) {
        print("Permission denied $status");
      }
      if (!context.mounted) return;
      if (source == ImageSource.gallery) {
        // Display a SnackBar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photo access is required to pick an image.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                // Open app settings so the user can grant permission
                openAppSettings();
              },
            ),
          ),
        );
      } else {
        // Display a SnackBar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Camera access is required to take an image.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                // Open app settings so the user can grant permission
                openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  void showFront(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext cont) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  getFrontImage(ImageSource.camera);
                },
                child: const Text(
                  'Use Camera',
                  textScaleFactor: 1.0,
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  getFrontImage(ImageSource.gallery);
                },
                child: const Text(
                  'Upload from files',
                  textScaleFactor: 1.0,
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Not Now',
                  textScaleFactor: 1.0, style: TextStyle(color: Colors.red)),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.height * 1;

    final double scaleFactor = MediaQuery.of(context).textScaleFactor;
    return DrawerWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add a child',
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          backgroundColor: Theme.of(context).primaryColor,
          leadingWidth: 80,
          leading: AppbarLeading(backCallBack: () => Navigator.pop(context)),
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
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Color(
                          (Theme.of(context).brightness == Brightness.light)
                              ? 0xffDDDDDD
                              : 0xff263238),
                      blurRadius: 6.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0.0, 0.0),
                    )
                  ],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          showFront(context);
                        },
                        child: Container(
                          width: width * .20,
                          height: height * .18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: (widget.index == -1 ||
                                    childData?.image == 'null')
                                ? (profileImage != null)
                                    ? Image.file(
                                        profileImage!,
                                        fit: BoxFit.fill,
                                      )
                                    : Image(
                                        image: const AssetImage(
                                          'Assets/add_pic.png',
                                        ),
                                        width: width * .20,
                                        height: height * .18,
                                      )
                                : (profileImage != null)
                                    ? Image.file(
                                        profileImage!,
                                        fit: BoxFit.fill,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: childData!.image.toString(),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
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
                                          return Image.asset(
                                              'Assets/profile_.png',
                                              height: height * .18,
                                              width: width * .34,
                                              fit: BoxFit.cover);
                                        },
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              textScaleFactor: 1.0,
                              text: TextSpan(
                                style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16),
                                children: [
                                  const TextSpan(text: 'First Name'),
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -7),
                                      child: const Text(
                                        '*',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextFormField(
                            focusNode: firstNameFocusNode,
                            controller: firstNameController,
                            style: TextStyle(fontSize: 16 / scaleFactor),
                            onChanged: (value) {
                              fName = value;
                            },
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return "This field is required";
                              } else {
                                return null;
                              }
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'First Name',
                              hintStyle: TextStyle(fontSize: 16 / scaleFactor),
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
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
                            onTapOutside: (e) {
                              firstNameFocusNode.unfocus();
                            },
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(context,
                                  firstNameFocusNode, lastNameFocusNode);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .025,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              textScaleFactor: 1.0,
                              text: TextSpan(
                                style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16),
                                children: [
                                  const TextSpan(text: 'Last Name'),
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -7),
                                      child: const Text(
                                        '*',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextFormField(
                            focusNode: lastNameFocusNode,
                            controller: lastNameController,
                            onChanged: (value) {
                              lName = value;
                            },
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return "This field is required";
                              } else {
                                return null;
                              }
                            },
                            style: TextStyle(fontSize: 16 / scaleFactor),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                              hintText: 'Last Name',
                              hintStyle: TextStyle(fontSize: 16 / scaleFactor),
                              isDense: true,
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
                            onTapOutside: (e) {
                              lastNameFocusNode.unfocus();
                            },
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(
                                  context, lastNameFocusNode, genderFN);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .025,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              textScaleFactor: 1.0,
                              text: TextSpan(
                                style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16),
                                children: [
                                  const TextSpan(text: 'Gender'),
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -7),
                                      child: const Text(
                                        '*',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            style: TextStyle(
                                fontSize: 16 / scaleFactor,
                                color: (Theme.of(context).brightness ==
                                        Brightness.light)
                                    ? Colors.black
                                    : Colors.white),
                            dropdownColor: Theme.of(context).cardColor,
                            focusNode: genderFN,
                            alignment: Alignment.centerRight,
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return "This field is required";
                              } else {
                                return null;
                              }
                            },
                            isExpanded: true,
                            decoration:
                                buildInputDecoration(context, 'Select gender'),
                            value: selectedGender,
                            //value: defaultUser == null ? null : user[defaultUser],
                            items: ['Male', 'Female']
                                .map<DropdownMenuItem<String>>(
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
                                selectedGender =
                                    newValue!; //user.indexOf(value!);
                              });
                            },
                            onSaved: (value) {
                              Utils.fieldFocusChange(
                                  context, genderFN, dobFocusNode);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .025,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              textScaleFactor: 1.0,
                              text: TextSpan(
                                style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16),
                                children: [
                                  const TextSpan(text: 'Date of Birth'),
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -7),
                                      child: const Text(
                                        '*',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextFormField(
                            focusNode: dobFocusNode,
                            controller: dobController,
                            style: TextStyle(fontSize: 16 / scaleFactor),
                            onTap: () {
                              _selectDate(context);
                            },
                            onChanged: (value) {
                              _selectDate(context);
                              //dob = value;
                            },
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return "This field is required";
                              } else if (dob == '') {
                                return "You haven't selected the date of birth.";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                              isDense: true,
                              hintStyle: TextStyle(fontSize: 16 / scaleFactor),
                              hintText: 'select date of birth',
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
                            onTapOutside: (e) {
                              dobFocusNode.unfocus();
                            },
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(
                                  context, dobFocusNode, countryNode);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .025,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              textScaleFactor: 1.0,
                              text: TextSpan(
                                style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16),
                                children: [
                                  const TextSpan(text: 'Country'),
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -7),
                                      child: const Text(
                                        '*',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            dropdownColor: Theme.of(context).cardColor,
                            style: TextStyle(
                                fontSize: 16 / scaleFactor,
                                color: (Theme.of(context).brightness ==
                                        Brightness.light)
                                    ? Colors.black
                                    : Colors.white),
                            focusNode: countryNode,
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return "This field is required";
                              } else {
                                return null;
                              }
                            },
                            menuMaxHeight: height * .3,
                            isExpanded: true,
                            decoration:
                                buildInputDecoration(context, 'Select country'),
                            value: selectedCountry,
                            items: ImmunizationData.countries
                                .map<DropdownMenuItem<String>>(
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
                                selectedCountry =
                                    newValue!; //user.indexOf(value!);
                              });
                            },
                            onSaved: (value) {
                              Utils.fieldFocusChange(
                                  context, countryNode, stateFocusNode);
                            },
                          ),
                        ],
                      ),
                      (selectedCountry == 'USA (default)')
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: height * .025,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: RichText(
                                    textScaleFactor: 1.0,
                                    text: TextSpan(
                                      style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 16),
                                      children: [
                                        const TextSpan(text: 'State'),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(0.0, -7),
                                            child: const Text(
                                              '*',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      AppColors.primaryColor),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DropdownButtonFormField<String>(
                                  dropdownColor: Theme.of(context).cardColor,
                                  focusNode: stateFocusNode,
                                  isExpanded: true,
                                  style: TextStyle(
                                      fontSize: 16 / scaleFactor,
                                      color: (Theme.of(context).brightness ==
                                              Brightness.light)
                                          ? Colors.black
                                          : Colors.white),
                                  menuMaxHeight: height * 0.3,
                                  decoration: buildInputDecoration(
                                      context, 'Select state'),
                                  value: selectedState,
                                  items: ImmunizationData
                                      .stateAbbreviationsWithNames
                                      .map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          textScaleFactor: 1.0,
                                          textAlign: TextAlign.left,
                                        ),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedState =
                                          newValue!; //user.indexOf(value!);
                                    });
                                  },
                                  onSaved: (value) {
                                    Utils.fieldFocusChange(context,
                                        stateFocusNode, weightFocusNode);
                                  },
                                )
                              ],
                            )
                          : const SizedBox.shrink(),
                      SizedBox(
                        height: height * .025,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              textScaleFactor: 1.0,
                              text: TextSpan(
                                style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16),
                                children: [
                                  const TextSpan(text: 'Weight in lbs'),
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -7),
                                      child: const Text(
                                        '',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextFormField(
                            focusNode: weightFocusNode,
                            controller: weightController,
                            style: TextStyle(fontSize: 16 / scaleFactor),
                            onChanged: (value) {
                              weight = value;
                            },
                            keyboardType:
                                defaultTargetPlatform == TargetPlatform.iOS
                                    ? const TextInputType.numberWithOptions(
                                        decimal: true, signed: true)
                                    : const TextInputType.numberWithOptions(
                                        decimal: true),
                            decoration: InputDecoration(
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                              hintStyle: TextStyle(fontSize: 16 / scaleFactor),
                              hintText: 'Weight in lbs',
                              isDense: true,
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
                            onTapOutside: (e) {
                              weightFocusNode.unfocus();
                            },
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(
                                  context, weightFocusNode, heightFocusNode);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .025,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              textScaleFactor: 1.0,
                              text: TextSpan(
                                style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16),
                                children: [
                                  const TextSpan(text: 'Height in feet inches'),
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -7),
                                      child: const Text(
                                        '',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextFormField(
                            focusNode: heightFocusNode,
                            controller: heightController,
                            onChanged: (value) {
                              childHeight = value;
                            },
                            style: TextStyle(fontSize: 16 / scaleFactor),
                            onTapOutside: (e) {
                              heightFocusNode.unfocus();
                            },
                            keyboardType:
                                defaultTargetPlatform == TargetPlatform.iOS
                                    ? const TextInputType.numberWithOptions(
                                        decimal: true, signed: true)
                                    : const TextInputType.numberWithOptions(
                                        decimal: true),
                            decoration: InputDecoration(
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                              hintText: 'Height in feet inches',
                              hintStyle: TextStyle(fontSize: 16 / scaleFactor),
                              isDense: true,
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
                              heightFocusNode.unfocus();
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .04,
                      ),
                      RoundButtonLight(
                        title: (widget.index != -1)
                            ? 'Update Profile'
                            : 'Save Profile',
                        onPress: () async {
                          if (dob == '') {
                            Utils.snackBarMessage(
                                'Please select your child date of birth',
                                context);
                          } else if (selectedGender == null ||
                              selectedGender!.isEmpty) {
                            Utils.snackBarMessage(
                                'Please select gender', context);
                          } else {
                            if (_form.currentState!.validate()) {
                              final childModel = Provider.of<CardViewModel>(
                                  context,
                                  listen: false);

                              if (!context.mounted) return;
                              // if (profileImage == null) {
                              //   Utils.snackBarMessage(
                              //       'Please select a profile image', context);
                              // }
                              Map<String, dynamic> data = {
                                if (widget.index != -1)
                                  'id': childData?.id.toString(),
                                'first_name':
                                    firstNameController.text.trim().toString(),
                                'last_name':
                                    lastNameController.text.trim().toString(),
                                'dob': dob.toString(),
                                'gender': selectedGender.toString(),
                                'state': (selectedState == null)
                                    ? stateController.text.trim().toString()
                                    : selectedState?.trim().toString(),
                                'height':
                                    heightController.text.trim().toString(),
                                'weight':
                                    weightController.text.trim().toString(),
                                'height_unit': 'inch',
                                'weight_unit': 'lbs',
                                if (profileImage != null)
                                  'image': MultipartFile.fromFileSync(
                                      profileImage!.path,
                                      filename: "image.jpg"),
                                'country': selectedCountry?.trim()
                              };
                              if (!context.mounted) return;
                              if (widget.index != -1) {
                                if (!childModel.isLoading) {
                                  await childModel.saveCard(context, data,
                                      false, false, false, false, false, true);
                                } else {
                                  Utils.snackBarMessage(
                                      'please wait..', context);
                                }
                              } else {
                                if (!childModel.isLoading) {
                                  await childModel.saveCard(context, data,
                                      false, false, false, true, false, false);
                                  DialogBoxes.showLoading();
                                } else {
                                  Utils.snackBarMessage(
                                      'please wait..', context);
                                }
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if (widget.index != -1)
                        RoundButtonLight(
                          title: 'Delete Profile',
                          onPress: () {
                            DialogBoxes.showConfirmationDialog(context,
                                () async {
                              await context.read<ChildVM>().deleteChild(
                                  childData!.id.toString(), context);
                            }, 'Are you sure you want to delete this profile? After this action you will not be able to recover your child\'s already saved record.',
                                false, false);
                          },
                          color: Colors.deepOrange,
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final String formattedDate = dateFormat.format(picked);
      dobController.text = DateFormat.yMMMMd().format(picked);

      setState(() {
        dob = formattedDate.toString();
      });
    }
  }
}
