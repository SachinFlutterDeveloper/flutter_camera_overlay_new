import 'dart:async';

import 'package:digihealthcardapp/models/custom_border.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/views/child_immunization/widgets/profile_card.dart';
import 'package:digihealthcardapp/views/profile/widgets/appbar_leading.dart';
import 'package:digihealthcardapp/views/test_results/viewmodels/tests_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'show_email_item.dart';
import 'show_test_item.dart';

class ShowTestResults extends StatefulWidget {
  const ShowTestResults({Key? key}) : super(key: key);

  @override
  State<ShowTestResults> createState() => _ShowTestResultsState();
}

class _ShowTestResultsState extends State<ShowTestResults> {
  @override
  void initState() {
    super.initState();
    context.read<ShowTestVM>().getTestsApi(context);
    Future.delayed(
      const Duration(milliseconds: 600),
      () => DialogBoxes.fetchEmailDialog(
        context,
        email,
        fetchEmail,
        () => context.read<ShowTestVM>().getEmailsApi(context),
      ),
    );
  }

  String email = 'example@email.com';
  String fetchEmail = 'testresults@digihealthcard.com';

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            // backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              'Test Results',
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            leadingWidth: 75,
            leading: AppbarLeading(backCallBack: () => Navigator.pop(context)),
            actions: [
              InkWell(
                onTap: () async {
                  final result =
                      await Navigator.pushNamed(context, RoutesName.testScan);
                  if (result == '1122') {
                    if (!context.mounted) return;
                    context.read<CameraHelper>().removeFrontImage();
                    context.read<ShowTestVM>().getTestsApi(context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Ink(
                    height: 8,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.primaryColor),
                    child: const Center(
                        child: Text(
                      'Add New',
                      textScaleFactor: 1.0,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    )),
                  ),
                ),
              ),
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
          body: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Consumer<ShowTestVM>(
                    builder: (context, value, child) {
                      if (value.getTests.isEmpty) {
                        return (!value.isLoading)
                            ? (value.error.isEmpty)
                                ? const Center(
                                    child: Text(
                                    'No test results available',
                                    textScaleFactor: 1.0,
                                  ))
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      Text(
                                        value.error.toString(),
                                        textScaleFactor: 1.0,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  )
                            : const Center(
                                child: CircularProgressIndicator(),
                              );
                      } else {
                        return RefreshIndicator(
                            onRefresh: () async {
                              await value.getTestsApi(context);
                            },
                            child: ListView.builder(
                              itemCount: value.getTests.length,
                              itemBuilder: (context, index) {
                                final item = value.getTests[index];
                                if ((item['result_type'] == 'manual')) {
                                  return ShowTestItem(
                                      testItem: item,
                                      removeTest: () => context
                                          .read<ShowTestVM>()
                                          .removeTestResult(context));
                                } else {
                                  return ShowEmailItem(
                                      emailItem: item,
                                      removeTestEmail: () => context
                                          .read<ShowTestVM>()
                                          .removeTestResult(context));
                                }
                              },
                            ));
                      }
                    },
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  shape: const CustomShapeBorder(radius: 10),
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          textScaleFactor: 1.0,
                          'Please send test results to the following email address.'
                          'After sending email please tap on sync email button to view'
                          'your test results inside the app.',
                          textAlign: TextAlign.start,
                        ),
                        InkWell(
                            onTap: () {
                              final emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: OnePref.getString('fetch_email') ??
                                    fetchEmail,
                              );
                              launchUrlString(emailLaunchUri.toString());
                            },
                            child: Text(
                              OnePref.getString('fetch_email').toString(),
                              textScaleFactor: 1.0,
                              style: const TextStyle(color: Colors.blueAccent),
                              textAlign: TextAlign.start,
                            )),
                        const Text(
                          'Please make sure you have to send your test results from the'
                          'email registered with your DigiHealthCard Health Wallet account.'
                          'Your registered email is:',
                          textScaleFactor: 1.0,
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          OnePref.getString('email').toString(),
                          textScaleFactor: 1.0,
                          style: const TextStyle(color: Colors.blueAccent),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          height: height * .008,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CardButton(
                              height: height * .040,
                              width: width * .38,
                              color: Colors.grey[900] ?? Colors.grey,
                              title: 'Done',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            CardButton(
                                title: 'Sync',
                                onPressed: () => context
                                    .read<ShowTestVM>()
                                    .getEmailsApi(context),
                                height: height * .040,
                                width: width * .38,
                                color: AppColors.primaryColor)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
