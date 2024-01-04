import 'package:digihealthcardapp/models/subscription_package.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/views/subscription/buy_subscription.dart';
import 'package:flutter/material.dart';

class SubscriptionPackageBuilder extends StatefulWidget {
  const SubscriptionPackageBuilder({
    super.key,
    required this.plans,
    required this.width,
    required this.height,
  });

  final List<PackageObject>? plans;
  final double width;
  final double height;

  @override
  State<SubscriptionPackageBuilder> createState() =>
      _SubscriptionPackageBuilderState();
}

class _SubscriptionPackageBuilderState
    extends State<SubscriptionPackageBuilder> {
  late TextEditingController freeCodeController;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ListView.builder(
      itemCount: widget.plans?.length,
      itemBuilder: (context, index) {
        final item = widget.plans![index];
        return Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
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
                      '${item.packageName} Plan',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Package Name',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text(item.packageName,
                                      textScaleFactor: 1.0,
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Package Mode',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text(item.pkgMode,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Package Type',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text(item.pkgMode,
                                      textScaleFactor: 1.0,
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Package Amount',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14),
                                  ),
                                  Text('US\$ ${item.amount}',
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
                              "${"""This subscription package will renew after\n${item.durationMonth}"""} month(s)",
                              textScaleFactor: 1.0,
                              style: const TextStyle(fontSize: 16)),
                        ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          if (item.id.isNotEmpty) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        BuySubscription(item: item)));
                          } else {
                            DialogBoxes.buyWithCode(
                                context, freeCodeController);
                          }
                        },
                        child: Ink(
                          width: widget.width * .7,
                          height: widget.height * .05,
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
              ],
            ),
          ),
        );
      },
    ));
  }

  @override
  void initState() {
    freeCodeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    freeCodeController.dispose();
    super.dispose();
  }
}
