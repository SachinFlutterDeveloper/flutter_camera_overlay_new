import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/views/profile/viewmodels/change_password.viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../res/components/round_button.dart';
import 'widgets/appbar_leading.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late FocusNode currentPassFocusNode;
  late FocusNode newPassFocusNode;
  late FocusNode confirmPassFocusNode;
  late TextEditingController currentPassController;
  late TextEditingController newpasswordController;
  late TextEditingController confirmpasswordController;

  var password = '';
  var currentPassword = '';
  var newPassword = '';

  @override
  void initState() {
    super.initState();
    currentPassFocusNode = FocusNode();
    confirmPassFocusNode = FocusNode();
    newPassFocusNode = FocusNode();
    currentPassController = TextEditingController();
    confirmpasswordController = TextEditingController();
    newpasswordController = TextEditingController();
  }

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final double scaleFactor = MediaQuery.of(context).textScaleFactor;

    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text(
                'Change Password',
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
            body: Form(
              key: _form,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'To reset password, enter your current password and new password below',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              focusNode: currentPassFocusNode,
                              controller: currentPassController,
                              style: TextStyle(fontSize: 16 / scaleFactor),
                              obscureText: true,
                              onTapOutside: (event) {
                                currentPassFocusNode.unfocus();
                              },
                              onChanged: (value) {
                                password = value;
                              },
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return "Please Enter Current Password";
                                } else if (value != null && value.length < 3) {
                                  return "Password must be at least 3 characters long";
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Current Password',
                                hintStyle:
                                    TextStyle(fontSize: 16 / scaleFactor),
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
                              onFieldSubmitted: (value) {
                                Utils.fieldFocusChange(context,
                                    currentPassFocusNode, newPassFocusNode);
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              focusNode: newPassFocusNode,
                              controller: newpasswordController,
                              style: TextStyle(fontSize: 16 / scaleFactor),
                              obscureText: true,
                              onChanged: (value) {
                                newPassword = value;
                              },
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return "Please Enter New Password";
                                } else if (value != null && value.length < 3) {
                                  return "Password must be at least 3 characters long";
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'New Password',
                                hintStyle:
                                    TextStyle(fontSize: 16 / scaleFactor),
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
                              onFieldSubmitted: (value) {
                                Utils.fieldFocusChange(context,
                                    newPassFocusNode, confirmPassFocusNode);
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              focusNode: confirmPassFocusNode,
                              controller: confirmpasswordController,
                              style: TextStyle(fontSize: 16 / scaleFactor),
                              obscureText: true,
                              onTapOutside: (event) {
                                confirmPassFocusNode.unfocus();
                              },
                              onChanged: (value) {
                                currentPassword = value;
                              },
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return "Please Confirm Password";
                                } else if (value != null && value.length < 3) {
                                  return "Password must be at least 3 characters long";
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Confirm New Password',
                                fillColor: Theme.of(context).cardColor,
                                filled: true,
                                hintStyle:
                                    TextStyle(fontSize: 16 / scaleFactor),
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
                            const SizedBox(
                              height: 30,
                            ),
                            RoundButton(
                                title: 'Submit',
                                onPress: () async {
                                  (_form.currentState?.validate());
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  final String? userToken =
                                      prefs.getString('access_token');
                                  final String? patientID =
                                      prefs.getString('id');
                                  Map<String, String> header = {
                                    "Oauthtoken": "Bearer $userToken"
                                  };
                                  Map data = {
                                    'patient_id': patientID.toString(),
                                    'old_password':
                                        currentPassController.text.toString(),
                                    'new_password':
                                        newpasswordController.text.toString(),
                                    'confirm_password':
                                        confirmpasswordController.text
                                            .toString(),
                                  };
                                  if (!context.mounted) {
                                    return;
                                  }
                                  final changePasswordVM =
                                      Provider.of<ChangePasswordVM>(context,
                                          listen: false);
                                  if (!context
                                      .read<ChangePasswordVM>()
                                      .loading) {
                                    changePasswordVM.changePasswordApi(
                                        data, header, context);
                                    if (kDebugMode) {
                                      print('Api hit ${data.values}');
                                    }
                                  }
                                  if (context
                                      .read<ChangePasswordVM>()
                                      .loading) {
                                    DialogBoxes.showLoading();
                                  }
                                })
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      var url = 'https://digihealthcard.com/';
                      final uri = Uri.parse(url);
                      if (!await launchUrl(uri,
                          mode: LaunchMode.platformDefault)) {
                        throw Exception('can not load $url');
                      }
                    },
                    child: Image.asset(
                      width: width,
                      height: height * .1,
                      'Assets/ad.png',
                      fit: BoxFit.fitHeight,
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
