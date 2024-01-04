import 'package:digihealthcardapp/generated/assets.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:flutter/material.dart';

import '../../profile/widgets/material_btn.dart';

class EmptyCardsListWidget extends StatelessWidget {
  final VoidCallback scanCardCallBack;
  const EmptyCardsListWidget({
    super.key,
    required this.scanCardCallBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          Assets.emptyCardList,
          color: AppColors.primaryColor,
          height: 60,
          width: 60,
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
            width: MediaQuery.sizeOf(context).width * .6,
            child: const Text(
              'You have not added any cards yet. Start adding your cards now',
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
            )),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width * .5,
          child: MaterialBtn(
            title: 'Add New Card',
            color: AppColors.primaryColor,
            materialCallBack: scanCardCallBack,
          ),
        ),
      ],
    );
  }
}
