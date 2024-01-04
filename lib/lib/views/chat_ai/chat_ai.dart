import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/views/chat_ai/viewmodels/ai_chat.viewmodel.dart';
import 'package:digihealthcardapp/views/chat_ai/widgets/user_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../profile/widgets/appbar_leading.dart';

class AIChat extends StatefulWidget {
  const AIChat({super.key});

  static _AIChatState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AIChatState>();

  @override
  State<AIChat> createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> {
  late final TextEditingController chatcontroller;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    chatcontroller = TextEditingController();
    // scrollController = ScrollController(
    //   onAttach: (position) {
    //     position.maxScrollExtent;
    //     scrollController.animateTo(position.maxScrollExtent,
    //         duration: const Duration(milliseconds: 500),
    //       curve: Curves.easeOut);
    //   },
    // );
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    chatcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      }
    });
    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'DigiChat AI',
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              leading: AppbarLeading(
                backCallBack: () {
                  context.read<ChatAIViewModel>().setToEmpty();
                  Navigator.of(context).pop();
                },
              ),
              leadingWidth: 80,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const ImageIcon(
                      AssetImage(
                        'Assets/home.png',
                      ),
                      color: AppColors.primaryColor,
                    )),
              ],
            ),
            body: Consumer<ChatAIViewModel>(
              builder: (context, chat, child) {
                final messages = chat.getMessages;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: !context.watch<ChatAIViewModel>().isAnimating
                          ? const EdgeInsets.only(bottom: 80)
                          : const EdgeInsets.only(bottom: 0),
                      child: messages.isEmpty
                          ? const SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Choose from the questions below',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    PromptButton(
                                        title: 'Feeding',
                                        prompt:
                                            'How often should I breastfeed or bottle-feed my baby?'),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    PromptButton(
                                        title: 'Hygiene',
                                        prompt:
                                            'When and how should I give my baby their first bath?'),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    PromptButton(
                                        title: 'Parenting and Lifestyle',
                                        prompt:
                                            'How can I establish a sleep routine for my baby?'),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    PromptButton(
                                        title: 'Health & Safety',
                                        prompt:
                                            'How do I take my baby\'s temperature?'),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Text(
                                      textScaleFactor: 1.0,
                                      'You can ask more questions as per your specific need.',
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : ListView(controller: scrollController, children: [
                              const Divider(
                                color: Color(0xffd1d5db),
                              ),
                              for (int i = 0; i < messages.length; i++)
                                messages[i]
                            ]),
                    ),
                    Positioned(
                      bottom: 100,
                      right: 20,
                      child: FloatingActionButton.small(
                          backgroundColor:
                              Theme.of(context).cardColor.withOpacity(0.5),
                          child: const Icon(
                            Icons.keyboard_double_arrow_down,
                            color: Color(0xff3c3c3c),
                          ),
                          onPressed: () {
                            scrollToBottom(scrollController);
                          }),
                    ),
                    //input
                    !context.watch<ChatAIViewModel>().isAnimating
                        ? UserInput(
                            scrollController: scrollController,
                            chatcontroller: chatcontroller,
                          )
                        : const SizedBox(
                            height: 10,
                          )
                  ],
                );
              },
            )),
      ),
    );
  }
}

class PromptButton extends StatelessWidget {
  const PromptButton({
    super.key,
    required this.title,
    required this.prompt,
  });
  final String title;
  final String prompt;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
          fixedSize: MaterialStateProperty.resolveWith((states) =>
              Size.fromWidth(MediaQuery.sizeOf(context).width * .9)),
          shape: MaterialStateProperty.resolveWith((states) =>
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
      onPressed: () {
        context.read<ChatAIViewModel>().sendChat(prompt, context);
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  textScaleFactor: 1.0,
                  style: Theme.of(context).primaryTextTheme.labelLarge),
              const SizedBox(
                height: 5,
              ),
              Text(
                prompt,
                textScaleFactor: 1.0,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void scrollToItem(ScrollController scrollController, int itemCount) {
  if (scrollController.hasClients) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(itemCount.toDouble());
    });
  }
}

void scrollToBottom(ScrollController scrollController) {
  if (scrollController.hasClients) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 10),
          curve: Curves.fastOutSlowIn);
    });
  }
}
