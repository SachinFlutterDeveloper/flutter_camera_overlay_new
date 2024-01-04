import 'dart:developer';

import 'package:digihealthcardapp/models/vaccine_model.dart';
import 'package:digihealthcardapp/repositories/immunization_repository.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VaccinationModel extends ChangeNotifier {
  final ImmunizationRepository _immunizationRepo = ImmunizationRepository();

  List<Vaccine> _vaccines = [];
  List<Vaccine> get vaccines => _vaccines;

  List<Vaccine> _vaccinesCompleted = [];
  List<Vaccine> get vaccineCompleted => _vaccinesCompleted;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void setCompletedVaccines(List<Vaccine> vaccines) {
    _vaccinesCompleted = [];
    _vaccinesCompleted = vaccines;
    _isLoading = false;
    notifyListeners();
  }

  Future<dynamic> getVaccines(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userTOKEN = prefs.getString('access_token');

    Map<String, String> header = {'Oauthtoken': 'Bearer $userTOKEN'};
    if (!context.mounted) return;
    _isLoading = true;
    _immunizationRepo.childVaccines(context, header).then((value) {
      if (value['status'] == 'success') {
        final vaccineList = value['data'] as List;
        debugPrint('vaccinesList: $vaccineList');
        _vaccines = List.generate(
            vaccineList.length,
            (index) => Vaccine(
                id: vaccineList[index]['id'].toString(),
                name: vaccineList[index]['name'].toString(),
                dosageCount: vaccineList[index]['dosage_num'].toString(),
                ageDuration: int.parse(vaccineList[index]['dosage_month']),
                start: vaccineList[index]['start'].toString(),
                end: vaccineList[index]['end'].toString()));
        debugPrint(_vaccines.toString());
        _isLoading = false;
        notifyListeners();
      } else {
        if (!context.mounted) return;
        //final error = value['error'];
        final errorDesc = value['error_description'];
        setError(errorDesc);
        log('errorDesc: $errorDesc');
        Utils.snackBarMessage('$errorDesc', context);
      }
    }).onError((error, stackTrace) {
      setError(error.toString());
      log('error: $error');
    });
  }

  Future<void> applyVaccineApi(
      dynamic data, dynamic header, BuildContext context) async {
    setLoading(true);
    if (kDebugMode) {
      print('vaccineData: $data Header:$header');
    }
    if (!context.mounted) return;
    _immunizationRepo.applyVaccines(context, data, header).then((value) async {
      setLoading(false);
      if (value['status'] == 'success') {
        final msg = value['msg'].toString();
        Utils.snackBarMessage('Successfully $msg!', context);
        Navigator.pop(context);
      } else if (value['status'] == 'error') {
        final msg = value['msg'];
        final message = (msg != null) ? msg : value['message'].toString();
        Utils.snackBarMessage(message, context);
      }
      if (kDebugMode) {
        print(value.toString());
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        Utils.snackBarMessage(error.toString(), context);
        print(error.toString());
      }
    });
  }

  Future<void> getCompletedVaccines(
      String childId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userTOKEN = prefs.getString('access_token');
    if (!context.mounted) return;
    Map<String, String> header = {'Oauthtoken': 'Bearer $userTOKEN'};
    setLoading(true);
    await _immunizationRepo
        .appliedVaccines(context, childId, header)
        .then((value) {
      if (value['status'] == 'success') {
        final vaccineList = value['data'] as List;
        debugPrint('vaccineCompletedList: $vaccineList');
        final vaccinesApplied = List.generate(
          vaccineList.length,
          (index) => Vaccine(
            id: vaccineList[index]['id'].toString(),
            name: vaccineList[index]['name'].toString(),
            dosageCount: vaccineList[index]['dosage_num'].toString(),
            ageDuration: int.parse(vaccineList[index]['dosage_month']),
            start: vaccineList[index]['start'].toString(),
            end: vaccineList[index]['end'].toString(),
            dateApplied: vaccineList[index]['dateof'].toString(),
            weight: vaccineList[index]['weight'].toString(),
            height: vaccineList[index]['height'].toString(),
            cardImage: vaccineList[index]['card_image'],
          ),
        );
        setCompletedVaccines(vaccinesApplied);
      } else {
        if (!context.mounted) return '';
        final errorDesc = value['error_description'];
        debugPrint('errorDesc: $errorDesc');
        setError(errorDesc);
      }
    }).onError((error, stackTrace) {
      setError(error.toString());
      debugPrint('error: $error');
    });
  }

  final Map<String, List<VaccineRecord>> _vaccineRecordsMap = {};
  Map<String, List<VaccineRecord>> get vaccineRecordsMap => _vaccineRecordsMap;

  Map<String, List<VaccineRecord>> calculateVaccinationRecord(
      BuildContext context, String childIdentifier, String dateOfBirth) {
    _isLoading = true;
    if (!vaccineRecordsMap.containsKey(childIdentifier)) {
      final List<VaccineRecord> vaccineRecords = [];

      final now = DateTime.now().millisecondsSinceEpoch;
      //convert birthdate to milliseconds
      final dob = DateTime.parse(dateOfBirth).millisecondsSinceEpoch;
      if (kDebugMode) {
        print(dob);
      }

      final model = Provider.of<VaccinationModel>(context, listen: false);
      for (var vaccine in model.vaccines) {
        final dueDate = DateTime.fromMillisecondsSinceEpoch(
            dob + (vaccine.ageDuration * 30 * 24 * 60 * 60 * 1000));
        int dueDateInWeeks =
            ((dueDate.millisecondsSinceEpoch - now) / (7 * 24 * 60 * 60 * 1000))
                .floor();
        if (kDebugMode) {
          print(dueDate);
        } // var dateFormat = DateFormat('yy/MM/dd');

        bool isVaccineCompleted = context
            .read<VaccinationModel>()
            .vaccineCompleted
            .any((completedVaccine) => completedVaccine.id == vaccine.id);

        if (kDebugMode) {
          print(isVaccineCompleted);
        }

        vaccineRecords.add(VaccineRecord(
            vaccineId: vaccine.id,
            name: vaccine.name,
            age: vaccine.ageDuration,
            dueDate: dueDate,
            status: isVaccineCompleted
                ? 'done'
                : dueDate.millisecondsSinceEpoch <= now
                    ? 'delayed'
                    : 'due',
            nextDueInWeeks: dueDateInWeeks >= 0 ? dueDateInWeeks : null,
            isDone: false));
      }

      vaccineRecordsMap[childIdentifier] =
          vaccineRecords; // Associate child with vaccine records
    }
    _isLoading = false;
    // notifyListeners();
    return vaccineRecordsMap;
  }
}
