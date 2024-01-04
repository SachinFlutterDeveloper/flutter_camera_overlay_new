import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/views/social_login/social_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoogleSignup extends StatefulWidget {
  final bool isApple;
  final String? appleName;
  final String? applelName;
  final String? appleEmail;
  final String? isStart;
  const GoogleSignup({
    Key? key,
    this.isApple = false,
    this.appleName = '',
    this.appleEmail = '',
    this.isStart,
    this.applelName,
  }) : super(key: key);

  @override
  State<GoogleSignup> createState() => _GoogleSignupState();
}

class _GoogleSignupState extends State<GoogleSignup> {
  String firstName = '';
  String email = '';
  @override
  void initState() {
    if (!widget.isApple) {
      firstName = FirebaseAuth.instance.currentUser!.displayName.toString();
      email = FirebaseAuth.instance.currentUser!.email.toString();
    }
    super.initState();
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
                frstName: (widget.isApple) ? widget.appleName : firstName,
                email: (widget.isApple) ? widget.appleEmail : email,
                lastName: (widget.isApple) ? widget.applelName : '',
                isHome: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
