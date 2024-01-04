import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:digihealthcardapp/generated/assets.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/views/chat_ai/viewmodels/ai_chat.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AiMessage extends StatelessWidget {
  final String text;
  final bool? shouldAnimate;
  const AiMessage({
    Key? key,
    required this.text,
    this.shouldAnimate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                  decoration: const BoxDecoration(
                      color: AppColors.primaryLightColor,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  padding: const EdgeInsets.all(3),
                  child: const ImageIcon(
                    AssetImage(Assets.chatbot),
                    size: 50,
                  ) /* Image.asset(
                  "images/ai-avatar.svg",
                  height: 30,
                  width: 30,
                  fit: BoxFit.contain,
                ), */
                  ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: shouldAnimate!
                  ? AnimatedTextKit(
                      key: UniqueKey(),
                      animatedTexts: [
                        TypewriterAnimatedText(
                          text,
                          textAlign: TextAlign.left,
                          textStyle: TextStyle(
                            wordSpacing: 0.2,
                            color: const Color(0xffd1d5db),
                            fontSize:
                                16 / MediaQuery.of(context).textScaleFactor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      totalRepeatCount: 1,
                      onFinished: () {
                        context.read<ChatAIViewModel>().setToUnanimate(text);
                      },
                      displayFullTextOnTap: true,
                      onTap: () {
                        context.read<ChatAIViewModel>().setToUnanimate(text);
                      },
                    )
                  : Text(
                      text,
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        wordSpacing: 0.2,
                        color: Color(0xffd1d5db),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
