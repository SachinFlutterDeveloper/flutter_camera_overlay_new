import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/views/child_immunization/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PreviewCard extends StatefulWidget {
  final String previewUrl;
  const PreviewCard({super.key, required this.previewUrl});

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  late final WebViewController webViewController;
  var loadingPercentage = 0;
  var urlError = '';
  bool isError = false;

  @override
  void initState() {
    webViewController = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
        onWebResourceError: (WebResourceError error) {},
      ))
      ..loadRequest(Uri.parse(widget.previewUrl.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: AppColors.primaryColor,
              ))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100.0,
              ),
            Expanded(child: WebViewWidget(controller: webViewController)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CardButton(
                    height: 40,
                    width: MediaQuery.sizeOf(context).width * 0.4,
                    color: AppColors.primaryColor,
                    title: 'Done',
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
