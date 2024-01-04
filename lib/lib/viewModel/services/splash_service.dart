import 'package:digihealthcardapp/models/user_model.dart';
import 'package:digihealthcardapp/viewModel/user_view_model.dart';
import 'package:digihealthcardapp/views/auth/login_view.dart';
import 'package:digihealthcardapp/views/social_login/signup_with_google.dart';
import 'package:digihealthcardapp/views/splash_screen/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SplashService {
  Future<user> getUserData() => User_view_model().getUser();

  checkAuth(BuildContext context) {
    getUserData().then((value) {
      if (kDebugMode) {
        print(value.isApproved.toString());
      }
      if (value.id == 'null' || value.id == '') {
        return const LoginScreen();
        // await Navigator.pushNamed(context, RoutesName.login);
      } else {
        return const SplashScreen();
      }
    });
  }

  checkingState() {
    return StreamBuilder(
        stream: getUserData().asStream(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.data?.id == 'null' || snapshot.data?.id == '') {
            // print(snapshot.data?.id);
            return const LoginScreen();
          } else if (snapshot.data?.isApproved == '0') {
            //print(snapshot.data?.isApproved.toString());
            return GoogleSignup(
              isApple: true,
              appleName: (snapshot.data?.firstName == 'null')
                  ? ''
                  : snapshot.data?.firstName,
              appleEmail:
                  (snapshot.data?.email == 'null') ? '' : snapshot.data?.email,
            );
          } else {
            return const SplashScreen();
          }
        });
  }
}
