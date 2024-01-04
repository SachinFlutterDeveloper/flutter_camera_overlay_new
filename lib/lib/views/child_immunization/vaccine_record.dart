import 'package:digihealthcardapp/generated/assets.dart';
import 'package:digihealthcardapp/models/child_model.dart';
import 'package:digihealthcardapp/models/vaccine_model.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/immunization_model.dart';
import 'package:digihealthcardapp/viewModel/services/notification_service.dart';
import 'package:digihealthcardapp/views/child_immunization/completed_vaccines.dart';
import 'package:digihealthcardapp/views/child_immunization/save_applied_vaccine.dart';
import 'package:digihealthcardapp/views/child_immunization/widgets/profile_card.dart';
import 'package:digihealthcardapp/views/profile/widgets/appbar_leading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VaccinationRecord extends StatefulWidget {
  const VaccinationRecord(
      {super.key, required this.birthdate, required this.childData});

  final DateTime birthdate;
  final Child childData;

  @override
  State<VaccinationRecord> createState() => _VaccinationRecordState();
}

class _VaccinationRecordState extends State<VaccinationRecord>
    with WidgetsBindingObserver {
  var dateFormat = DateFormat('yy/MM/dd');
  var vaccineDateform = DateFormat('dd/MM/yyyy, hh:mm:ss');
  var dateFormatForReminder = DateFormat('MMM d yyyy, h:mm a');

  List<VaccineRecord>? record;

  String? childName;

  DateTime? _alarmDateTime;
  FocusNode? dateFocusNode;
  FocusNode? weightFocus;
  FocusNode? heightFocus;
  TextEditingController? dateController;
  TextEditingController? weightController;
  TextEditingController? heightController;
  final NotificationHelper _notificationService = NotificationHelper();

  Child? childData;

  DateTime? vaccineGivenDate;

  String? name;
  String? lastName;
  DateTime? dateOfBirth;
  String? gender;
  String? childId;

  @override
  void initState() {
    dateFocusNode = FocusNode();
    weightFocus = FocusNode();
    heightFocus = FocusNode();
    weightController = TextEditingController();
    heightController = TextEditingController();
    dateController = TextEditingController(
        text: dateFormatForReminder.format(DateTime.now()));
    final model = Provider.of<VaccinationModel>(context, listen: false);
    //model.setCompletedEmpty();
    // model.getCompletedVaccines(widget.childData.id, context);
    final vaccineRecord = model.calculateVaccinationRecord(
        context, widget.childData.name, widget.birthdate.toString());
    record = vaccineRecord[widget.childData.name];
    childId = widget.childData.id;
    childName = widget.childData.name;
    lastName = widget.childData.lname;
    dateOfBirth = DateTime.tryParse(widget.childData.dob);
    gender = widget.childData.gender;
    childName = widget.childData.name;
    _notificationService.initializeAwesomeNotification(widget.childData.name);
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
    final now = DateTime.now();
    final age = now.difference(dateOfBirth!);
    final days = (age.inDays).round();
    final years = (days / 365).round();
    final months = (days / 30).round();
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    return DrawerWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'Vaccine Record',
            textScaleFactor: 1.0,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          leadingWidth: 80,
          leading: AppbarLeading(
            backCallBack: () => Navigator.pop(context, '1122'),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CompletedVaccines(childData: widget.childData)));
                },
                icon: const ImageIcon(AssetImage(Assets.assetsVaccineCompleted),
                    color: AppColors.primaryColor)),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$childName $lastName',
                          textScaleFactor: 1.0,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 17),
                        ),
                        SizedBox(
                          height: height * .005,
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
                        SizedBox(
                          height: height * .005,
                        ),
                        Text(
                            textScaleFactor: 1.0,
                            'Born on: ${DateFormat.yMMMd().format(dateOfBirth!)}'),
                        SizedBox(
                          height: height * .01,
                        ),
                        Row(
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
                        )
                      ],
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CompletedVaccines(
                                    childData: widget.childData),
                              ),
                            );
                          },
                          child: Ink(
                            height: 40,
                            width: width * 0.26,
                            decoration: BoxDecoration(
                                color: AppColors.primaryLightColor,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Center(
                                child: Text(
                                  'Vaccines\nCompleted',
                                  textScaleFactor: 1.0,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: width * 0.001,
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 6,
              child: Container(
                height: MediaQuery.sizeOf(context).height * .8,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Color(
                          (Theme.of(context).brightness == Brightness.light)
                              ? 0xffDDDDDD
                              : 0xff263238),
                      blurRadius: 6.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0.0, 0.0),
                    )
                  ],
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35)),
                ),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: record?.length,
                    itemBuilder: (context, index) {
                      final item = record![index];
                      final vaccinesCompleted =
                          context.read<VaccinationModel>().vaccineCompleted;
                      for (var vaccine in vaccinesCompleted) {
                        if (vaccine.id == item.vaccineId) {
                          return const SizedBox.shrink();
                        }
                      }
                      final dueDate = (item.status == 'done')
                          ? 'Completed'
                          : item.dueDate.isBefore(DateTime.now())
                              ? 'Delayed'
                              : 'Due Date: ${DateFormat.yMMMd().format(item.dueDate)}';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8),
                        child: Card(
                          elevation: 5,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: width * .6,
                                          child: Text(
                                            item.name,
                                            textScaleFactor: 1.0,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        (dueDate == 'Delayed')
                                            ? Text(
                                                dueDate,
                                                textScaleFactor: 1.0,
                                                style: const TextStyle(
                                                  color: Colors.deepOrange,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            : Text(
                                                dueDate,
                                                textScaleFactor: 1.0,
                                              ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CardButton(
                                          height: height * .040,
                                          width: width * .25,
                                          color: Colors.grey.shade400,
                                          title: 'Update',
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    SaveAppliedVaccine(
                                                        childData:
                                                            widget.childData,
                                                        vaccineId:
                                                            item.vaccineId,
                                                        vaccineListIndex: index,
                                                        vaccineName: item.name),
                                              ),
                                            );
                                            if (!context.mounted) return;
                                            if (result == '1122') {
                                              setState(() {});
                                            }
                                          },
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CardButton(
                                            height: height * .040,
                                            width: width * .25,
                                            color: AppColors.primaryLightColor,
                                            title: 'Reminder',
                                            onPressed: () {
                                              _vaccineReminderBtmSheet(
                                                  context,
                                                  index,
                                                  item.name,
                                                  item.dueDate,
                                                  _alarmDateTime,
                                                  dateController);
                                            })
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

/*   void _vaccineDetailedDialog(
    BuildContext context,
    int index,
    String vaccineId,
    String childId,
    String name,
    DateTime dueDate,
    String status,
    TextEditingController? dateController,
    TextEditingController? weightController,
    TextEditingController? heightController,
    FocusNode? dateFocus,
    FocusNode? weightFocus,
    FocusNode? heightFocus,
    DateTime givenDate,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: AlertDialog(
                shape: const CustomShapeBorder(radius: 10),
                actionsPadding: const EdgeInsets.all(10),
                actionsAlignment: MainAxisAlignment.center,
                contentPadding: const EdgeInsets.all(10),
                insetPadding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .16,
                    horizontal: MediaQuery.of(context).size.width * .050),
                title: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Center(
                      child: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w500),
                  )),
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: dateController,
                      focusNode: dateFocus,
                      onTap: () {
                        _selectDate(context);
                      },
                      onChanged: (value) {},
                      onFieldSubmitted: (v) {
                        Utils.fieldFocusChange(
                            context, dateFocus!, weightFocus!);
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
                      decoration: buildInputDecoration(
                          context, 'Enter child\'s height in cm.'),
                      onFieldSubmitted: (v) {
                        heightFocus?.unfocus();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Due Date  :  ',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[400]),
                        ),
                        Text(
                          DateFormat.yMMMd().format(dueDate),
                          style: TextStyle(
                              fontSize: 14, color: AppColors.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vaccine Status  :  ',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[400]),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                              fontSize: 14, color: AppColors.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                actions: [
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
                              final applyVaccine =
                                  Provider.of<VaccinationModel>(context,
                                      listen: false);
                              applyVaccine.changeVaccineStatus(
                                  index, true, childName!, givenDate);
                              Map<String, String> vaccineData = {
                                'child_id': childId.toString(),
                                'dateof': vaccineDateform
                                    .format(vaccineGivenDate!)
                                    .toString(),
                                'weight':
                                    weightController!.text.trim().toString(),
                                'height':
                                    heightController!.text.trim().toString(),
                                'vaccine_id': vaccineId.toString(),
                              };
                              SharedPreferences sp =
                                  await SharedPreferences.getInstance();
                              final accessToken = sp.getString('access_token');
                              Map<String, String> header = {
                                'Oauthtoken': 'Bearer $accessToken'
                              };
                              if (!context.mounted) return;
                              if (!context.read<VaccinationModel>().isLoading) {
                                applyVaccine.applyVaccineApi(
                                    vaccineData, header, context);
                                DialogBoxes.showLoading();
                              } else {
                                Utils.toastMessage('Please wait...');
                              }
                              dateController?.clear();
                              heightController.clear();
                              weightController.clear();
                            },
                            child: Ink(
                              height: MediaQuery.of(context).size.height * .05,
                              width: MediaQuery.of(context).size.width * .40,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Center(
                                  child: Text(
                                'Save',
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
                              width: MediaQuery.of(context).size.width * .40,
                              decoration: BoxDecoration(
                                  color: AppColors.black,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Center(
                                  child: Text(
                                'Not Now',
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height * .12,
                child: Image.asset(
                  'Assets/icon_logo.png',
                  height: 50,
                  width: 50,
                )),
          ],
        );
      },
    );
  } */

  GlobalKey<FormState> reminderKey = GlobalKey<FormState>();
  void _vaccineReminderBtmSheet(
      BuildContext context,
      int index,
      String name,
      DateTime dueDate,
      DateTime? reminderDateTime,
      TextEditingController? dateController) async {
    return showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: reminderKey,
                    child: TextFormField(
                      style: TextStyle(
                          fontSize:
                              16 / MediaQuery.of(context).textScaleFactor),
                      controller: dateController,
                      focusNode: dateFocusNode,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        showDateTimePicker(context: context);
                        setState(() {});
                      },
                      onChanged: (value) {
                        dateController?.text = value;
                        dateController?.selection =
                            TextSelection.collapsed(offset: value.length);
                        if (kDebugMode) {
                          print('$dateController');
                        }
                      },
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return "This field is required";
                        } else if (value !=
                            dateFormatForReminder.format(reminderDateTime!)) {
                          return "Please select the valid date and time";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).cardColor,
                        filled: true,
                        isDense: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xffE4E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        // if (value != null && value.isEmpty) {
                        //   return "This field is required";
                        // } else if (value !=
                        //     dateFormatForReminder.format(_alarmDateTime!)) {
                        //   return "Please select the valid date and time";
                        // } else {
                        //   return null;
                        // }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    name.toString(),
                    textScaleFactor: 1.0,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    padding: const EdgeInsets.all(5),
                    enableFeedback: true,
                    splashColor: Colors.white,
                    onPressed: () {
                      if (kDebugMode) {
                        print('${dateController?.text.toString()}  '
                            '$_alarmDateTime '
                            '$name');
                      }
                      if (_alarmDateTime != null &&
                          dateController!.text.toString() !=
                              dateFormatForReminder
                                  .format(DateTime.now())
                                  .toString()) {
                        _notificationService.createVaccineReminderNotification(
                            _alarmDateTime, index, name, childName!);
                        Navigator.of(context).pop();
                        DialogBoxes.showLoading();
                        Utils.snackBarMessage(
                            'You set reminder for $name', context);
                      } else {
                        // reminderKey.currentState?.validate();
                        Utils.toastMessage('Please select time in future!');
                      }
                    },
                    color: AppColors.primaryColor,
                    child: const Center(
                        child: Text(
                      'Set Reminder',
                      textScaleFactor: 1.0,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    )),
                  ),
                  // SizedBox(height: 5,),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    padding: const EdgeInsets.all(5),
                    enableFeedback: true,
                    color: AppColors.black,
                    splashColor: Colors.white,
                    child: const Center(
                        child: Text(
                      'Not Now',
                      textScaleFactor: 1.0,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    )),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (selectedTime != null) {
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      setState(() {
        dateController?.text = dateFormatForReminder.format(selectedDateTime);
        _alarmDateTime = selectedDateTime;
      });
    }

    return selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      if (kDebugMode) {
        print(picked);
        setState(() {
          vaccineGivenDate = picked;
          dateController?.text =
              dateFormatForReminder.format(picked).toString();
        });
        final String formattedDate = dateFormat.format(picked);
        if (kDebugMode) {
          print(formattedDate);
        }
        final vaccineDate = formattedDate.toString();
        if (kDebugMode) {
          print('Given: $vaccineDate');
        }
      }
    }
  }
}
