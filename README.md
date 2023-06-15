# flutter_camera_overlay_new

# Android 13 support 

This package provides a simple camera overlay to aid capture of documents such 
as national ID cards, passports and driving licenses.

## Default ISO Card formats
https://www.iso.org/standard/70483.html

cardID1 - Most banking cards and ID cards

cardID2 - French and other ID cards. Visas.

cardID3 - United States government ID cards

simID000 - SIM cards

<img src="https://raw.githubusercontent.com/matwright/flutter_camera_overlay_new/main/example/flutter_camera_overlay_new.webp" width="300">

## Getting Started

Import the file.

```dart
import 'package:flutter_camera_overlay_new/flutter_camera_overlay_new.dart';
```

### Use with default style:

```dart
CameraOverlay(
    snapshot.data!.first,
    CardOverlay.byFormat(format),
    (XFile file) => print(file.path),
    info: 'Position your ID card within the rectangle and ensure the image is perfectly readable.',
    label: 'Scanning ID Card');
```

### TODO

* add data capture (card numbers, etc)
* automatic edge detection & capture