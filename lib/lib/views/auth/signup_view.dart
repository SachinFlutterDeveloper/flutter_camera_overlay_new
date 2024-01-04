import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../res/components/round_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  var password = '';
  var confirmPass = '';
  var email = '';
  var fName = '';
  var lName = '';
  var formattedNumber = '';

  late FocusNode firstNameFocusNode;
  late FocusNode lastNameFocusNode;
  late FocusNode emailFocusNode;
  late FocusNode phoneFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode retypepasswordFocusNode;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  // late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController retypepasswordController;

  var phoneController = MaskedTextController(mask: '000-000-0000');

  @override
  void initState() {
    super.initState();
    firstNameFocusNode = FocusNode();
    lastNameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    retypepasswordFocusNode = FocusNode();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    retypepasswordController = TextEditingController();
    // phoneController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    retypepasswordFocusNode.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    retypepasswordController.dispose();
    // phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final authViewMode = Provider.of<AuthViewModel>(context);

    return WillPopScope(
      onWillPop: () {
        context.read<AuthViewModel>().setCheckBox(false);
        context.read<AuthViewModel>().setCheckBoxTerms(false);
        context.read<AuthViewModel>().setCheckBoxSec(false);
        context.read<AuthViewModel>().setCheckBoxSub(false);
        return Future(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            'Registration',
            textScaleFactor: 1.0,
            style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
            child: SingleChildScrollView(
              child: Form(
                key: _form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: RichText(
                            textScaleFactor: 1.0,
                            text: TextSpan(
                              style: const TextStyle(
                                  color: AppColors.primaryColor, fontSize: 16),
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
                          style: TextStyle(
                              fontSize:
                                  16 / MediaQuery.textScaleFactorOf(context)),
                          onTapOutside: (event) {
                            firstNameFocusNode.unfocus();
                          },
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
                          onFieldSubmitted: (value) {
                            Utils.fieldFocusChange(
                                context, firstNameFocusNode, lastNameFocusNode);
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
                                  color: AppColors.primaryColor, fontSize: 16),
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
                          style: TextStyle(
                              fontSize:
                                  16 / MediaQuery.textScaleFactorOf(context)),
                          onTapOutside: (event) {
                            lastNameFocusNode.unfocus();
                          },
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
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
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
                          onFieldSubmitted: (value) {
                            Utils.fieldFocusChange(
                                context, lastNameFocusNode, emailFocusNode);
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
                                  color: AppColors.primaryColor, fontSize: 16),
                              children: [
                                const TextSpan(text: 'Email'),
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
                          focusNode: emailFocusNode,
                          controller: emailController,
                          onTapOutside: (event) {
                            emailFocusNode.unfocus();
                          },
                          onChanged: (value) {
                            email = value;
                          },
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "This field is required";
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(
                              fontSize:
                                  16 / MediaQuery.textScaleFactorOf(context)),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
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
                          onFieldSubmitted: (value) {
                            Utils.fieldFocusChange(
                                context, emailFocusNode, phoneFocusNode);
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
                                  color: AppColors.primaryColor, fontSize: 16),
                              children: [
                                const TextSpan(text: 'Phone Number'),
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
                        IntlPhoneField(
                          inputFormatters: const [],
                          focusNode: phoneFocusNode,
                          controller: phoneController,
                          style: TextStyle(
                              fontSize:
                                  16 / MediaQuery.textScaleFactorOf(context)),
                          keyboardType: TextInputType.number,
                          autofocus: false,
                          disableLengthCheck: true,
                          flagsButtonMargin:
                              const EdgeInsets.symmetric(horizontal: 5),
                          flagsButtonPadding: const EdgeInsets.all(5),
                          dropdownTextStyle: TextStyle(
                              fontSize:
                                  16 / MediaQuery.textScaleFactorOf(context)),
                          decoration: InputDecoration(
                            isDense: true,
                            enabled: true,
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
                          initialCountryCode: 'US',
                          onChanged: (phone) {
                            final phone0 = phone.number;
                            formattedNumber = DialogBoxes.formatPhoneNumber(
                              phone.countryCode,
                              phone0,
                            );
                            phoneController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: phoneController.text.length));
                            if (kDebugMode) {
                              print(formattedNumber);
                            }
                          },
                          onSaved: (phone) {
                            final phone_ = phone?.number;
                            formattedNumber = DialogBoxes.formatPhoneNumber(
                              phone!.countryCode.toString(),
                              '$phone_',
                            );
                            if (kDebugMode) {
                              print('saved: $formattedNumber');
                            }
                          },
                          onSubmitted: (value) {
                            Utils.fieldFocusChange(
                                context, phoneFocusNode, passwordFocusNode);
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
                                  color: AppColors.primaryColor, fontSize: 16),
                              children: [
                                const TextSpan(text: 'Password'),
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
                          focusNode: passwordFocusNode,
                          controller: passwordController,
                          style: TextStyle(
                              fontSize:
                                  16 / MediaQuery.textScaleFactorOf(context)),
                          obscureText: true,
                          onTapOutside: (event) {
                            passwordFocusNode.unfocus();
                          },
                          onChanged: (value) {
                            password = value;
                          },
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "Please Enter New Password";
                            } else if (value != null && value.length < 6) {
                              return "Password must be atleast 6 characters long";
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
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
                          onFieldSubmitted: (value) {
                            Utils.fieldFocusChange(context, passwordFocusNode,
                                retypepasswordFocusNode);
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
                                  color: AppColors.primaryColor, fontSize: 16),
                              children: [
                                const TextSpan(text: 'RetypePassword'),
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
                          focusNode: retypepasswordFocusNode,
                          controller: retypepasswordController,
                          style: TextStyle(
                              fontSize:
                                  16 / MediaQuery.textScaleFactorOf(context)),
                          onTapOutside: (event) {
                            retypepasswordFocusNode.unfocus();
                          },
                          obscureText: true,
                          onChanged: (value) {
                            confirmPass = value;
                          },
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "Please Enter New Password";
                            } else if (value != null && value.length < 6) {
                              return "Password must be atleast 6 characters long";
                            } else if (value != confirmPass) {
                              return 'Does not match';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
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
                    RichText(
                      textScaleFactor: 1.0,
                      text: TextSpan(
                        style: const TextStyle(
                            color: AppColors.primaryColor, fontSize: 16),
                        children: [
                          const TextSpan(
                              text: 'Required Acceptance  (Click to accept)'),
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
                    Consumer<AuthViewModel>(builder: (context, value, child) {
                      return CheckboxListTile(
                        value: value.checkBoxValue,
                        onChanged: (val) {
                          value.setCheckBox(val!);
                        },
                        subtitle: !value.checkBoxValue
                            ? const Text(
                                'Required',
                                textScaleFactor: 1.0,
                                style: TextStyle(color: Colors.red),
                              )
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.green,
                        title: GestureDetector(
                            onTap: () async {
                              var url = OnePref.getString('privacy_policy') ??
                                  'https://digihealthcard.com/privacy.php';
                              final uri = Uri.parse(url);
                              if (!await launchUrl(uri,
                                  mode: LaunchMode.platformDefault)) {
                                throw Exception('can not load $url');
                              }
                            },
                            child: const Text(
                              'Privacy and Policy',
                              textScaleFactor: 1.0,
                              style: TextStyle(color: Colors.blue),
                            )),
                      );
                    }),
                    Consumer<AuthViewModel>(builder: (context, value, child) {
                      return CheckboxListTile(
                        value: value.checkBoxValueTerms,
                        onChanged: (val) {
                          value.setCheckBoxTerms(val!);
                        },
                        subtitle: !value.checkBoxValueTerms
                            ? const Text(
                                'Required',
                                textScaleFactor: 1.0,
                                style: TextStyle(color: Colors.red),
                              )
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.green,
                        title: GestureDetector(
                            onTap: () async {
                              var url = OnePref.getString('terms') ??
                                  'https://digihealthcard.com/terms.php';
                              final uri = Uri.parse(url);
                              if (!await launchUrl(uri,
                                  mode: LaunchMode.platformDefault)) {
                                throw Exception('can not load $url');
                              }
                            },
                            child: const Text(
                              'Terms and Conditions',
                              textScaleFactor: 1.0,
                              style: TextStyle(color: Colors.blue),
                            )),
                      );
                    }),
                    Consumer<AuthViewModel>(builder: (context, value, child) {
                      return CheckboxListTile(
                        value: value.checkBoxValueSub,
                        onChanged: (val) {
                          value.setCheckBoxSub(val!);
                        },
                        subtitle: !value.checkBoxValueSub
                            ? const Text(
                                'Required',
                                textScaleFactor: 1.0,
                                style: TextStyle(color: Colors.red),
                              )
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.green,
                        title: GestureDetector(
                          onTap: () async {
                            var url = OnePref.getString('sub_policy') ??
                                'https://digihealthcard.com/app/patient/subscription_policy';
                            final uri = Uri.parse(url);
                            if (!await launchUrl(uri,
                                mode: LaunchMode.platformDefault)) {
                              throw Exception('can not load $url');
                            }
                          },
                          child: RichText(
                            textScaleFactor: 1.0,
                            text: TextSpan(
                              style: const TextStyle(
                                  color: AppColors.blue, fontSize: 16),
                              children: [
                                const TextSpan(text: 'Subscription Policy'),
                                WidgetSpan(
                                  child: Transform.translate(
                                    offset: const Offset(0.0, 1),
                                    child: Text(
                                      textScaleFactor: 1.0,
                                      OnePref.getString(
                                              'subscription_timeline') ??
                                          '',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    Consumer<AuthViewModel>(builder: (context, value, child) {
                      return CheckboxListTile(
                        value: value.checkBoxValueSec,
                        onChanged: (val) {
                          value.setCheckBoxSec(val!);
                        },
                        subtitle: !value.checkBoxValueSec
                            ? const Text(
                                'Required',
                                textScaleFactor: 1.0,
                                style: TextStyle(color: Colors.red),
                              )
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.green,
                        title: GestureDetector(
                            onTap: () async {
                              var url = OnePref.getString('security') ??
                                  'https://digihealthcard.com/app/patient/security';
                              final uri = Uri.parse(url);
                              if (!await launchUrl(uri,
                                  mode: LaunchMode.platformDefault)) {
                                throw Exception('can not load $url');
                              }
                            },
                            child: const Text(
                              'App Security',
                              textScaleFactor: 1.0,
                              style: TextStyle(color: Colors.blue),
                            )),
                      );
                    }),
                    SizedBox(
                      height: height * .03,
                    ),
                    RoundButton(
                        title: 'Submit',
                        onPress: () async {
                          final authModel = context.read<AuthViewModel>();
                          if (firstNameController.text.isEmpty) {
                            Utils.snackBarMessage(
                                'Please enter first name', context);
                          } else if (lastNameController.text.isEmpty) {
                            Utils.snackBarMessage(
                                'Please enter last name', context);
                          } else if (emailController.text.isEmpty) {
                            Utils.snackBarMessage(
                                'Please enter email', context);
                          } else if (phoneController.text.isEmpty) {
                            Utils.snackBarMessage(
                                'Please enter phone number', context);
                          } else if (passwordController.text.isEmpty) {
                            Utils.snackBarMessage(
                                'Please enter password', context);
                          } else if (passwordController.text.length < 6) {
                            Utils.snackBarMessage(
                                'Password should not be less than 6 digits',
                                context);
                          } else if (retypepasswordController.text.isEmpty) {
                            Utils.snackBarMessage(
                                'Please retype your password', context);
                          } else if (passwordController.text !=
                              retypepasswordController.text) {
                            Utils.snackBarMessage(
                                'Password does not match', context);
                          } else if (!authModel.checkBoxValue ||
                              !authModel.checkBoxValueSec ||
                              !authModel.checkBoxValueSub ||
                              !authModel.checkBoxValueTerms) {
                            Utils.snackBarMessage(
                                'Privacy and Terms acceptance is required',
                                context);
                          } else if (_form.currentState!.validate()) {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            final String? userToken =
                                prefs.getString('access_token');
                            await prefs.setString(
                                'phone', formattedNumber.toString());
                            final phone = prefs.getString('phone');
                            if (kDebugMode) {
                              print('saved: $phone');
                            }
                            await prefs.setString('first_name',
                                firstNameController.text.toString());
                            await prefs.setString('last_name',
                                lastNameController.text.toString());
                            await prefs.setString(
                                'password', passwordController.text.toString());
                            await prefs.setString(
                                'email', emailController.text.toString());
                            Map<String, String> header = {
                              "Oauthtoken": "Bearer $userToken"
                            };
                            Map data = {
                              'first_name': firstNameController.text.toString(),
                              'last_name': lastNameController.text.toString(),
                              'email': emailController.text.toString(),
                              'phone': formattedNumber.toString(),
                              'password': passwordController.text.toString()
                            };
                            if (!context.mounted) {
                              return;
                            }
                            authViewMode.signupApi(data, header, context);
                            debugPrint('Api hit $data $header');
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
