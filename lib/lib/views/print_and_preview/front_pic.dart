import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

class PhotoViewer extends StatefulWidget {
  final String fImageUrl;
  final String bImageUrl;
  const PhotoViewer(
      {Key? key, required this.fImageUrl, required this.bImageUrl})
      : super(key: key);

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  int _currentIndex = 0;
  bool showShare = true;

  @override
  Widget build(BuildContext context) {
    List<String> images = [widget.fImageUrl, widget.bImageUrl];
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            setState(() {
              showShare = !showShare;
            });
          },
          onVerticalDragUpdate: (details) {
            // exit the gallery when the user swipes up
            if (details.delta.dy < -10) {
              Navigator.of(context).pop();
            }
          },
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: PhotoViewGallery.builder(
                      itemCount: images.length,
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(images[index]),
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          maxScale: PhotoViewComputedScale.covered * 2,
                        );
                      },
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      scrollPhysics: const BouncingScrollPhysics(),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      loadingBuilder: (context, event) => Center(
                        child: CircularProgressIndicator(
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (showShare)
                Stack(
                  children: [
                    Positioned(
                        top: 6,
                        right: 10,
                        child: TextButton(
                            onPressed: () {
                              Share.share(images[_currentIndex]);
                            },
                            child: Text(
                              'Share',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ))),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
