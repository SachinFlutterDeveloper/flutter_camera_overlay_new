import 'package:digihealthcardapp/res/app_url.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/views/scan_id_card/show_cards_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile/widgets/appbar_leading.dart';
import 'widgets/empty_cards_list_widget.dart';
import 'widgets/show_card_item.dart';

class ShowHealthCards extends StatefulWidget {
  const ShowHealthCards({Key? key}) : super(key: key);

  @override
  State<ShowHealthCards> createState() => _ShowHealthCardsState();
}

class _ShowHealthCardsState extends State<ShowHealthCards> {
  @override
  void initState() {
    Provider.of<ShowCardsVM>(context, listen: false).getCardsApi(context, true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Show Cards',
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            leadingWidth: 80,
            leading: AppbarLeading(backCallBack: () => Navigator.pop(context)),
            actions: [
              InkWell(
                onTap: () async {
                  final result =
                      await Navigator.pushNamed(context, RoutesName.scanCard);
                  if (!context.mounted) return;
                  if (result == '1122') {
                    context.read<ShowCardsVM>().getCardsApi(context, true);
                    context.read<CameraHelper>().removeBackImage();
                    context.read<CameraHelper>().removeFrontImage();
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
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
          body: Center(
            child: Consumer<ShowCardsVM>(builder: (context, value, child) {
              if (value.getCards.isEmpty) {
                return (!value.isLoading)
                    ? (value.error.isEmpty)
                        ? EmptyCardsListWidget(
                            scanCardCallBack: () async {
                              final result = await Navigator.pushNamed(
                                  context, RoutesName.scanCard);
                              if (result == '1122') {
                                if (!context.mounted) return;
                                value.getCardsApi(context, true);
                                context.read<CameraHelper>().removeBackImage();
                                context.read<CameraHelper>().removeFrontImage();
                              }
                            },
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                    await value.getCardsApi(context, true);
                  },
                  child: ListView.builder(
                    itemCount: value.getCards.length,
                    itemBuilder: (context, index) {
                      final item = value.getCards[index];
                      return ShowCardItem(
                        cardItem: item,
                        removeCard: () => context
                            .read<ShowCardsVM>()
                            .removeCard(context, true),
                        printUrl: AppUrl.healthCardPrint,
                      );
                    },
                  ),
                );
              }
            }),
          ),
        ),
      ),
    );
  }
}
