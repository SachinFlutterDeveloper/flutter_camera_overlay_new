import 'dart:io';

import 'package:digihealthcardapp/models/child_model.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/views/scan_health_card/card_viewmodel.dart';
import 'package:digihealthcardapp/views/scan_health_card/scan_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../profile/widgets/appbar_leading.dart';

class SaveAppliedVaccine extends StatefulWidget {
  const SaveAppliedVaccine(
      {super.key,
      required this.childData,
      required this.vaccineId,
      required this.vaccineListIndex,
      required this.vaccineName});
  final Child childData;
  final String vaccineId;
  final int vaccineListIndex;
  final String vaccineName;

  @override
  State<SaveAppliedVaccine> createState() => _SaveAppliedVaccineState();
}

class _SaveAppliedVaccineState extends State<SaveAppliedVaccine> {
  FocusNode? dateFocusNode;
  FocusNode? weightFocus;
  FocusNode? heightFocus;
  TextEditingController? dateController;
  TextEditingController? weightController;
  TextEditingController? heightController;

  var dateFormat = DateFormat('yy/MM/dd');
  var vaccineDateform = DateFormat('yyyy-MM-dd hh:mm:ss');
  var dateFormatForReminder = DateFormat('MMM d yyyy, h:mm a');

  String? childName;
  String? childId;

  DateTime? vaccineGivenDate;

  @override
  void initState() {
    context.read<CameraHelper>().removeFrontImage();

    vaccineGivenDate = DateTime.now();
    dateFocusNode = FocusNode();
    weightFocus = FocusNode();
    heightFocus = FocusNode();
    weightController = TextEditingController();
    heightController = TextEditingController();
    dateController = TextEditingController(
        text: dateFormatForReminder.format(DateTime.now()));
    childId = widget.childData.id;
    childName = widget.childData.name;
    super.initState();
  }

