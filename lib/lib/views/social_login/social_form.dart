import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/components/round_button_light.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocialForm extends StatefulWidget {
  const SocialForm(
      {super.key,
      required this.frstName,
      required this.email,
      this.isHome,
      this.lastName});
  final String? frstName;
  final String? lastName;
  final bool? isHome;
  final String? email;
  @override
  State<SocialForm> createState() => _SocialFormState();
}

class _SocialFormState extends State<SocialForm> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  var eMail = '';
  var fName = '';
  var lName = '';
  var formattedNumber = '';
  String formatPhoneNumber(String phoneNumber) {
    // Remove any non-numeric characters from the phone number
    String digits = phoneNumber.replaceAll(RegExp(r'\D+'), '');
    // Check if the phone number is too short to format
    if (digits.length < 10) {
      return phoneNumber;
    }
    // Add the country code prefix
    String formatted = '+${digits.substring(0, 2)}-';

    // Add the area code
    formatted += '${digits.substring(2, 5)}-';

    // Add the first three digits of the phone number
    formatted += '${digits.substring(5, 8)}-';

    // Add the last four digits of the phone number
    formatted += digits.substring(8);

    return formatted;
  }

  late FocusNode firstNameFocusNode;
  late FocusNode lastNameFocusNode;
  late FocusNode emailFocusNode;
  late FocusNode phoneFocusNode;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;

  var phoneController = MaskedTextController(mask: '000-000-0000');

  @override
  void initState() {
    super.initState();
    firstNameFocusNode = FocusNode();
    lastNameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
    firstNameController = TextEditingController(text: widget.frstName);
    lastNameController = TextEditingController(
        text: (widget.lastName == 'null' || widget.lastName == null)
            ? ''
            : widget.lastName);
    emailController = TextEditingController(text: widget.email);
    // phoneController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewMode = Provider.of<AuthViewModel>(context);
    final height = MediaQuery.of(context).size.height * 1;

    final double scaleFactor = MediaQuery.of(context).textScaleFactor;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Color((Theme.of(context).brightness == Brightness.light)
                ? 0xffDDDDDD
                : 0xff263238),
            blurRadius: 6.0,
            spreadRadius: 2.0,
            offset: const Offset(0.0, 0.0),
          )
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 70),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Form(
        key: _form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Verification Required',
                    textScaleFactor: 1.0,
                  ),
                ),
                SizedBox(
                  height: height * .050,
                ),
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
                                  fontSize: 10, color: AppColors.primaryColor),
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
                    fillColor: Theme.of(context).cardColor,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffE4E7EB)),
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
                          color: AppColors.primaryColor, fontSize: 16),
                      children: [
                        const TextSpan(text: 'Last Name'),
                        WidgetSpan(
                          child: Transform.translate(
                            offset: const Offset(0.0, -7),
                            child: const Text(
                              '*',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.primaryColor),
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
                    isDense: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffE4E7EB)),
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
                          color: AppColors.primaryColor, fontSize: 16),
                      children: [
                        const TextSpan(text: 'Email'),
                        WidgetSpan(
                          child: Transform.translate(
                            offset: const Offset(0.0, -7),
                            child: const Text(
                              '*',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.primaryColor),
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
                  style: TextStyle(fontSize: 16 / scaleFactor),
                  onTapOutside: (event) {
                    emailFocusNode.unfocus();
                  },
                  onChanged: (value) {
                    eMail = value;
                  },
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return "This field is required";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).cardColor,
                    filled: true,
                    isDense: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffE4E7EB)),
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
                          color: AppColors.primaryColor, fontSize: 16),
                      children: [
                        const TextSpan(text: 'Phone Number'),
                        WidgetSpan(
                          child: Transform.translate(
                            offset: const Offset(0.0, -7),
                            child: const Text(
                              '*',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.primaryColor),
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
                  style: TextStyle(fontSize: 16 / scaleFactor),
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  disableLengthCheck: true,
                  // pickerDialogStyle: PickerDialogStyle(countryCodeStyle: TextStyle(fontSize: )),
                  flagsButtonMargin: const EdgeInsets.symmetric(horizontal: 5),
                  flagsButtonPadding: const EdgeInsets.all(5),
                  decoration: InputDecoration(
                    isDense: true,
                    enabled: true,
                    // prefixStyle: TextStyle(fontSize: 21),
                    // counterStyle: TextStyle(fontSize: 18, letterSpacing: 10, leadingDistribution: TextLeadingDistribution.even),
                    fillColor: Theme.of(context).cardColor,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffE4E7EB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  initialCountryCode: 'PK',
                  onChanged: (phone) {
                    final _phone = phone.number;
                    formattedNumber = DialogBoxes.formatPhoneNumber(
                        phone.countryCode, _phone);
                    // final SharedPreferences prefs = await SharedPreferences.getInstance();
                    // await prefs.setString('phone', _phone ?? '');
                    if (kDebugMode) {
                      print(formattedNumber);
                    }
                  },
                  onSaved: (phone) {
                    final phone_ = phone?.completeNumber;
                    formattedNumber = DialogBoxes.formatPhoneNumber(
                      phone!.countryCode,
                      phone.number,
                    );
                    // final SharedPreferences prefs = await SharedPreferences.getInstance();
                    // await prefs.setString('phone', formattedNumber ?? '');
                    if (kDebugMode) {
                      print('saved: $formattedNumber');
                    }
                  },
                  onSubmitted: (value) async {
                    phoneFocusNode.unfocus();
                  },
                ),
              ],
            ),
            SizedBox(
              height: height * .020,
            ),
            RichText(
              textScaleFactor: 1.0,
              text: TextSpan(
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
                children: [
                  const TextSpan(text: 'Mobile Number Format:'),
                  WidgetSpan(
                    child: Transform.translate(
                      offset: const Offset(0.0, 2),
                      child: const Text(
                        ' 123-123-1234',
                        textScaleFactor: 1.0,
                        style:
                            TextStyle(fontSize: 16, color: Colors.lightGreen),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height * .04,
            ),
            RoundButtonLight(
                title: 'Send OTP',
                onPress: () async {
                  if (firstNameController.text.isEmpty) {
                    Utils.snackBarMessage('Please enter first name', context);
                  } else if (lastNameController.text.isEmpty) {
                    Utils.snackBarMessage('Please enter last name', context);
                  } else if (emailController.text.isEmpty) {
                    Utils.snackBarMessage('Please enter email', context);
                  } else if (phoneController.text.isEmpty) {
                    Utils.snackBarMessage('Please enter phone number', context);
                  } else if (_form.currentState!.validate()) {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final String? UserToken = prefs.getString('access_token');
                    await prefs.setString('phone', formattedNumber.toString());
                    final phone = prefs.getString('phone');
                    if (kDebugMode) {
                      print('saved: $phone');
                    }
                    await prefs.setString(
                        'first_name', firstNameController.text.toString());
                    await prefs.setString(
                        'last_name', lastNameController.text.toString());
                    await prefs.setString(
                        'email', emailController.text.toString());
                    Map<String, String> header = {
                      "Oauthtoken": "Bearer $UserToken"
                    };
                    Map data = {
                      'first_name': firstNameController.text.toString(),
                      'last_name': lastNameController.text.toString(),
                      'email': emailController.text.toString(),
                      'phone': formattedNumber.toString(),
                    };
                    if (!context.mounted) {
                      return;
                    }
                    authViewMode.socialOTPApi(data, header, context, false);
                    if (kDebugMode) {
                      print('Api hit $data $header');
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }
}
