import 'dart:async';
import 'dart:convert';

import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/viewModel/check_expiry.dart';
import 'package:digihealthcardapp/views/subscription/viewmodels/subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/widgets/appbar_leading.dart';
import 'widgets/list_error_widget.dart';
import 'widgets/subscribed_package.dart';
import 'widgets/subscription_package_builder.dart';

class SubscriptionPlans extends StatefulWidget {
  const SubscriptionPlans({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlans> createState() => _SubscriptionPlansState();
}

class _SubscriptionPlansState extends State<SubscriptionPlans>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController tabController;

  @override
  void initState() {
    fetchSubData();
    context.read<SubscriptionViewModel>().fetchPlans(context);
    WidgetsBinding.instance.addObserver(this);
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  IApEngine iApEngine = IApEngine();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        context.read<CheckExpiry>().checkExpiry(context, true);

        /// Call your method when the screen is resumed
        // _checkSubscriptionStatus();
      }
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    final addition = iApEngine.inAppPurchase
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final purchases = await addition.queryPastPurchases();
    // Process the purchase details to determine the subscription status
    // The response contains a list of PurchaseDetails
    if (!context.mounted) return;
    // if(purchases.pastPurchases.isEmpty){
    //   context.read<SubscriptionViewModel>().cancelSubscription(context);
    // }
    for (PurchaseDetails purchase in purchases.pastPurchases) {
      Map purchasedData =
          jsonDecode(purchase.verificationData.localVerificationData);
      debugPrint(
          'subscription: ${purchase.status} ${purchasedData['purchaseToken']}');
      if (purchasedData['purchaseToken'] == OnePref.getString('sub_id') &&
          purchase.status == PurchaseStatus.canceled) {
        context.read<SubscriptionViewModel>().cancelSubscription(context);
      }
    }
  }

  String? billing;
  String? expStatus;
  String? subName;
  String? subMode;
  String? subType;
  String? subAmount;
  String? subStart;
  String? subEnd;
  String? subMessage;
  Future<void> fetchSubData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    billing = prefs.getString('billing').toString();
    subName = prefs.getString('sub_name').toString();
    expStatus = prefs.getString('trial_status').toString();
    subStart = prefs.getString('start_date').toString();
    subEnd = prefs.getString('end_date').toString();
    subMode = prefs.getString('sub_mode').toString();
    subAmount = prefs.getString('sub_amount').toString();
    subType = prefs.getString('sub_type').toString();
    subMessage = prefs.getString('sub_message').toString();
    setState(() {});
  }

  @override
  void dispose() {
    tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Subscription Packages',
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            leadingWidth: 80,
            leading: AppbarLeading(backCallBack: () => Navigator.pop(context)),
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
          body: (OnePref.getString('sub_name').toString() == 'null' ||
                  OnePref.getString('sub_name')!.isEmpty)
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, right: 10.0, left: 10.0),
                    child: Column(
                      children: [
                        Card(
                          // margin: EdgeInsets.symmetric(horizontal: 20),
                          clipBehavior: Clip.antiAlias,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          child: TabBar(
                            splashBorderRadius:
                                const BorderRadius.all(Radius.circular(25)),
                            padding: EdgeInsets.zero,
                            indicatorWeight: 3.0,
                            controller: tabController,
                            labelColor: Colors.white,
                            tabAlignment: TabAlignment.start,
                            indicatorPadding:
                                const EdgeInsets.symmetric(horizontal: -18),
                            unselectedLabelColor: AppColors.primaryColor,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: AppColors.primaryColor),
                            isScrollable: true,
                            // labelPadding: const EdgeInsets.symmetric(horizontal: 30),
                            tabs: const <Widget>[
                              Tab(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.man),
                                      Text(
                                        "Individual",
                                        textScaleFactor: 1.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Tab(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.family_restroom),
                                      Text(
                                        "Family",
                                        textScaleFactor: 1.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Consumer<SubscriptionViewModel>(
                              builder: (context, value, child) {
                            if (value.getSelfPlans.isEmpty) {
                              return (!value.isLoading)
                                  ? (value.error.isEmpty)
                                      ? const Center(
                                          child: Text(
                                              'No subscription plans available'))
                                      : ListErrorWidget(
                                          error: value.error.toString())
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    );
                            } else {
                              return TabBarView(
                                  controller: tabController,
                                  children: [
                                    RefreshIndicator(
                                      onRefresh: () async {},
                                      child: SubscriptionPackageBuilder(
                                          plans: value.getSelfPlans,
                                          width: width,
                                          height: height),
                                    ),
                                    RefreshIndicator(
                                      onRefresh: () async {},
                                      child: SubscriptionPackageBuilder(
                                          plans: value.getFamilyPlans,
                                          width: width,
                                          height: height),
                                    )
                                  ]);
                            }
                          }),
                        )
                      ],
                    ),
                  ),
                )
              : SubscribedPackage(
                  pkgName: subName.toString(),
                  pkgMode: subMode.toString(),
                  pkgType: subType.toString(),
                  pkgMessage: subMessage.toString(),
                  pkgEnd: subEnd.toString(),
                  pkgStart: subStart.toString(),
                  pkgAmount: subAmount.toString(),
                ),
        ),
      ),
    );
  }
}
