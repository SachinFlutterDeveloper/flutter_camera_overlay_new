import 'package:digihealthcardapp/repositories/cards_repo.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowCardsVM with ChangeNotifier {
  List<dynamic> _cards = [];
  List<dynamic> get getCards => _cards;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCards(List<dynamic> cards) {
    _cards = cards;
    _error = '';
    _isLoading = false;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  final CardsRepo _cardRepo;
  ShowCardsVM(this._cardRepo);

  Future<dynamic> getCardsApi(BuildContext context, bool isHealth) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    if (!context.mounted) return;
    Map<String, dynamic> body = {
      'patient_id': userId.toString(),
    };
    Map<String, dynamic> header = <String, String>{
      'Oauthtoken': 'Bearer $userToken',
    };
    setLoading(true);
    _cards = [];
    try {
      final value =
          await _cardRepo.getCardsApi(context, body, header, isHealth);
      final status = value['status'];
      DialogBoxes.cancelLoading();
      if (status == 'success') {
        if (kDebugMode) {
          print("-- response ${value.toString()} ${value['data']}");
        }
        final cards = value['data'] as List<dynamic>;
        setCards(cards);
      } else {
        setError(value['message']);
        // API call failed, handle error here
        debugPrint(value.toString());
      }
    } catch (e) {
      setError(e.toString());
      debugPrint(e.toString());
    }
  }

  Future<void> removeCard(BuildContext context, bool isHealth) async {
    DialogBoxes.showLoadingNoTimer();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    final String? cardID = prefs.getString('Card_id');
    if (!context.mounted) return;
    Map<String, dynamic> body = {
      'id': cardID.toString(),
      'patient_id': userId.toString(),
    };
    Map<String, dynamic> header = <String, String>{
      'Oauthtoken': 'Bearer $userToken',
    };
    _cardRepo.removeCardsApi(context, body, header, isHealth).then((value) {
      final status = value['status'];
      DialogBoxes.cancelLoading();
      final msg = value['message'];
      if (status == 'success') {
        Utils.snackBarMessage('Successfully $msg', context);
        context.read<ShowCardsVM>().getCardsApi(context, isHealth);
        if (kDebugMode) {
          print("-- response ${value.toString()} $cardID");
        }
      } else {
        // API call failed, handle error here
        Utils.errorSnackBar('$msg', context);
        debugPrint(value.toString());
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      if (!context.mounted) return;
      Utils.snackBarMessage(error.toString(), context);
    });
  }
}
