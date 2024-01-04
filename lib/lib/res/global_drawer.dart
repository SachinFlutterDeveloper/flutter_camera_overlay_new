import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:digihealthcardapp/models/Drawer_Items.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/camera_service_model.dart';
import 'package:digihealthcardapp/viewModel/user_view_model.dart';
import 'package:digihealthcardapp/views/chat_ai/viewmodels/ai_chat.viewmodel.dart';
import 'package:digihealthcardapp/views/profile/viewmodels/change_password.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DrawerContent extends StatefulWidget {
  final AnimationController controller;
  const DrawerContent({Key? key, required this.controller}) : super(key: key);

  @override
  State<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final userModel = Provider.of<User_view_model>(context);
    List<VoidCallback> drawerCallBacks = [
      () => Navigator.pushReplacementNamed(context, RoutesName.home),
      () {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        DialogBoxes.showDashboardDialog(
            context,
            'Immunization',
            () {
              Navigator.popAndPushNamed(context, RoutesName.immunization);
            },
            'Child Immunization',
            () {
              Utils.snackBarMessage('Coming soon..', context);
              Navigator.pop(context);
            },
            'Adult Immunization');
      },
      () {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        DialogBoxes.showDashboardDialog(
            context,
            'Health Cards',
            () {
              Navigator.popAndPushNamed(context, RoutesName.showCard);
            },
            'Show Cards',
            () {
              Navigator.popAndPushNamed(context, RoutesName.scanCard);
            },
            'Scan Card');
      },
      () {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        Navigator.pushNamed(context, RoutesName.test);
      },
      () {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        Navigator.pushNamed(context, RoutesName.testLocation);
      },
      () {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        DialogBoxes.showDashboardDialog(
            context,
            'Identity Cards',
            () {
              Navigator.popAndPushNamed(context, RoutesName.showID);
            },
            'Show Cards',
            () {
              Navigator.popAndPushNamed(context, RoutesName.scanID);
            },
            'Scan Card');
      },
      () {
        DialogBoxes.telehealth(context);
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
      },
      () {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        Navigator.pushNamed(context, RoutesName.profile);
      },
      () {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        DialogBoxes.showLogoutDialog(this.context);
      },
    ];
    List<VoidCallback> drawerCallbacks2 = [
      () async {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String policy = prefs.getString('policy_url').toString();
        var url = policy;
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          throw Exception('can not load $url');
        }
      },
      () async {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String terms = prefs.getString('terms_url').toString();
        var url = terms;
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          throw Exception('can not load $url');
        }
      },
      () async {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String subscriptionURL = prefs.getString('sub_url').toString();
        var url = subscriptionURL;
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          throw Exception('can not load $url');
        }
      },
      () {
        if (widget.controller.isCompleted) {
          widget.controller.reverse();
        }
        Navigator.pushNamed(context, RoutesName.subscription);
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder(
                future: userModel.getUser(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade100,
                      highlightColor: Colors.grey.shade500,
                      child: Container(
                        height: 5,
                        width: width * .5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  } else {
                    final fName = snapshot.data?.firstName.toString();
                    final lName = snapshot.data?.lastName.toString();
                    final email = snapshot.data?.email.toString();
                    final phone = (snapshot.data?.phone == 'null')
                        ? ''
                        : snapshot.data?.phone;
                    final image = snapshot.data?.image.toString();
                    return UserAccountsDrawerHeader(
                      currentAccountPicture: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: image.toString(),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            progressIndicatorBuilder: (context, url, progress) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                          value: progress.progress,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                ],
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Image.asset('Assets/profile_.png',
                                  height: height * .18,
                                  width: width * .34,
                                  fit: BoxFit.cover);
                            },
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      currentAccountPictureSize: const Size.fromRadius(32.0),
                      decoration: const BoxDecoration(color: AppColors.primary),
                      accountName: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: height * .034,
                          ),
                          Text(
                            '$fName $lName',
                            textScaleFactor: 1.0,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      accountEmail: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$email',
                            textScaleFactor: 1.0,
                            style: const TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: height * .006,
                          ),
                          Text(
                            '${phone ?? ''} ',
                            textScaleFactor: 1.0,
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    );
                  }
                }),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Dashboard',
                        textScaleFactor: 1.0,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: height * .60,
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(
                            left: 5.0,
                          ),
                          itemCount: drawerCallBacks.length,
                          itemExtent: height * .065,
                          itemBuilder: (BuildContext context, int index) {
                            if ((OnePref.getString('trial_status') ==
                                    'error') &&
                                index >= 1 &&
                                index <= 5) {
                              return SizedBox(
                                height: height * .06,
                                child: ListTile(
                                  enabled: false,
                                  style: ListTileStyle.drawer,
                                  title: Opacity(
                                      opacity: .5,
                                      child: DrawerItems.drawerTitles[index]),
                                ),
                              );
                            } else {
                              return SizedBox(
                                height: height * .06,
                                child: ListTile(
                                  onTap: drawerCallBacks[index],
                                  style: ListTileStyle.drawer,
                                  title: DrawerItems.drawerTitles[index],
                                ),
                              );
                            }
                          }),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Privacy & Terms',
                        textScaleFactor: 1.0,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: height * .28,
                      child: ListView.builder(
                          padding: const EdgeInsets.only(left: 5.0),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: drawerCallbacks2.length,
                          itemExtent: height * .065,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: height * .06,
                              child: ListTile(
                                onTap: drawerCallbacks2[index],
                                style: ListTileStyle.drawer,
                                title: DrawerItems.drawerTitles2[index],
                              ),
                            );
                          }),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Contact Us',
                        textScaleFactor: 1.0,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: ListTile(
                        onTap: () async {
                          final emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: OnePref.getString('info_mail') ??
                                'info@digihealthcard.com',
                          );
                          launchUrlString(emailLaunchUri.toString());
                        },
                        style: ListTileStyle.drawer,
                        title: Text(
                          OnePref.getString('info_mail') ??
                              'info@digihealthcard.com',
                          textScaleFactor: 1.0,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      height: height * .15,
                      width: width,
                      color: AppColors.primary,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            OnePref.getString('footer_l1') ?? '',
                            textScaleFactor: 1.0,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                          Text(
                            'version ${OnePref.getString('app_version')}',
                            textScaleFactor: 1.0,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                          Text(
                            OnePref.getString('footer_l2') ?? '',
                            textScaleFactor: 1.0,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DrawerWidget extends StatefulWidget {
  final Widget child;
  const DrawerWidget({super.key, required this.child});

  static _DrawerWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<_DrawerWidgetState>();
  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  static Duration duration = const Duration(microseconds: 300);
  static const double maxSlide = 255;
  static const dragStartRight = 60;
  static const dragStartLeft = maxSlide - 20;
  static bool shouldDrag = false;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: _DrawerWidgetState.duration);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<bool> onWillPop() async {
    bool isClosed = false;
    context.read<ChatAIViewModel>().setToEmpty();
    context.read<CameraHelper>().removeBackImage();
    context.read<ChangePasswordVM>().setStatus('');
    context.read<CameraHelper>().removeFrontImage();
    if (_animationController!.isCompleted) {
      toggle();
      isClosed = false;
    } else {
      toggle();
      isClosed = true;
    }
    return isClosed;
  }

  void close() => _animationController?.reverse();
  void open() => _animationController?.forward();

  void toggle() {
    if (_animationController!.isCompleted) {
      close();
    } else {
      open();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _animationController!,
        builder: (BuildContext context, _) {
          double animationVal = _animationController!.value;
          double translateVal = animationVal * maxSlide;
          return Stack(
            children: [
              DrawerContent(controller: _animationController!),
              Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()..translate(translateVal),
                  child:
                      WillPopScope(onWillPop: onWillPop, child: widget.child)),
            ],
          );
        },
      ),
    );
  }

  void _onDragStart(DragStartDetails startDetails) {
    bool isDraggingFromLeft = _animationController!.isDismissed &&
        startDetails.globalPosition.dx < dragStartRight;
    bool isDraggingFromRight = !_animationController!.isDismissed &&
        startDetails.globalPosition.dx > dragStartLeft;
    shouldDrag = isDraggingFromLeft || isDraggingFromRight;
  }

  void _onDragUpdate(DragUpdateDetails updateDetails) {
    if (shouldDrag == false) {
      return;
    }
    double delta = updateDetails.primaryDelta! / maxSlide;
    _animationController?.value += delta;
  }

  void _onDragEnd(DragEndDetails endDetails) {
    if (_animationController!.isCompleted ||
        _animationController!.isDismissed) {
      return;
    }
    double kMinFlingVelocity = 365.0;
    double dragVelocity = endDetails.velocity.pixelsPerSecond.dx.abs();
    if (dragVelocity >= kMinFlingVelocity) {
      double visualVelocityinPx = endDetails.velocity.pixelsPerSecond.dx /
          MediaQuery.sizeOf(context).width;
      _animationController?.fling(velocity: visualVelocityinPx);
    } else if (_animationController!.value < 0.5) {
      close();
    } else {
      open();
    }
  }
}
