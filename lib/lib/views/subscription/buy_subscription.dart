import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/generated/assets.dart';
import 'package:digihealthcardapp/models/custom_border.dart';
import 'package:digihealthcardapp/models/subscription_package.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/views/subscription/viewmodels/subscription_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/widgets/appbar_leading.dart';

class BuySubscription extends StatefulWidget {
  final PackageObject item;
  const BuySubscription({
    super.key,
    required this.item,
  });

  @override
  State<BuySubscription> createState() => _BuySubscriptionState();
}

class _BuySubscriptionState extends State<BuySubscription> {
  //list of products
  late final List<ProductDetails> _products = <ProductDetails>[];

  //list of product ids
  late final List<ProductId> _productIds;

  //Subscription confirmation variable
  bool isSubscribed = false;

  //purchase Stream
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  //inAppPurchase instance(

  IApEngine iApEngine = IApEngine();

  //Purchase stream to listen to the purchase updates

  @override
  void initState() {
    final purchaseUpdated = iApEngine.inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      listenPurchaseUpdates(purchaseDetailsList);
    }, onDone: () {
      DialogBoxes.cancelLoading();
      _subscription.cancel();
    }, onError: (error, stacktrace) {
      DialogBoxes.cancelLoading();
      _subscription.cancel();
      debugPrint('$error $stacktrace');
    });
    getProducts();
    super.initState();
  }

  Future<void> listenPurchaseUpdates(
      List<PurchaseDetails> purchasesList) async {
    if (purchasesList.isNotEmpty) {
      debugPrint('listening to purchase stream');

      for (PurchaseDetails purchaseDetails in purchasesList) {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          debugPrint('status: ${purchaseDetails.status.toString()}');
          DialogBoxes.showLoadingNoTimer();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          DialogBoxes.cancelLoading();
          debugPrint(
              'Purchased: ${purchaseDetails.verificationData.source.toString()}'
              '  ${purchaseDetails.purchaseID.toString()}'
              ' ${purchaseDetails.status.toString()}'
              ' ${purchaseDetails.error.toString()} '
              '${purchaseDetails.purchaseID.toString()}');

          if (Platform.isAndroid) {
            Map purchasedData = jsonDecode(
                purchaseDetails.verificationData.localVerificationData);
            if (purchasedData['acknowledged']) {
              if (kDebugMode) {
                print('restore purchase: $purchasedData');
              }
            } else {
              if (kDebugMode) {
                print('first time purchase : $purchasedData');
              }
              if (Platform.isAndroid) {
                final InAppPurchaseAndroidPlatformAddition
                    androidPlatformAddition = iApEngine.inAppPurchase
                        .getPlatformAddition<
                            InAppPurchaseAndroidPlatformAddition>();
                final token = purchasedData['purchaseToken'];
                if (token != null || token.isNotEmpty) {
                  await _verifySub(context, token.toString(),
                      purchaseDetails.verificationData.source.toString());
                }
                await androidPlatformAddition.consumePurchase(purchaseDetails);
              }
            }
          } else if (Platform.isIOS) {
            if (!context.mounted) return;
            var purchaseID = purchaseDetails.purchaseID;
            if (purchaseDetails is AppStorePurchaseDetails) {
              final originalTransaction =
                  purchaseDetails.skPaymentTransaction.originalTransaction;
              if (originalTransaction != null) {
                purchaseID = originalTransaction.transactionIdentifier;
              }
            }
            final subscriptionId = purchaseID;
            debugPrint(subscriptionId.toString());
            if (subscriptionId != null || subscriptionId!.isNotEmpty) {
              if (!context.mounted) return;
              await _verifySub(context, subscriptionId.toString(),
                  purchaseDetails.verificationData.source.toString());
            }
          }
        } else {
          DialogBoxes.cancelLoading();
          debugPrint(purchaseDetails.status.toString());
          await iApEngine.inAppPurchase.completePurchase(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          debugPrint(purchaseDetails.pendingCompletePurchase.toString());
          await iApEngine.inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  static late SKPaymentQueueWrapper _skPaymentQueueWrapper;

  Future<void> _clearPendingPurchases() async {
    if (Platform.isIOS) {
      try {
        _skPaymentQueueWrapper = SKPaymentQueueWrapper();
        final transactions = await _skPaymentQueueWrapper.transactions();
        for (final transaction in transactions) {
          try {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
          } catch (e) {
            debugPrint("Error clearing pending purchases::in::loop");
            debugPrint(e.toString());
            rethrow;
          }
        }
      } catch (e) {
        debugPrint("Error clearing pending purchases");
        debugPrint(e.toString());
        rethrow;
      }
    }
  }

  void getProducts() async {
    DialogBoxes.showLoadingNoTimer();
    if (Platform.isAndroid) {
      _productIds = <ProductId>[
        ProductId(id: widget.item.androidPkgId, isConsumable: false)
      ];
    } else if (Platform.isIOS) {
      _productIds = <ProductId>[
        ProductId(id: widget.item.appstorePkgId, isConsumable: false)
      ];
    }
    await iApEngine.getIsAvailable().then((available) async {
      if (available) {
        await iApEngine.queryProducts(_productIds).then((res) {
          DialogBoxes.cancelLoading();
          debugPrint('Not found: ${res.notFoundIDs}');
          _products.clear();
          debugPrint('Prod: ${res.productDetails}');
          debugPrint('error ${res.error.toString()}');
          setState(() {
            _products.addAll(res.productDetails);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return DrawerWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'DigiHealthCard Subscription',
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
                    Assets.assetsHome,
                  ),
                  color: AppColors.primaryColor,
                )),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              shape: const CustomShapeBorder(radius: 10),
              elevation: 5,
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.item.packageName.toString()} Plan',
                          textScaleFactor: 1.0,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Package Name',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14),
                                      ),
                                      Text(widget.item.packageName,
                                          textScaleFactor: 1.0,
                                          style: const TextStyle(fontSize: 16)),
                                    ]),
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Package Mode',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14),
                                      ),
                                      Text(widget.item.pkgMode,
                                          textScaleFactor: 1.0,
                                          style: const TextStyle(fontSize: 16)),
                                    ]),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 60,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Package Type',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14),
                                      ),
                                      Text(widget.item.pkgType,
                                          textScaleFactor: 1.0,
                                          style: const TextStyle(fontSize: 16)),
                                    ]),
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Package Amount',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14),
                                      ),
                                      Text('US\$ ${widget.item.amount}',
                                          textScaleFactor: 1.0,
                                          style: const TextStyle(fontSize: 16)),
                                    ]),
                              ],
                            ),
                          ],
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Message',
                                textScaleFactor: 1.0,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 14),
                              ),
                              Text(
                                  'This subscription package will renew after ${widget.item.durationMonth} month(s)',
                                  textScaleFactor: 1.0,
                                  style: const TextStyle(fontSize: 16)),
                            ]),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: InkWell(
                onTap: () {
                  iApEngine.handlePurchase(_products[0], _productIds);
                  //DialogBoxes.showLoadingWithDuration(4000);
                  // DialogBoxes.showLoadingNoTimer();
                },
                child: Ink(
                  width: width * .7,
                  height: height * .05,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('Subscribe Now',
                        textScaleFactor: 1.0,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifySub(
      BuildContext context, String purchaseToken, String platform) async {
    final subscriptionVM =
        Provider.of<SubscriptionViewModel>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    //final plat = (Platform.isAndroid) ? 'android' : 'appstore';
    final pkgId = widget.item.id;
    String? userToken = prefs.getString('access_token');
    debugPrint('$platform $pkgId $purchaseToken ${prefs.getString('id')} ');

    Map<String, String> inAppData = {
      'patient_id': prefs.getString('id').toString(),
      'package_id': pkgId.toString(),
      'payment_from': platform.toString(),
      'subscription_id': purchaseToken.toString(),
    };
    Map<String, String> header = {'Oauthtoken': 'Bearer $userToken'};
    if (!context.mounted) return;
    await subscriptionVM.verifySubscription(
        context, header, inAppData, widget.item.packageName);
  }
}
