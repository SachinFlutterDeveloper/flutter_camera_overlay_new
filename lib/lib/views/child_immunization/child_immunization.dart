import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/viewModel/child_view_model.dart';
import 'package:digihealthcardapp/viewModel/immunization_model.dart';
import 'package:digihealthcardapp/views/child_immunization/add_child.dart';
import 'package:digihealthcardapp/views/child_immunization/child_profile.dart';
import 'package:digihealthcardapp/views/child_immunization/vaccine_schedule.dart';
import 'package:digihealthcardapp/views/child_immunization/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../profile/widgets/appbar_leading.dart';

class ChildImmunization extends StatefulWidget {
  const ChildImmunization({super.key});

  @override
  State<ChildImmunization> createState() => _ChildImmunizationState();
}

class _ChildImmunizationState extends State<ChildImmunization>
    with WidgetsBindingObserver {
  @override
  void initState() {
    Future.delayed(
        const Duration(milliseconds: 600),
        () => DialogBoxes.showConfirmationDialog(
            context, () {}, '', true, false));
    final model = Provider.of<VaccinationModel>(context, listen: false);
    model.getVaccines(context);
    final childrenList = Provider.of<ChildVM>(context, listen: false);
    childrenList.getChildren(context);
    super.initState();
  }

  var dateFormat = DateFormat('yy/MM/dd');

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
              'Children List',
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            leadingWidth: 80,
            leading: AppbarLeading(backCallBack: () => Navigator.pop(context)),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const VaccineSchedule()));
                },
                icon: const Icon(Icons.list_alt_rounded),
                color: AppColors.primaryColor,
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
          body: Consumer<ChildVM>(builder: (context, value, child) {
            if (value.children.isEmpty) {
              return (!value.isLoading)
                  ? (value.error.isEmpty)
                      ? const Center(
                          child: Text(
                            'Please add your child profile',
                            textScaleFactor: 1.0,
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : Center(
                          child: Text(
                            value.error.toString(),
                            textScaleFactor: 1.0,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  value.getChildren(context);
                },
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10.0),
                    itemCount: value.children.length,
                    itemBuilder: (context, index) {
                      return ChildTile(
                          childIndex: index,
                          recordCallBack: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildProfile(
                                  childData: value.children[index],
                                ),
                              ),
                            );

                            if (!context.mounted) return;
                            if (result == '1122') {
                              setState(() {});
                              await context
                                  .read<ChildVM>()
                                  .getChildren(context);
                            }
                          },
                          profileCallBack: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddChildProfile(
                                        index: index,
                                      )),
                            );
                            if (!context.mounted) return;
                            if (result == '1122') {
                              setState(() {});
                              await context
                                  .read<ChildVM>()
                                  .getChildren(context);
                            }
                          });
                    }),
              );
            }
          }),
          floatingActionButton: FloatingActionButton.extended(
              icon: const Icon(Icons.person_add_alt_outlined),
              backgroundColor: AppColors.primaryColor,
              label: const Text(
                "Add a child",
                textScaleFactor: 1.0,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final result = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddChildProfile()));
                if (!context.mounted) return;
                if (result == '1122') {
                  setState(() {});
                  await context.read<ChildVM>().getChildren(context);
                }
              }),
        ),
      ),
    );
  }
}

class ChildTile extends StatelessWidget {
  const ChildTile(
      {super.key,
      required this.childIndex,
      required this.recordCallBack,
      required this.profileCallBack});

  final int childIndex;
  final VoidCallback recordCallBack;
  final VoidCallback profileCallBack;

  @override
  Widget build(BuildContext context) {
    final childModel = Provider.of<ChildVM>(context);
    final displayChild = childModel.children[childIndex];
    var dateFormat = DateFormat('yy/MM/dd');
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      onTap: recordCallBack,
      child: Card(
        color: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.person_outline, size: 18, weight: 1),
                      Text(
                        '${displayChild.name} ${displayChild.lname}',
                        textScaleFactor: 1.0,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayChild.gender,
                          textScaleFactor: 1.0,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          textScaleFactor: 1.0,
                          'Born on: ${dateFormat.format(DateTime.parse(displayChild.dob)).toString()}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        )
                      ]),
                ],
              ),
              Column(
                children: [
                  CardButton(
                      height: /* MediaQuery.of(context).size.height * .00 */ 30,
                      width: MediaQuery.of(context).size.width * .35,
                      color: AppColors.primaryLightColor,
                      title: 'Record',
                      onPressed: recordCallBack),
                  const SizedBox(
                    height: 6,
                  ),
                  CardButton(
                      height: /*  MediaQuery.of(context).size.height * .040 */
                          30,
                      width: MediaQuery.of(context).size.width * 0.35,
                      color: AppColors.primaryLightColor,
                      title: 'Profile',
                      onPressed: profileCallBack),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
