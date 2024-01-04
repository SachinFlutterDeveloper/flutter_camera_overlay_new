import 'package:digihealthcardapp/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final String text;
  const Loading({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: /* const Color(0xff444654) */ AppColors.primary,
      padding: const EdgeInsets.all(8),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Expanded(
          //   flex: 1,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Container(
          //         color: const Color(0xff0fa37f),
          //         padding: const EdgeInsets.all(3),
          //         child: Icon(
          //           Icons.flutter_dash,
          //           size: 50,
          //         )),
          //   ),
          // ),
          Expanded(
            flex: 5,
            child: Center(
                child: SpinKitThreeBounce(
              color: AppColors.white,
            )),
          ),
        ],
      ),
    );
  }
}
