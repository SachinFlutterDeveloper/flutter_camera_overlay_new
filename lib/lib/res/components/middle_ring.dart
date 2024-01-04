import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/viewModel/immunization_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MiddleRing extends StatelessWidget {
  final double width;
  final int? dueInWeeks;
  final int? done;
  final double pendingPercent;
  final double donePercent;
  final int? delayed;

  const MiddleRing({
    Key? key,
    required this.width,
    required this.dueInWeeks,
    this.done,
    this.delayed,
    required this.pendingPercent,
    required this.donePercent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: width,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightGreen, width: 3),
        // color: Colors.white,
        gradient: const LinearGradient(
          colors: [Color(0xffaddbaf), Color(0xff008b9d)],
          stops: [.1, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          height: width * 0.6,
          width: width * 0.6,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff00c4b2), width: 3),
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                // blurStyle: BlurStyle.outer,
                spreadRadius: 22,
                blurRadius: 0.5,
                offset: const Offset(-1, -1),
                color: const Color(0xffaddbaf).withOpacity(0.2),
              ),
              BoxShadow(
                spreadRadius: -2,
                blurRadius: 10,
                offset: const Offset(5, 5),
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (dueInWeeks == 0 && delayed == 0)
                    ? 'All vaccines'
                    : (delayed != 0)
                        ? '$delayed vaccines'
                        : 'Next Vaccine Due',
                textScaleFactor: 1.0,
                style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.light)
                      ? Colors.grey
                      : const Color(0xffeeeeee),
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              ((dueInWeeks == 0 && delayed == 0))
                  ? const Text('Completed',
                      textScaleFactor: 1.0,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600))
                  : (delayed != 0)
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.red,
                            ),
                            Text('Delayed',
                                textScaleFactor: 1.0,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ],
                        )
                      : Text(
                          'In $dueInWeeks Weeks',
                          textScaleFactor: 1.0,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Done: ${context.read<VaccinationModel>().vaccineCompleted.length}',
                textScaleFactor: 1.0,
                style: TextStyle(
                    color: (Theme.of(context).brightness == Brightness.light)
                        ? Colors.grey
                        : const Color(0xffeeeeee),
                    fontSize: 14),
              ),
              const SizedBox(
                height: 10,
              ),
/*               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$donePercent',
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    '/',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    '$pendingPercent',
                    style: TextStyle(
                        color: AppColors.primaryLightColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )
                ],
              )
 */
            ],
          ),
        ),
      ),
    );
  }
}