  @override
  void dispose() {
    dateController?.dispose();
    dateFocusNode?.dispose();
    weightFocus?.dispose();
    heightFocus?.dispose();
    weightController?.dispose();
    heightController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).textScaleFactor;
    final cameraService = Provider.of<CameraHelper>(context, listen: false);
    return DrawerWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Save Applied Vaccine',
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
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        textScaleFactor: 1.0,
                        'Please add the front and back pictures of your health/ID card.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Card(
                        margin: const EdgeInsets.all(10),
                        // color: Colors.grey[200],
                        shadowColor: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * .25,
                              ),
                              InkWell(
                                onTap: () {
                                  DialogBoxes.showPickImageDialog(context,
                                      () async {
                                    Navigator.pop(context);
                                    cameraService.onCaptureFront(context);
                                  }, () async {
                                    Navigator.pop(context);
                                    cameraService.getFrontImage(
                                        context, ImageSource.gallery);
                                  });
                                },
                                child: Container(
                                  height:
                                      MediaQuery.sizeOf(context).height * .40,
                                  width: MediaQuery.sizeOf(context).width * .80,
                                  color: Theme.of(context).primaryColor,
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        cameraService.frontImage != null
                                            ? Image.file(
                                                File(cameraService
                                                        .frontImage!.path)
                                                    .absolute,
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        .32,
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        .78,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'Assets/add_pic.png',
                                                height: 50,
                                                width: 50,
                                              ),
                                        if (cameraService.frontImage != null)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: GestureDetector(
                                              onTap: () => DialogBoxes
                                                  .showConfirmDialogDel(context,
                                                      () {
                                                Navigator.pop(context);
                                                cameraService
                                                    .removeFrontImage();
                                              }),
                                              child: const CircleAvatar(
                                                radius: 10,
                                                backgroundColor: Colors.red,
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                              ),
                                            ),
                                          )
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        initialValue: widget.vaccineName,
                        style: TextStyle(fontSize: 16 / scaleFactor),
                        enabled: false,
                        onFieldSubmitted: (v) {
                          Utils.fieldFocusChange(
                              context, dateFocusNode!, weightFocus!);
                        },
                        decoration:
                            buildInputDecoration(context, 'Vaccination name'),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: dateController,
                        focusNode: dateFocusNode,
                        style: TextStyle(fontSize: 16 / scaleFactor),
                        onTap: () {
                          _selectDate(context);
                        },
                        onTapOutside: (event) {
                          weightFocus?.unfocus();
                        },
                        onChanged: (value) {},
                        onFieldSubmitted: (v) {
                          Utils.fieldFocusChange(
                              context, dateFocusNode!, weightFocus!);
                        },
                        decoration: buildInputDecoration(
                            context, 'Enter Vaccination Date'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: weightController,
                        focusNode: weightFocus,
                        style: TextStyle(fontSize: 16 / scaleFactor),
                        keyboardType:
                            defaultTargetPlatform == TargetPlatform.iOS
                                ? const TextInputType.numberWithOptions(
                                    decimal: true, signed: true)
                                : const TextInputType.numberWithOptions(
                                    decimal: true),
                        decoration: buildInputDecoration(
                            context, 'Enter child\'s weight in lbs.'),
                        onFieldSubmitted: (v) {
                          Utils.fieldFocusChange(
                              context, weightFocus!, heightFocus!);
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: heightController,
                        focusNode: heightFocus,
                        style: TextStyle(fontSize: 16 / scaleFactor),
                        keyboardType:
                            defaultTargetPlatform == TargetPlatform.iOS
                                ? const TextInputType.numberWithOptions(
                                    decimal: true, signed: true)
                                : const TextInputType.numberWithOptions(
                                    decimal: true),
                        decoration: buildInputDecoration(
                            context, 'Enter child\'s height in feet inches.'),
                        onFieldSubmitted: (v) {
                          heightFocus?.unfocus();
                        },
                        onTapOutside: (event) {
                          heightFocus?.unfocus();
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              if (!context.mounted) return;
                              if (cameraService.frontImage?.path == null ||
                                  cameraService.frontImage!.path.isEmpty) {
                                Utils.snackBarMessage(
                                    'Please add scan of child\'s vaccine card',
                                    context);
                              } else if (vaccineGivenDate == null) {
                                Utils.snackBarMessage(
                                    'Please select the date of vaccination',
                                    context);
                              } else {
                                // final applyVaccine =
                                //     Provider.of<VaccinationModel>(context,
                                //         listen: false);
                                Map<String, dynamic> vaccineData = {
                                  'child_id': childId.toString(),
                                  'dateof': vaccineDateform
                                      .format(vaccineGivenDate!)
                                      .toString(),
                                  'weight':
                                      weightController!.text.trim().toString(),
                                  'height':
                                      heightController!.text.trim().toString(),
                                  'vaccine_id': widget.vaccineId.toString(),
                                  'front_pic': MultipartFile.fromFileSync(
                                      context
                                          .read<CameraHelper>()
                                          .frontImage!
                                          .path,
                                      filename: "front_image.jpg"),
                                };
                                if (!context.mounted) return;
                                final cardVM = Provider.of<CardViewModel>(
                                    context,
                                    listen: false);
                                if (!context.read<CardViewModel>().isLoading) {
                                  cardVM.saveCard(context, vaccineData, false,
                                      false, true, false, false, false);
                                } else {
                                  Utils.toastMessage('Please wait...');
                                }
                              }
                            },
                            child: Ink(
                              height: MediaQuery.of(context).size.height * .05,
                              width: MediaQuery.of(context).size.width * .80,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Center(
                                  child: Text(
                                'Save',
                                textScaleFactor: 1.0,
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              dateController?.clear();
                              heightController?.clear();
                              weightController?.clear();
                              Navigator.pop(context);
                            },
                            child: Ink(
                              height: MediaQuery.of(context).size.height * .05,
                              width: MediaQuery.of(context).size.width * .80,
                              decoration: BoxDecoration(
                                  color: AppColors.black,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Center(
                                  child: Text(
                                'Not Now',
                                textScaleFactor: 1.0,
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      debugPrint(picked.toString());
      setState(() {
        vaccineGivenDate = picked;
        dateController?.text = dateFormatForReminder.format(picked).toString();
      });
      final String formattedDate = dateFormat.format(picked);
      debugPrint(formattedDate);
      final vaccineDate = formattedDate.toString();
      debugPrint('Given: $vaccineDate');
    }
  }
}
