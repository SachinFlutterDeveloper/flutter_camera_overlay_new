import 'package:cached_network_image/cached_network_image.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/views/chat_ai/viewmodels/ai_chat.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';

class UserInput extends StatelessWidget {
  final TextEditingController chatcontroller;
  final ScrollController? scrollController;
  const UserInput({
    Key? key,
    required this.chatcontroller,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 5,
            right: 5,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            border: Border(
              top: BorderSide(
                color: Color(0xffd1d5db),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: /*MediaQuery.sizeOf(context).height*0.080*/
                          60,
                      width: /*MediaQuery.sizeOf(context).width*0.22*/ 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: OnePref.getString('image').toString(),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          progressIndicatorBuilder: (context, url, progress) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Image.asset('Assets/profile_.png',
                                fit: BoxFit.cover);
                          },
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )),
              Expanded(
                flex: 5,
                child: TextFormField(
                  enabled: !context.read<ChatAIViewModel>().isLoading,
                  controller: chatcontroller,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 / MediaQuery.of(context).textScaleFactor),
                  decoration: InputDecoration(
                    focusColor: Colors.white,
                    filled: true,
                    hintText: 'How can I assist you today?',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade200.withOpacity(0.5),
                        fontSize: 16 / MediaQuery.of(context).textScaleFactor),
                    fillColor: AppColors.primaryLightColor,
                    suffixIcon: InkWell(
                      onTap: () {
                        if (!context.read<ChatAIViewModel>().isLoading) {
                          if (chatcontroller.text.trim().toString() == '') {
                            Utils.snackBarMessage(
                                'Input field cannot be empty!', context);
                          } else {
                            context
                                .read<ChatAIViewModel>()
                                .sendChat(chatcontroller.text.trim().toString(),
                                    context)
                                .then((value) {
                              if (scrollController!.hasClients) {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) {
                                  scrollController?.animateTo(
                                      scrollController!
                                          .position.maxScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 10),
                                      curve: Curves.fastOutSlowIn);
                                });
                              }
                            });
                            chatcontroller.clear();
                          }
                        } else {
                          Utils.snackBarMessage('Please wait...', context);
                        }
                      },
                      child: const Icon(
                        Icons.send,
                        color: AppColors.primary,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
