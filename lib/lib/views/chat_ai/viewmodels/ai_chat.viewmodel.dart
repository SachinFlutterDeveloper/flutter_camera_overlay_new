import 'package:digihealthcardapp/views/chat_ai/repository/chat_ai_repository.dart';
import 'package:digihealthcardapp/views/chat_ai/widgets/ai_message.dart';
import 'package:digihealthcardapp/views/chat_ai/widgets/loading.dart';
import 'package:digihealthcardapp/views/chat_ai/widgets/user_message.dart';
import 'package:flutter/material.dart';

class ChatAIViewModel with ChangeNotifier {
  List<Widget> messages = [];
  List<Widget> get getMessages => messages;

  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setToUnanimate(String txt) {
    messages.removeLast();
    _isAnimating = false;
    messages.add(AiMessage(
      text: txt,
      shouldAnimate: false,
    ));
    notifyListeners();
  }

  void setToEmpty() {
    messages = [];
    notifyListeners();
  }

  Future<void> sendChat(String txt, BuildContext context) async {
    addUserMessage(txt);
    Map<String, dynamic> response = await ChatAIRepository.chatAI(prompt: txt);
    debugPrint('response ${response.toString()}');
    if (response['status'] != false) {
      String text =
          response['choices'][0]['message']['content'] ?? response['message'];
      //remove the last item
      _isLoading = false;
      _isAnimating = true;
      messages.removeLast();
      //    if (context.mounted) {
      messages.add(AiMessage(
        text: text,
        shouldAnimate: true,
      ));
    } else {
      _isLoading = false;
      messages.removeLast();
      messages.add(Text(
        response['message'],
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.deepOrange, fontSize: 14),
      ));
    }
    notifyListeners();
  }

  void addUserMessage(txt) {
    _isLoading = true;
    messages.add(UserMessage(text: txt));
    messages.add(const Loading(text: "..."));
    notifyListeners();
  }
}
