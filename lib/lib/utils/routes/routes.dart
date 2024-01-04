import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/views/auth/forgot_password.dart';
import 'package:digihealthcardapp/views/auth/login_view.dart';
import 'package:digihealthcardapp/views/auth/otp_screen.dart';
import 'package:digihealthcardapp/views/auth/signup_view.dart';
import 'package:digihealthcardapp/views/child_immunization/child_immunization.dart';
import 'package:digihealthcardapp/views/dashboard/dashboard.dart';
import 'package:digihealthcardapp/views/dashboard/permission_description_view.dart';
import 'package:digihealthcardapp/views/profile/change_password.dart';
import 'package:digihealthcardapp/views/profile/delete_profile.dart';
import 'package:digihealthcardapp/views/profile/profile.dart';
import 'package:digihealthcardapp/views/scan_health_card/scan_card.dart';
import 'package:digihealthcardapp/views/scan_health_card/show_health_card.dart';
import 'package:digihealthcardapp/views/scan_id_card/id_card.dart';
import 'package:digihealthcardapp/views/scan_id_card/scan_id.dart';
import 'package:digihealthcardapp/views/splash_screen/splash_screen.dart';
import 'package:digihealthcardapp/views/subscription/subscription_plans.dart';
import 'package:digihealthcardapp/views/test_results/scan_test_result.dart';
import 'package:digihealthcardapp/views/test_results/show_test_result.dart';
import 'package:digihealthcardapp/views/test_results/test_location_view.dart';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splash:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen());

      case RoutesName.home:
        return MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(subscription: OnePref.getString('trail_status').toString(),));

      case RoutesName.login:
        return MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen());

      case RoutesName.signup:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SignUpScreen());

      case RoutesName.otp:
        return MaterialPageRoute(
            builder: (BuildContext context) => const OTPScreen(
                  isHome: false,
                ));

      case RoutesName.forgot:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ForgotPassword());

      case RoutesName.permissions:
        return MaterialPageRoute(
            builder: (BuildContext context) => const PermissionsScreen());

      case RoutesName.scanCard:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ScanCardScreen());

      case RoutesName.showID:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ShowIDScreen());

      case RoutesName.profile:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ProfileScreen());

      case RoutesName.test:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ShowTestResults());

      case RoutesName.showCard:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ShowHealthCards());

      case RoutesName.testLocation:
        return MaterialPageRoute(
            builder: (BuildContext context) => const TestLocationScreen());

      case RoutesName.scanID:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ScanIDScreen());

      case RoutesName.deleteProfile:
        return MaterialPageRoute(
            builder: (BuildContext context) => const DeleteProfile());

      case RoutesName.changePassword:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ChangePassword());

      case RoutesName.testScan:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ScanTestResult());

      case RoutesName.subscription:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SubscriptionPlans());

      case RoutesName.immunization:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ChildImmunization());

      default:
        return MaterialPageRoute(builder: (_) {
          return const Scaffold(
            body: Center(
              child: Text('No Routes Defined'),
            ),
          );
        });
    }
  }
}
