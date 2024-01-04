import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:digihealthcardapp/generated/assets.dart';
import 'package:digihealthcardapp/models/child_model.dart';
import 'package:digihealthcardapp/models/custom_border.dart';
import 'package:digihealthcardapp/models/vaccine_model.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/components/middle_ring.dart';
import 'package:digihealthcardapp/res/components/progress_rings.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/viewModel/child_view_model.dart';
import 'package:digihealthcardapp/viewModel/immunization_model.dart';
import 'package:digihealthcardapp/views/child_immunization/completed_vaccines.dart';
import 'package:digihealthcardapp/views/child_immunization/vaccine_record.dart';
import 'package:digihealthcardapp/views/child_immunization/vaccine_schedule.dart';
import 'package:digihealthcardapp/views/profile/widgets/appbar_leading.dart';
import 'package:digihealthcardapp/views/scan_health_card/card_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'widgets/circular_button.dart';

class ChildProfile extends StatefulWidget {
  const ChildProfile({super.key, required this.childData});

  final Child childData;

  @override
  State<ChildProfile> createState() => _ChildProfileState();
}

class _ChildProfileState extends State<ChildProfile>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _vaccineRingAnimationcontroller;
  late Animation<double> _vaccineRinganimation;

  var dateFormat = DateFormat('yy/MM/dd');

  List<VaccineRecord> record = [];

  String? name;
  String? lastName;
  String? childId;
  DateTime? dateOfBirth;
  String? gender;
  String childWeight = '';
  String childHeight = '';

  Map<String, int> countByStatus = {
    'done': 0,
    'delayed': 0,
    'due': 0,
  };
  int doneCount = 0;
  int delayedCount = 0;
  int pendingCount = 0;
  // Map<String, int> initialCountByStatus = {};

  void updateCountByStatus() {
/*    for (var record in record!) {
      if (record.status == 'done') {
        doneCount++;
      } else if (record.status == 'delayed') {
        delayedCount++;
      } else if (record.status == 'due') {
        pendingCount++;
      }
    }*/
  }

  List<Vaccine> vaccinesCompleted = [];
  @override
  void initState() {
    resetCountByStatus();
    final model = Provider.of<VaccinationModel>(context, listen: false);
    childId = widget.childData.id;
    model.getCompletedVaccines(childId!, context);
    Future.delayed(const Duration(milliseconds: 1800), () {
      Map<String, List<VaccineRecord>> recordMap =
          model.calculateVaccinationRecord(
              context,
              widget.childData.name.toString(),
              widget.childData.dob.toString());
      record = recordMap[widget.childData.name]!;
      removeCompletedVaccines();
    });
    if (kDebugMode) {
      print('Done $doneCount Delayed $delayedCount Due $pendingCount');
    }
    name = widget.childData.name;
    lastName = widget.childData.lname;

    dateOfBirth = DateTime.tryParse(widget.childData.dob);

    gender = widget.childData.gender;
    _vaccineRingAnimationcontroller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _vaccineRinganimation =
        Tween(begin: 0.0, end: 1.0).animate(_vaccineRingAnimationcontroller);
    _vaccineRingAnimationcontroller.forward();
    super.initState();
  }

  void removeCompletedVaccines() {
    if (!context.mounted) return;
    vaccinesCompleted = context.read<VaccinationModel>().vaccineCompleted;
    if (vaccinesCompleted.isNotEmpty) {
      for (var i = 0; i < record.length; i++) {
        for (var vaccineCom in vaccinesCompleted) {
          debugPrint(
              'At removal:   completed: ${vaccineCom.id.toString()} due: ${record[i].vaccineId.toString()}');
          if (vaccineCom.id.toString() + widget.childData.id.toString() ==
              record[i].vaccineId.toString() + widget.childData.id.toString()) {
            record.removeAt(i);
          }
        }
        debugPrint(record[i].toString());
      }
    }
    doneCount = 0;
    delayedCount = 0;
    pendingCount = 0;
    final vaccineRecord = record;
    countByStatus = vaccineRecord.fold(
      {'done': 0, 'delayed': 0, 'due': 0},
      (Map<String, int> acc, record) {
        acc[record.status] = acc[record.status]! + 1;
        return acc;
      },
    );
    debugPrint(
        '${countByStatus['done']}, ${countByStatus['delayed']},${countByStatus['due']}');
    context.read<VaccinationModel>().setLoading(false);
  }

  void resetCountByStatus() {
    doneCount = 0;
    delayedCount = 0;
    pendingCount = 0;
  }

  @override
  void dispose() {
    _vaccineRingAnimationcontroller.dispose();
    super.dispose();
  }

  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  Future getFrontImage(ImageSource source) async {
    final imageFront =
        await _picker.pickImage(source: source, imageQuality: 100);
    if (imageFront != null) {
      File? image = File(imageFront.path);
      final compressed =
          await CameraHelper.compressedImage(image.path.toString());
      image = await CameraHelper.cropImage(File(compressed.path));
      setState(() {
        profileImage = image;
      });
      if (profileImage != null) {
        Map<String, dynamic> profileBody = {
          'id': childId,
          'image': MultipartFile.fromFileSync(profileImage!.path,
              filename: "image.jpg")
        };
        if (!context.mounted) return;
        if (!context.read<CardViewModel>().isLoading) {
          await Provider.of<CardViewModel>(context, listen: false).saveCard(
              context, profileBody, false, false, false, false, true, false);
        } else {
          Utils.snackBarMessage('Please wait...', context);
        }
      }
    } else {
      if (kDebugMode) {
        print('no image is picked');
      }
    }
  }

  void showFront(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext cont) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  getFrontImage(ImageSource.camera);
                },
                child: const Text('Use Camera'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  getFrontImage(ImageSource.gallery);
                },
                child: const Text('Upload from files'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Not Now', style: TextStyle(color: Colors.red)),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final age = now.difference(dateOfBirth!);
    final days = (age.inDays == 0) ? 1 : (age.inDays).round();
    final years = (days / 365).round();
    final months = (days / 30).round();
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    return DrawerWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text("$name's Record",
              textScaleFactor: 1.0,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
          backgroundColor: Theme.of(context).primaryColor,
          leadingWidth: 80,
          leading: AppbarLeading(backCallBack: () {
            resetCountByStatus();
            Navigator.pop(context);
          }),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CompletedVaccines(childData: widget.childData)));
                },
                icon: const ImageIcon(
                  AssetImage(Assets.assetsVaccineCompleted),
                  color: AppColors.primaryColor,
                )),
            IconButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RoutesName.home, (route) => false);
                },
                icon: const ImageIcon(
                  AssetImage(
                    Assets.assetsHome,
                  ),
                  color: AppColors.primaryColor,
                )),
            IconButton(
                onPressed: () {
                  DialogBoxes.showConfirmationDialog(context, () async {
                    await context
                        .read<ChildVM>()
                        .deleteChild(childId.toString(), context);
                  }, 'Are you sure you want to delete this profile? After this action you will not be able to recover your child\'s already saved record.',
                      false, false);
                },
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.deepOrange,
                  size: 30,
                ))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Flexible(
                flex: 3,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              (widget.childData.image != 'null' &&
                                      widget.childData.image!.isNotEmpty)
                                  ? InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        showFront(context);
                                        debugPrint(
                                            widget.childData.image.toString());
                                      },
                                      child: Ink(
                                        width: width * .15,
                                        height: height * .08,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.childData.image
                                                .toString(),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            progressIndicatorBuilder:
                                                (context, url, progress) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          value:
                                                              progress.progress,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                ],
                                              );
                                            },
                                            errorWidget: (context, url, error) {
                                              return Image.asset(
                                                  'Assets/profile_.png',
                                                  height: height * .18,
                                                  width: width * .34,
                                                  fit: BoxFit.cover);
                                            },
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$name $lastName',
                                    textScaleFactor: 1.0,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17),
                                  ),
                                  (gender?.toLowerCase() == 'male')
                                      ? const Text(
                                          'Baby Boy',
                                          textScaleFactor: 1.0,
                                        )
                                      : const Text(
                                          'Baby Girl',
                                          textScaleFactor: 1.0,
                                        ),
                                  Text(
                                    'Born on: ${DateFormat.yMMMd().format(dateOfBirth!)}',
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Weight',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    '${widget.childData.weight.toString()} ${widget.childData.weightUnit.toString()}',
                                    textScaleFactor: 1.0,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              // SizedBox(
                              //   width: 50,
                              //   child: Column(
                              //     children: [
                              //       Divider(
                              //         thickness: 1,
                              //         color: (Theme.of(context).brightness ==
                              //             Brightness.light)
                              //             ? Colors.black
                              //             : Colors.white,
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Height',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    ' ${widget.childData.height.toString()} ${widget.childData.heightUnit.toString()}',
                                    textScaleFactor: 1.0,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * .005,
                    ),
                    Card(
                      elevation: 5,
                      shape: const CustomShapeBorder(radius: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Age Today :',
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                Text(
                                  '$years',
                                  textScaleFactor: 1.0,
                                ),
                                const Text(
                                  'Years',
                                  textScaleFactor: 1.0,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 30,
                              child: Row(
                                children: [
                                  VerticalDivider(
                                    thickness: 1,
                                    color: (Theme.of(context).brightness ==
                                            Brightness.light)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '$months',
                                  textScaleFactor: 1.0,
                                ),
                                const Text(
                                  'Months',
                                  textScaleFactor: 1.0,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 30,
                              child: Row(
                                children: [
                                  VerticalDivider(
                                    thickness: 1,
                                    color: (Theme.of(context).brightness ==
                                            Brightness.light)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '$days',
                                  textScaleFactor: 1.0,
                                ),
                                const Text(
                                  'Days',
                                  textScaleFactor: 1.0,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                flex: 5,
                child: Column(
                  children: [
                    SizedBox(
                      height: height * .010,
                    ),
                    context.read<VaccinationModel>().isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                            child: SizedBox(
                              child: InkWell(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(250)),
                                // splashFactory: InkSparkle.splashFactory,
                                onTap: () async {
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              VaccinationRecord(
                                                birthdate: dateOfBirth!,
                                                childData: widget.childData,
                                              )));

                                  if (result == '1122') {
                                    setState(() {});
                                    if (!context.mounted) return;
                                    final model = Provider.of<VaccinationModel>(
                                        context,
                                        listen: false);
                                    childId = widget.childData.id;
                                    model.getCompletedVaccines(
                                        childId!, context);

                                    Future.delayed(
                                        const Duration(milliseconds: 1800), () {
                                      Map<String, List<VaccineRecord>>
                                          recordMap =
                                          model.calculateVaccinationRecord(
                                              context,
                                              widget.childData.name.toString(),
                                              widget.childData.dob.toString());
                                      record =
                                          recordMap[widget.childData.name]!;
                                      removeCompletedVaccines();
                                    });
                                  }
                                },
                                child: AnimatedBuilder(
                                  animation: _vaccineRinganimation,
                                  builder: (context, child) {
                                    final pendingPercent =
                                        (countByStatus['due']! == 0)
                                            ? 0.0
                                            : (countByStatus['due']!) /
                                                (context
                                                    .read<VaccinationModel>()
                                                    .vaccines
                                                    .length);

                                    final donePercent = ((context
                                            .read<VaccinationModel>()
                                            .vaccineCompleted
                                            .length) /
                                        (context
                                            .read<VaccinationModel>()
                                            .vaccines
                                            .length));
                                    final delayPercent =
                                        (countByStatus['delayed']! == 0)
                                            ? 0.0
                                            : (countByStatus['delayed']!) /
                                                (context
                                                    .read<VaccinationModel>()
                                                    .vaccines
                                                    .length);
                                    return Ink(
                                      height: 225,
                                      width: 520,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            spreadRadius: -10,
                                            blurRadius: 17,
                                            offset: const Offset(-5, -5),
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          BoxShadow(
                                            spreadRadius: -2,
                                            blurRadius: 10,
                                            offset: const Offset(7, 7),
                                            color:
                                                (Theme.of(context).brightness ==
                                                        Brightness.light)
                                                    ? Colors.black12
                                                    : Colors.black38,
                                          )
                                        ],
                                      ),
                                      child: Stack(
                                        children: <Widget>[
                                          Center(
                                            child: MiddleRing(
                                              width: 260,
                                              dueInWeeks: (record
                                                  .firstWhere(
                                                      (record) =>
                                                          record
                                                              .nextDueInWeeks !=
                                                          null,
                                                      orElse: () =>
                                                          VaccineRecord(
                                                            vaccineId: '',
                                                            nextDueInWeeks: 0,
                                                            name: '',
                                                            status: 'due',
                                                            age: 2,
                                                            dueDate:
                                                                DateTime.now(),
                                                          ))
                                                  .nextDueInWeeks),
                                              done: countByStatus['done'],
                                              delayed: countByStatus['delayed'],
                                              pendingPercent:
                                                  pendingPercent * 100,
                                              donePercent: donePercent * 100,
                                            ),
                                          ),
                                          Transform.rotate(
                                            angle: pi * 1.4,
                                            child: CustomPaint(
                                              painter: ProgressRings(
                                                completedPercentage:
                                                    (_vaccineRinganimation
                                                            .value *
                                                        pendingPercent),
                                                circleWidth: 11,
                                                gradient: orangeGradient,
                                                radiusDiv: 2.15,
                                                gradientStartAngle: 0.0,
                                                gradientEndAngle: pi / 3,
                                                progressStartAngle: 1.85,
                                                lengthToRemove: 0,
                                              ),
                                              child: const Center(),
                                            ),
                                          ),
                                          Transform.rotate(
                                            angle: pi * 1.4,
                                            child: CustomPaint(
                                              painter: ProgressRings(
                                                completedPercentage:
                                                    (_vaccineRinganimation
                                                            .value *
                                                        donePercent),
                                                circleWidth: 11,
                                                gradient: turqoiseGradient,
                                                radiusDiv: 2.38,
                                                gradientStartAngle: 0.0,
                                                gradientEndAngle: pi / 2,
                                                progressStartAngle: 1.85,
                                              ),
                                              child: const Center(),
                                            ),
                                          ),
                                          Transform.rotate(
                                            angle: pi * 1.4,
                                            child: CustomPaint(
                                              painter: ProgressRings(
                                                completedPercentage:
                                                    (_vaccineRinganimation
                                                            .value *
                                                        delayPercent),
                                                circleWidth: 11,
                                                gradient: [
                                                  Colors.deepOrange,
                                                  Colors.red.shade200
                                                ],
                                                radiusDiv: 2.72,
                                                gradientStartAngle: 0.0,
                                                gradientEndAngle: pi / 2,
                                                progressStartAngle: 1.85,
                                              ),
                                              child: const Center(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 1),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade200,
                                    Colors.deepOrange
                                  ],
                                  stops: const [0, 1],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(2)),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Delayed',
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.blueGrey),
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xff00c4b2), width: 1),
                                gradient: LinearGradient(
                                  colors: orangeGradient,
                                  stops: const [0, 1],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(2)),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Due',
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.blueGrey),
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xff00c4b2), width: 1),
                                gradient: const LinearGradient(
                                  colors: turqoiseGradient,
                                  stops: [0, 1],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(2)),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Done',
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.blueGrey),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Column(
                      children: [
                        ListTile(
                          dense: true,
                          minVerticalPadding: 0,
                          // minLeadingWidth: width*.2,
                          contentPadding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35))),
                          tileColor: AppColors.primaryLightColor,
                          leading: const SizedBox(
                            width: 80,
                            child: CircularBTN(
                                height: 40,
                                width: 40,
                                color: AppColors.primary,
                                icon: Icon(Icons.vaccines_outlined,
                                    weight: .5, color: Colors.white)),
                          ),
                          title: const Text(
                            'Baby\'s Vaccine Report',
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VaccinationRecord(
                                          birthdate: dateOfBirth!,
                                          childData: widget.childData,
                                        )));

                            if (result == '1122') {
                              setState(() {});
                              if (!context.mounted) return;
                              final model = Provider.of<VaccinationModel>(
                                  context,
                                  listen: false);
                              childId = widget.childData.id;
                              model.getCompletedVaccines(childId!, context);

                              Future.delayed(const Duration(milliseconds: 1800),
                                  () {
                                Map<String, List<VaccineRecord>> recordMap =
                                    model.calculateVaccinationRecord(
                                        context,
                                        widget.childData.name.toString(),
                                        widget.childData.dob.toString());
                                record = recordMap[widget.childData.name]!;
                                removeCompletedVaccines();
                              });
                            }
                          },
                        ),
                        SizedBox(
                          height: height * .015,
                        ),
                        ListTile(
                          dense: true,
                          minVerticalPadding: 0,
                          contentPadding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          tileColor: AppColors.primaryLightColor,
                          leading: const SizedBox(
                            width: 80,
                            child: CircularBTN(
                                height: 40,
                                width: 40,
                                color: AppColors.primary,
                                icon: Icon(
                                  Icons.list,
                                  color: Colors.white,
                                )),
                          ),
                          title: const Text(
                            'Vaccine Schedule',
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const VaccineSchedule()));
                          },
                        ),
                        SizedBox(
                          height: height * .015,
                        ),
                        /*  ListTile(
                          dense: true,
                          minVerticalPadding: 0,
                          contentPadding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          tileColor: Colors.deepOrange,
                          leading: SizedBox(
                            width: 80,
                            child: CircularBTN(
                                height: 40,
                                width: 40,
                                color: Colors.red.shade300,
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                )),
                          ),
                          title: const Text(
                            'Delete Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            DialogBoxes.showConfirmationDialog(context,
                                () async {
                              await context
                                  .read<ChildVM>()
                                  .deleteChild(childId.toString(), context);
                            }, 'Are you sure you want to delete this profile? After this action you will not be able to recover your child\'s already saved record.');
                          },
                        ),
                       */
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double getAngleInRadians(double degree) {
    double unitRadian = 57.2957;
    return degree / unitRadian;
  }
}

const innerColor = Color.fromRGBO(233, 242, 249, 1);
const shadowColor = Color.fromRGBO(220, 227, 234, 1);

const turqoiseGradient = [Color(0xff74ebd5), Color(0xffACB6E5)];

final orangeGradient = [
  Colors.lime.shade300,
  Colors.deepOrange.shade200,
];
