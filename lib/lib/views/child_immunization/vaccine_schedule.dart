import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/viewModel/immunization_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile/widgets/appbar_leading.dart';

class VaccineSchedule extends StatefulWidget {
  const VaccineSchedule({super.key});

  @override
  State<VaccineSchedule> createState() => _VaccineScheduleState();
}

class _VaccineScheduleState extends State<VaccineSchedule> {
  @override
  void initState() {
    final vaccines = Provider.of<VaccinationModel>(context, listen: false);
    vaccines.getVaccines(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 1;

    return DrawerWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Immunization Schedule',
            textScaleFactor: 1.0,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Theme.of(context).primaryColor,
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
        body: Consumer<VaccinationModel>(
          builder: (context, value, child) {
            if (value.vaccines.isEmpty) {
              return (value.error.isEmpty)
                  ? (value.isLoading)
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : const Center(
                          child: Text(
                            'No Schedule Available',
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
                    );
            } else {
              return RefreshIndicator(
                onRefresh: () => value.getVaccines(context),
                child: ListView.builder(
                    itemCount: value.vaccines.length,
                    itemBuilder: (context, index) {
                      if (index == 0 ||
                          value.vaccines[index].ageDuration !=
                              value.vaccines[index - 1].ageDuration) {
                        // Add a heading for the duration/timeline
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                padding: const EdgeInsets.all(5),
                                width: width * .9,
                                // color: AppColors.Primary,
                                child: Text(
                                  '${value.vaccines[index].ageDuration} months',
                                  textScaleFactor: 1.0,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            VaccineTile(vaccineIndex: index),
                          ],
                        );
                      } else {
                        // Display a vaccine within the same duration/timeline
                        return VaccineTile(vaccineIndex: index);
                      }
                    }),
              );
            }
          },
        ),
      ),
    );
  }
}

class VaccineTile extends StatelessWidget {
  const VaccineTile({super.key, required this.vaccineIndex});

  final int vaccineIndex;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 1;

    final childModel = Provider.of<VaccinationModel>(context);
    final displayVaccine = childModel.vaccines[vaccineIndex];

    return Container(
      // decoration: BoxDecoration(color: Theme.of(context).cardColor,
      //     borderRadius: const BorderRadius.all(Radius.circular(10))),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: ListTile(
        style: ListTileStyle.list,
        title: Row(
          children: [
            const Icon(Icons.vaccines, size: 16, weight: 1),
            SizedBox(
              width: width * .8,
              child: Text(
                displayVaccine.name,
                textScaleFactor: 1.0,
                softWrap: true,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Age: ${displayVaccine.ageDuration} months',
          textScaleFactor: 1.0,
        ),
        // trailing: Text(displayVaccine.timeline),
        // trailing: Text(dateFormat
        //     .format(displayChild.DOB)
        //     .toString(),style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
      ),
    );
  }
}
