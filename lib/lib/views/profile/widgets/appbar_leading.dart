import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:flutter/material.dart';

class AppbarLeading extends StatelessWidget {
  final VoidCallback backCallBack;

  const AppbarLeading({super.key, required this.backCallBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          child: IconButton(
            onPressed: backCallBack,
            alignment: Alignment.centerLeft,
            icon: const ImageIcon(
              AssetImage('Assets/back.png'),
              color: AppColors.primaryColor,
            ),
          ),
        ),
        Positioned(
          left: 40,
          child: Builder(builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                DrawerWidget.of(context)?.toggle();
              },
              icon: const ImageIcon(
                AssetImage('Assets/sidemenu.png'),
                color: AppColors.primaryColor,
              ),
            );
          }),
        ),
      ],
    );
  }
}
