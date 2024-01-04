import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/views/social_login/social_form.dart';
import 'package:flutter/material.dart';

class FacebookSignUp extends StatefulWidget {
  final bool isHome;
  final Map<String, dynamic>? userData;
  const FacebookSignUp({Key? key, required this.userData, required this.isHome})
      : super(key: key);

  @override
  State<FacebookSignUp> createState() => _FacebookSignUpState();
}

class _FacebookSignUpState extends State<FacebookSignUp> {
  String? firstName;
  String? email;
  @override
  void initState() {
    super.initState();
    firstName = widget.userData?['name'];
    email = widget.userData?['email'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => DialogBoxes.onWillPopDialog(context, false, true),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => DialogBoxes.onWillPopDialog(context, false, true),
          ),
          backgroundColor: AppColors.primary,
          title: const Text('OTP verification',
              textScaleFactor: 1.0,
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500)),
        ),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
            child: SingleChildScrollView(
              child: SocialForm(
                  frstName: firstName, email: email, isHome: widget.isHome),
            ),
          ),
        ),
      ),
    );
  }
}
