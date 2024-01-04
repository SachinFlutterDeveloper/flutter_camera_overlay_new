import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/Theme_view_model.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/views/profile/viewmodels/change_password.viewmodel.dart';
import 'package:digihealthcardapp/views/profile/viewmodels/profile.viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:onepref/onepref.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/network_exceptions.dart';
import 'widgets/appbar_leading.dart';
import 'widgets/material_btn.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImg;
  String? fName;
  String? lName;
  DateTime bDate = DateTime.now();
  PhoneNumber? Phone;
  String? Number;
  String? Code;
  String? formattedNumber;
  PhoneNumber? number;
  String? _Phone;
  String? _gender;

  @override
  void initState() {
    firstNameController =
        TextEditingController(text: OnePref.getString('first_name') ?? '');
    lastNameController = TextEditingController(
      text: OnePref.getString('last_name') ?? '',
    );
    birthdateController = TextEditingController(
      text: OnePref.getString('birthdate'),
    );
    super.initState();
    firstNameFocusNode;
    lastNameFocusNode;
    birthdateFocusNode;
    phoneFocusNode;
    _Phone = OnePref.getString('phone');
    _gender = OnePref.getString('gender') ?? '';
    fetchImg();
  }

  final TextEditingController phoneController =
      MaskedTextController(mask: '000-000-0000');

  Future<void> fetchImg() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    profileImg = prefs.getString('image') ?? '';
    _gender = prefs.getString('gender') ?? '';
    _Phone = prefs.getString('phone') ?? '';
    final RegExp regex = RegExp(r'^\+(\d+)-(\d+)-(\d+)-(\d+)$');

    if (_Phone != null) {
      final Match? match = regex.firstMatch(_Phone ?? '');
      if (match != null) {
        Code = match.group(1) ?? '';
        Number = '${match.group(2)}-${match.group(3)}-${match.group(4)}';
        if (kDebugMode) {
          print('$Number, $Code');
        }
      }
    }

    prefs.setString('phone', '+$Code-$Number');

    if (_Phone != null || _Phone!.isNotEmpty) {
      number = await PhoneNumber.getRegionInfoFromPhoneNumber(_Phone ?? '');
      phoneController.text = ((number!.parseNumber().substring(1).length >= 8)
          ? Number
          : number!.parseNumber().substring(1))!;
      if (kDebugMode) {
        print('${number?.isoCode} ${number?.parseNumber().substring(1)}');
      }
      Phone = PhoneNumber(isoCode: number?.isoCode);
      setState(() {});
    }
  }

  List<String> gender = ['1', '0', '2'];
  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode birthdateFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  final DateFormat formatter = DateFormat('MM/dd/yyyy');

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: bDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final String formattedDate = formatter.format(picked);
      birthdateController?.text = formattedDate.toString();
    }
  }

  TextEditingController? firstNameController;
  TextEditingController? lastNameController;
  TextEditingController? birthdateController;

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  // CroppedFile? _croppedFile;
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
        // final imageFrontPermanent = await saveFilePermanently(imageFront.path);
        setState(() {
          profileImage = image;
        });
        if (profileImage != null) {
          if (!context.mounted) return;
          saveProfilePicture(context);
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

  Future<void> saveProfilePicture(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    String imageName = '$userId' + '_' + '$userId' + '_patient_image.jpg';
    try {
      // get your image bytes here
      String url = AppUrl.profileImg;
      Map<String, String> headers = {"Oauthtoken": "Bearer $userToken"};
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(profileImage!.path,
            filename: imageName.toString()),
      });
      DialogBoxes.showLoadingNoTimer();
      Response response = await dio.post(url,
          data: formData,
          options: Options(
              method: 'POST',
              headers: headers,
              responseType: ResponseType.json));

      if (response.statusCode == 200) {
        DialogBoxes.cancelLoading();
        String responseBody = response.data.toString();
        var decodedResponse = jsonDecode(response.data);
        if (kDebugMode) {
          print(decodedResponse.toString());
        }
        final msg = decodedResponse['msg'];
        final img = decodedResponse['image'];
        await prefs.setString('image', img);
        fetchImg();
        DialogBoxes.showLoading();
        if (!context.mounted) return;
        Utils.snackBarMessage('$msg', context);
        if (kDebugMode) {
          print(decodedResponse.toString() + responseBody);
        }
      } else {
        DialogBoxes.cancelLoading();
        if (!context.mounted) return;
        Utils.snackBarMessage('failed to upload', context);
        if (kDebugMode) {
          print(Future.error(response).toString());
          print('Error sending request');
        }
      }
    } on SocketException catch (e) {
      DialogBoxes.cancelLoading();
      NetworkExceptions exception = NetworkExceptions.fromDioException(e);
      String errorMsg = NetworkExceptions.getErrorMessage(exception);
      if (!context.mounted) return;
      Utils.snackBarMessage(errorMsg, context);
      if (kDebugMode) {
        print('Socket: $errorMsg');
      }
    } on DioException catch (e) {
      DialogBoxes.cancelLoading();
      NetworkExceptions exception = NetworkExceptions.fromDioException(e);
      String errorMsg = NetworkExceptions.getErrorMessage(exception);
      if (!context.mounted) return;
      Utils.errorSnackBar(errorMsg, context);
      if (kDebugMode) {
        print('dio: $errorMsg ${e.response} ${e.stackTrace}');
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
  void dispose() {
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    birthdateFocusNode.dispose();
    phoneFocusNode.dispose();
    firstNameController?.dispose();
    lastNameController?.dispose();
    birthdateController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    final double scaleFactor = MediaQuery.of(context).textScaleFactor;
    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Update Profile',
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              leadingWidth: 80,
              leading: AppbarLeading(
                backCallBack: () => Navigator.pop(context),
              ),
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
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          showFront(context);
                        },
                        child: Container(
                          width: width * .34,
                          height: height * .18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: profileImg.toString(),
                              imageBuilder: (context, imageProvider) =>
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                          child: CircularProgressIndicator(
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
                                return Image.asset('Assets/profile_.png',
                                    height: height * .18,
                                    width: width * .34,
                                    fit: BoxFit.cover);
                              },
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            showFront(context);
                          },
                          child: const Text(
                            'Edit Profile Picture',
                            textScaleFactor: 1.0,
                            style: TextStyle(color: AppColors.primaryColor),
                          )),
                      SizedBox(
                        height: height * .020,
                      ),
                      const Divider(
                          thickness: 2, color: AppColors.primaryColor),
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
                            onTapOutside: (event) {
                              firstNameFocusNode.unfocus();
                            },
                            onChanged: (value) {
                              firstNameController?.text = value;
                              firstNameController?.selection =
                                  TextSelection.collapsed(offset: value.length);
                            },
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return "This field is required";
                              } else {
                                return null;
                              }
                            },
                            keyboardType: TextInputType.text,
                            decoration:
                                buildInputDecoration(context, 'First name'),
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(context,
                                  firstNameFocusNode, lastNameFocusNode);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .015,
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
                            style: TextStyle(fontSize: 16 / scaleFactor),
                            onTapOutside: (event) {
                              lastNameFocusNode.unfocus();
                            },
                            onChanged: (value) {
                              lastNameController?.text = value;
                              lastNameController?.selection =
                                  TextSelection.collapsed(offset: value.length);
                            },
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return "This field is required";
                              } else {
                                return null;
                              }
                            },
                            keyboardType: TextInputType.text,
                            decoration:
                                buildInputDecoration(context, 'Last name'),
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(context, lastNameFocusNode,
                                  birthdateFocusNode);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .015,
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
                                  const TextSpan(text: 'Birthdate'),
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -7),
                                      child: const Text(
                                        '*',
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
                            style: TextStyle(fontSize: 16 / scaleFactor),
                            controller: birthdateController,
                            focusNode: birthdateFocusNode,
                            onTapOutside: (event) {
                              birthdateFocusNode.unfocus();
                            },
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              _selectDate(context);
                            },
                            onChanged: (value) {
                              birthdateController?.text = value;
                              birthdateController?.selection =
                                  TextSelection.collapsed(offset: value.length);
                              if (kDebugMode) {
                                print('$birthdateController');
                              }
                            },
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return "This field is required";
                              } else {
                                return null;
                              }
                            },
                            keyboardType: TextInputType.text,
                            decoration:
                                buildInputDecoration(context, 'Birthdate'),
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(
                                  context, birthdateFocusNode, phoneFocusNode);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .015,
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
                                  const TextSpan(text: 'Phone Number'),
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -7),
                                      child: const Text(
                                        '*',
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
                          InternationalPhoneNumberInput(
                            autoFocus: false,
                            selectorTextStyle: TextStyle(
                                fontSize: 16 / scaleFactor,
                                fontWeight: FontWeight.w400),
                            textStyle: TextStyle(fontSize: 16 / scaleFactor),
                            textFieldController: phoneController,
                            onInputChanged: (PhoneNumber number) {
                              formattedNumber = DialogBoxes.formatPhoneNumber(
                                number.dialCode.toString(),
                                number.parseNumber(),
                              );
                              phoneController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: phoneController.text.length));
                              // phoneController?.text = Number.toString();
                              if (kDebugMode) {
                                print('Formatted: $formattedNumber');
                              }
                            },
                            onSaved: (PhoneNumber number) {
                              formattedNumber = DialogBoxes.formatPhoneNumber(
                                number.dialCode.toString(),
                                number.parseNumber(),
                              );
                              if (kDebugMode) {
                                print('$formattedNumber');
                              }
                            },
                            isEnabled: false,
                            formatInput: false,
                            onInputValidated: (bool value) {
                              if (kDebugMode) {
                                print(value);
                              }
                            },
                            spaceBetweenSelectorAndTextField: width * .001,
                            selectorConfig: const SelectorConfig(
                              trailingSpace: false,
                              leadingPadding: 8.0,
                              showFlags: true,
                              setSelectorButtonAsPrefixIcon: true,
                              selectorType: PhoneInputSelectorType.DIALOG,
                            ),
                            locale: 'EN',
                            ignoreBlank: true,
                            maxLength: 20,
                            initialValue: Phone,
                            focusNode: phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (kDebugMode) {
                                print(value);
                              }
                              if (value != null && value.isEmpty) {
                                return "This field is required";
                              } else {
                                return null;
                              }
                            },
                            inputDecoration: InputDecoration(
                              isDense: true,
                              counterStyle:
                                  TextStyle(fontSize: 16 / scaleFactor),
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
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .015,
                      ),
                      Card(
                        color: Theme.of(context).cardColor,
                        clipBehavior: Clip.hardEdge,
                        shape: Border.all(
                          width: 1,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Column(
                          children: [
                            Consumer<themeChanger>(
                                builder: (context, value, child) {
                              return RadioListTile<ThemeMode>(
                                  title: const Text(
                                    'Follow System Setting',
                                    textScaleFactor: 1.0,
                                  ),
                                  value: ThemeMode.system,
                                  groupValue: value.themeMode,
                                  onChanged: (value) {
                                    Provider.of<themeChanger>(context,
                                            listen: false)
                                        .setTheme(value, 0);
                                  });
                            }),
                            Consumer<themeChanger>(
                                builder: (context, value, child) {
                              return RadioListTile<ThemeMode>(
                                  title: const Text(
                                    'Dark Mode',
                                    textScaleFactor: 1.0,
                                  ),
                                  value: ThemeMode.dark,
                                  groupValue: value.themeMode,
                                  onChanged: (value) {
                                    Provider.of<themeChanger>(context,
                                            listen: false)
                                        .setTheme(value, 1);
                                  });
                            }),
                            Consumer<themeChanger>(
                                builder: (context, value, child) {
                              return RadioListTile<ThemeMode>(
                                  title: const Text(
                                    'Light Mode',
                                    textScaleFactor: 1.0,
                                  ),
                                  value: ThemeMode.light,
                                  groupValue: value.themeMode,
                                  onChanged: (value) {
                                    Provider.of<themeChanger>(context,
                                            listen: false)
                                        .setTheme(value, 2);
                                  });
                            }),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * .015,
                      ),
                      Row(
                        children: [
                          Radio(
                            value: gender[0],
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                          ),
                          const Text(
                            'Male',
                            textScaleFactor: 1.0,
                          ),
                          Radio(
                            value: gender[1],
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                          ),
                          const Text(
                            'Female',
                            textScaleFactor: 1.0,
                          ),
                          Radio(
                            value: gender[2],
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                          ),
                          const Text(
                            'Other',
                            textScaleFactor: 1.0,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .005,
                      ),
                      MaterialBtn(
                          title: 'Submit',
                          color: AppColors.primaryColor,
                          materialCallBack: () async {
                            if (_gender == null || _gender!.isEmpty) {
                              Utils.snackBarMessage(
                                  'Please select gender', context);
                            } else if (_form.currentState!.validate()) {
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? phonewithHyphens =
                                  formattedNumber ?? prefs.getString('phone');
                              if (kDebugMode) {
                                print('$phonewithHyphens');
                              }
                              final String? id = prefs.getString('id');
                              final String? userTOKEN =
                                  prefs.getString('access_token');
                              final String? address =
                                  prefs.getString('residency');
                              final String? city = prefs.getString('city');
                              final String? state = prefs.getString('state');
                              final String? country =
                                  prefs.getString('country');
                              final String? zipCode =
                                  prefs.getString('zipcode');
                              final String? maritalStatus =
                                  prefs.getString('marital_status');
                              Map<String, String> header = {
                                "Oauthtoken": "Bearer $userTOKEN"
                              };
                              Map data = {
                                'id': id.toString(),
                                'first_name':
                                    firstNameController?.text.toString(),
                                'last_name':
                                    lastNameController?.text.toString(),
                                'address': address.toString(),
                                'country': country.toString(),
                                'phone': phonewithHyphens.toString(),
                                'city': city.toString(),
                                'state': state.toString(),
                                'zipcode': zipCode.toString(),
                                'birthdate':
                                    birthdateController?.text.toString(),
                                'marital_status': /*MaritalStatus.toString() ??*/
                                    '0',
                                'gender': _gender.toString(),
                                'type': 'patient'
                              };
                              if (!context.mounted) return;
                              final profileVM = Provider.of<ProfileViewModel>(
                                  context,
                                  listen: false);
                              if (!context.read<ProfileViewModel>().loading) {
                                profileVM.updateProfileApi(
                                    data, header, context);
                              } else {
                                Utils.snackBarMessage('Please wait..', context);
                              }
                            }
                          }),
                      SizedBox(
                        height: height * .005,
                      ),
                      MaterialBtn(
                          title: 'Change Password',
                          color: AppColors.primaryColor,
                          materialCallBack: () {
                            Navigator.pushNamed(
                                context, RoutesName.changePassword);
                          }),
                      SizedBox(
                        height: height * .005,
                      ),
                      MaterialBtn(
                          title: 'Delete My Account',
                          color: Colors.red,
                          materialCallBack: () async {
                            final result = await Navigator.pushNamed(
                                context, RoutesName.deleteProfile);
                            if (!context.mounted) return;
                            if (result == '1122') {
                              context.read<ChangePasswordVM>().setStatus('');
                            }
                          }),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  InputDecoration buildInputDecoration(BuildContext context, String? hint) {
    return InputDecoration(
      isDense: true,
      fillColor: Theme.of(context).cardColor,
      filled: true,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffE4E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
