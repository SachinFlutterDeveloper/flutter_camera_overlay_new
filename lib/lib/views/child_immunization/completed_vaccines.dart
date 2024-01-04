import 'package:cached_network_image/cached_network_image.dart';
import 'package:digihealthcardapp/models/child_model.dart';
import 'package:digihealthcardapp/models/vaccine_model.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/viewModel/immunization_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../profile/widgets/appbar_leading.dart';

class CompletedVaccines extends StatefulWidget {
  final Child childData;
  const CompletedVaccines({super.key, required this.childData});

  @override
  State<CompletedVaccines> createState() => _CompletedVaccinesState();
}

class _CompletedVaccinesState extends State<CompletedVaccines> {
  @override
  void initState() {
    super.initState();
    final childId = widget.childData.id;
    final vaccine = Provider.of<VaccinationModel>(context, listen: false);
    vaccine.getCompletedVaccines(childId, context);
  }

  @override
  Widget build(BuildContext context) {
    return DrawerWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Completed Vaccines',
            textScaleFactor: 1.0,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          leadingWidth: 80,
          leading: AppbarLeading(
            backCallBack: () => Navigator.pop(context),
          ),
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
                ))
          ],
        ),
        body: SafeArea(
          child: Consumer<VaccinationModel>(
            builder: (context, vaccineGiven, child) {
              if (vaccineGiven.vaccineCompleted.isEmpty) {
                return (vaccineGiven.isLoading)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : (vaccineGiven.error.isEmpty)
                        ? const Center(
                            child: Text(
                            'No vaccines completed',
                            textScaleFactor: 1.0,
                            style: TextStyle(fontSize: 16),
                          ))
                        : Center(
                            child: Text(
                              vaccineGiven.error.toString(),
                              textScaleFactor: 1.0,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
              } else {
                return RefreshIndicator(
                  onRefresh: () => vaccineGiven.getCompletedVaccines(
                      widget.childData.id, context),
                  child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shrinkWrap: true,
                      itemCount: vaccineGiven.vaccineCompleted.length,
                      itemBuilder: (context, index) {
                        final vaccineItem =
                            vaccineGiven.vaccineCompleted[index];
                        return CompletedVaccinesListTile(
                          vaccine: vaccineItem,
                        );
                      }),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class CompletedVaccinesListTile extends StatelessWidget {
  final Vaccine vaccine;
  const CompletedVaccinesListTile({super.key, required this.vaccine});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateApplied =
        dateFormat.format(DateTime.parse(vaccine.dateApplied.toString()));
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      elevation: 3,
      margin:
          const EdgeInsetsDirectional.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.5,
                          child: Text(
                            vaccine.name.toString(),
                            textScaleFactor: 1.0,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                        ),
                        Text(
                          'Dosage: ${vaccine.dosageCount}',
                          textScaleFactor: 1.0,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Given on:\n${dateApplied.toString()}',
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * .8,
              height: MediaQuery.sizeOf(context).height * .3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: vaccine.cardImage.toString(),
                  progressIndicatorBuilder: (context, url, progress) => Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Loading',
                              textScaleFactor: 1.0,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CircularProgressIndicator(
                              value: progress.progress,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  errorWidget: (context, error, stackTrace) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'No image found',
                        textScaleFactor: 1.0,
                      ),
                    ));
                  },
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
