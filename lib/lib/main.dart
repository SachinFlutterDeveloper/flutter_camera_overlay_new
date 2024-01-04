import 'package:digihealthcardapp/firebase_options.dart';
import 'package:digihealthcardapp/repositories/cards_repo.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/utils/routes/routes.dart';
import 'package:digihealthcardapp/viewModel/Location_view_model.dart';
import 'package:digihealthcardapp/viewModel/Theme_view_model.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/viewModel/check_expiry.dart';
import 'package:digihealthcardapp/viewModel/child_view_model.dart';
import 'package:digihealthcardapp/viewModel/home_screen_model.dart';
import 'package:digihealthcardapp/viewModel/home_view_model.dart';
import 'package:digihealthcardapp/viewModel/immunization_model.dart';
import 'package:digihealthcardapp/viewModel/otp_model.dart';
import 'package:digihealthcardapp/viewModel/services/notification_service.dart';
import 'package:digihealthcardapp/viewModel/services/splash_service.dart';
import 'package:digihealthcardapp/viewModel/social_view_model.dart';
import 'package:digihealthcardapp/viewModel/user_view_model.dart';
import 'package:digihealthcardapp/views/chat_ai/viewmodels/ai_chat.viewmodel.dart';
import 'package:digihealthcardapp/views/profile/viewmodels/change_password.viewmodel.dart';
import 'package:digihealthcardapp/views/profile/viewmodels/profile.viewmodel.dart';
import 'package:digihealthcardapp/views/scan_health_card/card_viewmodel.dart';
import 'package:digihealthcardapp/views/scan_id_card/show_cards_vm.dart';
import 'package:digihealthcardapp/views/subscription/viewmodels/subscription_viewmodel.dart';
import 'package:digihealthcardapp/views/test_results/repositories/test_result_repo.dart';
import 'package:digihealthcardapp/views/test_results/viewmodels/tests_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationHelper().initializeAwesomeNotification;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await OnePref.init();

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) => runApp(const DigiHealthCard()));
}

class DigiHealthCard extends StatefulWidget {
  const DigiHealthCard({super.key});

  @override
  State<DigiHealthCard> createState() => _DigiHealthCardState();
}

class _DigiHealthCardState extends State<DigiHealthCard> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocationViewModel()),
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => LocationProvider()),
          ChangeNotifierProvider(create: (_) => OTP_Model()),
          ChangeNotifierProvider(create: (_) => HomeModel()),
          ChangeNotifierProvider(create: (_) => User_view_model()),
          ChangeNotifierProvider(create: (_) => HomeViewModel()),
          ChangeNotifierProvider(create: (_) => themeChanger()),
          ChangeNotifierProvider(create: (_) => SocialViewModel()),
          ChangeNotifierProvider(create: (_) => VaccinationModel()),
          ChangeNotifierProvider(create: (_) => ChangePasswordVM()),
          ChangeNotifierProvider(create: (_) => SubscriptionViewModel()),
          ChangeNotifierProvider(create: (_) => CameraHelper()),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          ChangeNotifierProvider(create: (_) => ChildVM()),
          ChangeNotifierProvider(create: (_) => CardViewModel()),
          ChangeNotifierProvider(create: (_) => ChatAIViewModel()),
          ChangeNotifierProvider(create: (_) => CheckExpiry()),
          ChangeNotifierProvider(create: (_) => ShowCardsVM(CardsRepo())),
          ChangeNotifierProvider(
              create: (_) => ShowTestVM(TestResultRepository())),
        ],
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: appOverlayDarkIcons,
          child: Builder(builder: (BuildContext context) {
            final themeChangeModel = Provider.of<themeChanger>(context);
            themeChangeModel.loadTheme();
            return MaterialApp(
              scaffoldMessengerKey: AppKeys.rootScaffoldMessengerKey,
              debugShowCheckedModeBanner: false,
              themeMode: themeChangeModel.themeMode,
              theme: ThemeData(
                  appBarTheme: const AppBarTheme(
                      backgroundColor: AppColors.white,
                      titleTextStyle: TextStyle(color: AppColors.black)),
                  primaryColor: Colors.white,
                  scaffoldBackgroundColor: Colors.white,
                  primaryTextTheme: const TextTheme(
                      bodyMedium: TextStyle(color: Colors.black)),
                  brightness: Brightness.light,
                  cardColor: Colors.grey[200],
                  colorScheme: ColorScheme.fromSwatch()
                      .copyWith(
                          primary: AppColors.primary,
                          secondary: AppColors.primaryLightColor)
                      .copyWith(background: Colors.white)),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                cardColor: Colors.black,
                primaryColor: Colors.grey[800],
                scaffoldBackgroundColor: Colors.grey[800],
                primaryTextTheme:
                    const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
                appBarTheme: AppBarTheme(
                    backgroundColor: Colors.grey[800],
                    titleTextStyle: const TextStyle(color: Colors.white)),
                textTheme: const TextTheme(),
                colorScheme: ColorScheme.fromSwatch()
                    .copyWith(
                      brightness: Brightness.dark,
                      primary: AppColors.primary,
                      secondary: AppColors.primaryLightColor,
                    )
                    .copyWith(background: Colors.grey[800]),
              ),
              home: SplashService().checkingState(),
              builder: EasyLoading.init(),
              onGenerateRoute: Routes.generateRoute,
            );
          }),
        ));
  }
}
