// ignore_for_file: use_build_context_synchronously

import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../res/components/round_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  FocusNode emailFocusNode = FocusNode();
  late TextEditingController emailController;
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    emailFocusNode = FocusNode();
  }

  final GlobalKey<FormState> _formforgot = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final authViewMode = Provider.of<AuthViewModel>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            'Forgot Password',
            textScaleFactor: 1.0,
            style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500),
          ),
        ),
        body: Form(
          key: _formforgot,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Center(
                    child: Text(
                  'To reset your password, enter your email address below',
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                )),
                SizedBox(
                  height: height * .030,
                ),
                TextFormField(
                  focusNode: emailFocusNode,
                  controller: emailController,
                  style: TextStyle(
                      fontSize: 16 / MediaQuery.textScaleFactorOf(context)),
                  keyboardType: TextInputType.emailAddress,
                  onTapOutside: (event) {
                    emailFocusNode.unfocus();
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Email Address',
                    hintStyle: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16 / MediaQuery.textScaleFactorOf(context)),
                    fillColor: Theme.of(context).cardColor,
                    filled: true,
                    prefixIcon: const Icon(Icons.email_outlined),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffE4E7EB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * .010,
                ),
                const Center(
                    child: Text(
                  'Your password will be sent on your email address.',
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.center,
                )),
                SizedBox(
                  height: height * .020,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: RoundButton(
                      title: 'Submit',
                      onPress: () async {
                        if (emailController.text.isEmpty) {
                          Utils.snackBarMessage('Please enter email', context);
                        } else if (_formforgot.currentState!.validate()) {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          final String? userToken =
                              prefs.getString('access_token');
                          Map<String, String> header = {
                            "Oauthtoken": "Bearer $userToken"
                          };
                          Map data = {
                            'email': emailController.text.toString(),
                            'username': emailController.text.toString(),
                            'type': 'patient',
                            'hospital_id': '13'
                          };
                          if (!context.read<AuthViewModel>().otpLoading) {
                            authViewMode.forgotPassApi(data, header, context);
                          } else {
                            Utils.snackBarMessage('Please wait..', context);
                          }
                          if (kDebugMode) {
                            print('Api hit $data');
                          }
                        }
                      }),
                )
              ],
            ),
          ),
        ));
  }
}
