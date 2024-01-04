import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';

class UserMessage extends StatelessWidget {
  final String text;
  const UserMessage({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  height: /*MediaQuery.sizeOf(context).height*0.080*/ 60,
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
                    /*FadeInImage(
                                image: NetworkImage('$profileImg'),
                                placeholder: const AssetImage(
                                  "Assets/profile_.png",
                                ),
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return Image.asset('Assets/profile_.png',
                                      fit: BoxFit.cover);
                                },
                                fit: BoxFit.cover,
                              ),
                            */
                  ),
                )),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 3,
                top: 8,
              ),
              child: Text(
                text,
                textScaleFactor: 1.0,
                style: const TextStyle(
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
