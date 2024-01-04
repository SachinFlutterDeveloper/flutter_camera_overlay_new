import 'package:digihealthcardapp/models/custom_border.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/views/profile/widgets/appbar_leading.dart';
import 'package:digihealthcardapp/views/subscription/viewmodels/subscription_viewmodel.dart';
import 'package:digihealthcardapp/views/subscription/widgets/list_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../res/colors.dart';
import '../../utils/routes/routes_name.dart';
import 'models/invoice_model.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  @override
  void initState() {
    context.read<SubscriptionViewModel>().fetchInvoices(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Payment Invoices',
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              leadingWidth: 80,
              leading:
                  AppbarLeading(backCallBack: () => Navigator.pop(context)),
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
            body: Consumer<SubscriptionViewModel>(
              builder: (context, value, child) {
                if (value.invoices.isEmpty) {
                  return (!value.isLoading)
                      ? (value.error.isEmpty)
                          ? const Center(child: Text('No invoices available'))
                          : ListErrorWidget(error: value.error.toString())
                      : const Center(
                          child: CircularProgressIndicator(),
                        );
                } else {
                  return InvoiceListBuilder(
                    invoices: value.invoices,
                    height: MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width,
                  );
                }
              },
            )),
      ),
    );
  }
}

class InvoiceListBuilder extends StatelessWidget {
  const InvoiceListBuilder({
    super.key,
    required this.invoices,
    required this.width,
    required this.height,
  });

  final List<Invoice> invoices;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final item = invoices[index];
          return Card(
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
                      const Text(
                        'Your payment invoice',
                        textScaleFactor: 1.0,
                        style: TextStyle(
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
                                      'Date',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14),
                                    ),
                                    Text(item.dateof,
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
                                      'Amount',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14),
                                    ),
                                    Text('US\$ ${item.amount}',
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
                            Text(item.message,
                                textScaleFactor: 1.0,
                                style: const TextStyle(fontSize: 16)),
                          ]),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
