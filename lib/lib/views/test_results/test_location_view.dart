import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/models/custom_border.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/components/round_button.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/viewModel/Location_view_model.dart';
import 'package:digihealthcardapp/viewModel/home_view_model.dart';
import 'package:digihealthcardapp/views/chat_ai/chat_ai.dart';
import 'package:digihealthcardapp/views/profile/widgets/appbar_leading.dart';
import 'package:digihealthcardapp/views/scan_health_card/card_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TestLocationScreen extends StatefulWidget {
  const TestLocationScreen({Key? key}) : super(key: key);

  @override
  State<TestLocationScreen> createState() => _TestLocationScreenState();
}

class _TestLocationScreenState extends State<TestLocationScreen> {
  final scrollController = ScrollController();

  String? _fetchLocationURl;
  String? locationURL;
  String nextPageToken = '';
  List<dynamic> _locations = [];
  bool isLoading = false;
  TextEditingController? searchController;
  FocusNode? searchFocus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchLabels();
    DialogBoxes.showLoading();
    fetchLocations();
    fetchLocation();
    scrollController.addListener(_scrollListener);
    searchController = TextEditingController();
    searchFocus = FocusNode();
  }

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  var lat = 0.0;
  var lng = 0.0;

  List<dynamic> _filteredLocations = [];

  Future<void> fetchLocation() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.getLocation();
    final position = locationProvider.position;
    if (position != null) {
      lat = position.latitude;
      lng = position.longitude;
      // Use the latitude and longitude values here
    }
  }

  Future<void> fetchLabels() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    _fetchLocationURl = await homeViewModel.fetchLocURl();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    locationURL = prefs.getString('location_url') ?? '';
    setState(() {});
  }

  Future<void> fetchLocations() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_searchQuery.isEmpty || _searchQuery == '') {
      String url =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=vaccination+near+me&key=AIzaSyDcXui6S-AQcgRmHdZtB4rwsPR_Yo-s2f4';
      locationURL = prefs.getString('location_url') ?? url;
    } else {
      locationURL =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?key=AIzaSyDcXui6S-AQcgRmHdZtB4rwsPR_Yo-s2f4&query=vaccination+near+${_searchQuery.toString()}';
      // LocationUrl = (await prefs.getString('search_url')) +'${searchController!.text.toString()}'; /*'$url'*/
    }
    final token = nextPageToken;
    if (kDebugMode) {
      print('API CAll: $token');
    }
    final response = await http.get(Uri.parse('$locationURL&pagetoken=$token'));
    if (kDebugMode) {
      print('URL: $locationURL');
    }
    if (response.statusCode == 200) {
      var jsonBody = json.decode(response.body);
      debugPrint('${response.statusCode}  result:${jsonBody.toString()}');
      final String? nextToken;
      if (jsonBody['next_page_token'] != null) {
        nextToken = jsonBody['next_page_token'].toString();
      } else {
        nextToken = null;
      }
      await prefs.setString('token_', nextToken ?? '');
      final results = jsonBody['results'] as List;
      setState(() {
        nextPageToken = nextToken ?? '';
        _locations.addAll(results);
      });
      _addMarkers(_locations);
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Token: $nextPageToken, Results: $_locations $_markers');
      }
    } else {
      throw Exception('Failed to fetch locations');
    }
  }

  void _scrollListener() async {
    if (nextPageToken.isEmpty) {
      return;
    }
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoading) {
      if (kDebugMode) {
        print('scroll: $nextPageToken');
      }
      await fetchLocations();
      if (kDebugMode) {
        print('scroll listening $locationURL');
      }
    }
  }

  @override
  void dispose() {
    searchController?.dispose();
    searchFocus?.dispose();
    super.dispose();
    scrollController.dispose();
  }

  void _filterLocations() {
    if (_searchQuery.isNotEmpty) {
      setState(() {
        _filteredLocations = _locations
            .where((location) => location['name']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        _filteredLocations = _locations;
      });
    }
  }

  final Set<Marker> _markers = {};

  void _addMarkers(List<dynamic> locations) {
    for (var location in locations) {
      double lat = location['geometry']['location']['lat'].toDouble();
      double lng = location['geometry']['location']['lng'].toDouble();
      final name = location['name'];
      final markerId = MarkerId(name);
      final marker = Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: name),
      );
      _markers.add(marker);
      debugPrint('___markers: $_markers');
    }
  }

  ValueNotifier<int?> selectedLocationIndex = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;

    CameraPosition kGooglePlex = const CameraPosition(
      target: LatLng(25.383123, 68.363),
      zoom: 12,
    );

    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text(
                'Vaccination Center',
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              leadingWidth: 80,
              leading:
                  AppbarLeading(backCallBack: () => Navigator.pop(context)),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, RoutesName.home, (route) => false);
                    },
                    icon: const ImageIcon(
                      AssetImage(
                        'Assets/home.png',
                      ),
                      color: AppColors.primaryColor,
                    )),
              ],
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.transparent,
                    margin: const EdgeInsets.all(8),
                    child: TextFormField(
                      focusNode: searchFocus,
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          isLoading = value.isEmpty;
                        });
                        setState(() {
                          _searchQuery = value;
                          _filterLocations();
                          _locations = _filteredLocations;
                        });
                      },
                      onFieldSubmitted: (value) {
                        searchFocus?.unfocus();
                        setState(() {
                          _searchQuery = value;
                          _locations = [];
                          nextPageToken = '';
                        });
                        fetchLocations();
                        setState(() {
                          _locations = _filteredLocations;
                        });
                      },
                      decoration: buildInputDecorationSearch(context),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(0),
                            scrollDirection: Axis.vertical,
                            itemCount: _locations.length +
                                (nextPageToken.isEmpty
                                    ? 1
                                    : (isLoading ? 1 : 0)),
                            itemBuilder: (context, index) {
                              if (index < _locations.length ||
                                  index < _filteredLocations.length) {
                                final location = /*(_searchQuery.isNotEmpty)
                                    ? _filteredLocations[index]
                                    : */
                                    _locations[index];
                                if (index == 0 ||
                                    index == 20 ||
                                    index == 30 ||
                                    index == 40) {
                                  double zoom = 12.0;
                                  switch (index) {
                                    case 0:
                                      zoom = 11.5;
                                      break;
                                    case 20:
                                      zoom = 11.0;
                                      break;
                                    case 30:
                                      zoom = 10.5;
                                      break;
                                    case 40:
                                      zoom = 10.0;
                                      break;
                                    default:
                                      zoom = 10.0;
                                  }
                                  moveCameraToMarker(_markers, _mapController,
                                      _locations[index]['name'], zoom);
                                }
                                return LocationCardItem(
                                    index: index,
                                    location: location,
                                    mapController: _mapController,
                                    markers: _markers);
                              } else if (isLoading ||
                                  nextPageToken.isNotEmpty ||
                                  index > _locations.length) {
                                return Center(
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Loading',
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: height * .015,
                                      ),
                                      const CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                      ),
                                    ],
                                  ),
                                );
                              } else if (nextPageToken.isEmpty) {
                                return const Center(
                                  child: Text('No More Locations Available'),
                                );
                              } // NextpgToken is null, so return an empty container
                              return const Center(
                                child: Text('No Locations Available'),
                              );
                            }),
                        Positioned(
                          bottom: 10,
                          right: 30,
                          child: FloatingActionButton.small(
                              backgroundColor:
                                  Theme.of(context).cardColor.withOpacity(0.7),
                              child: const Icon(
                                Icons.keyboard_double_arrow_down,
                                color: Color(0xff3c3c3c),
                              ),
                              onPressed: () {
                                scrollToBottom(scrollController);
                              }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        child: GoogleMap(
                          mapType: MapType.normal,
                          myLocationButtonEnabled: true,
                          initialCameraPosition: kGooglePlex,
                          onMapCreated: (GoogleMapController controller) {
                            _mapController.complete(controller);
                          },
                          markers: _markers,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}

void moveCameraToMarker(
    Set<Marker> markers,
    Completer<GoogleMapController> mapController,
    String markerId,
    double zoom) async {
  MarkerId _currentMarker = MarkerId(markerId);
  GoogleMapController _mapController = await mapController.future;
  final currentPosition = _getMarkerPosition(markers, _currentMarker);
  _mapController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: zoom), // Get marker's position
    ),
  );
  debugPrint(
      '${_currentMarker.value} ${_getMarkerPosition(markers, _currentMarker).toString()}');
}

LatLng _getMarkerPosition(Set<Marker> markers, MarkerId markerId) {
  for (Marker marker in markers) {
    if (marker.markerId == markerId) {
      return marker.position;
    }
  }
  return const LatLng(0.0, 0.0);
}

InputDecoration buildInputDecorationSearch(BuildContext context) {
  return InputDecoration(
    label: const Text(
      'Search',
      textScaleFactor: 1.0,
    ),
    hintText: 'Search',
    hintStyle: TextStyle(color: Theme.of(context).primaryColorLight),
    prefixIcon: Icon(
      Icons.search_outlined,
      color: Theme.of(context).primaryColorLight,
    ),
    fillColor: Theme.of(context).cardColor,
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primaryColor),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffE4E7EB)),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

void showLocationDialog(BuildContext context, dynamic location) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AlertDialog(
            shape: const CustomShapeBorder(radius: 10),
            actionsPadding: const EdgeInsets.all(10),
            actionsAlignment: MainAxisAlignment.center,
            contentPadding: const EdgeInsets.all(10),
            insetPadding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * .22,
                horizontal: MediaQuery.of(context).size.width * .010),
            // icon: ImageIcon(AssetImage('Assets/ic_launcher_round.png'), size: 80, ),
            title: const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Center(
                  child: Text(
                'DigiHealthCard',
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
              )),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Location :',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * .65,
                        child: Text(
                          '${location['name']}',
                          textScaleFactor: 1.0,
                        ))
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Row(
                  children: [
                    Text(
                      'Phone :',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '',
                      textScaleFactor: 1.0,
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Text(
                      'Address :',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * .65,
                        child: Text(
                          '${location['formatted_address']}',
                          textScaleFactor: 1.0,
                        ))
                  ],
                )
              ],
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Ink(
                          height: MediaQuery.of(context).size.height * .05,
                          width: MediaQuery.of(context).size.width * .25,
                          decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(8)),
                          child: const Center(
                              child: Text(
                            'Call Now',
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Ink(
                          height: MediaQuery.of(context).size.height * .05,
                          width: MediaQuery.of(context).size.width * .25,
                          decoration: BoxDecoration(
                              color: AppColors.primaryLightColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Center(
                              child: Text(
                            'Website',
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.of(context).pop();
                          final double? lat = location['geometry']['location']
                                  ['lat']
                              .toDouble();
                          final double? lng = location['geometry']['location']
                                  ['lng']
                              .toDouble();
                          final String? destination =
                              location['formatted_address'];
                          String? url = '';
                          if(Platform.isAndroid) {
                            url =
                                'google.navigation:q=${Uri.encodeQueryComponent(destination ?? '')}&mode=d&entry=fnlr&dir_action=navigate';
                          }else
                          {
                            url = 'https://maps.apple.com/?q=${Uri.encodeQueryComponent(destination ?? '')}';
                          }
                          final uri = Uri.parse(url);
                          if (kDebugMode) {
                            print(url);
                          }
                          if (!await launchUrl(uri,
                              mode: LaunchMode.externalApplication)) {
                            throw Exception('can not load $url');
                          }
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * .05,
                          width: MediaQuery.of(context).size.width * .25,
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Center(
                              child: Text(
                            'Directions',
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RoundButtonBlack(
                      title: "Done",
                      onPress: () {
                        Navigator.of(context).pop();
                      })
                ],
              )
            ],
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * .18,
              child: Image.asset(
                'Assets/icon_logo.png',
                height: 50,
                width: 50,
              )),
        ],
      );
    },
  );
}

class LocationCardItem extends StatelessWidget {
  final int index;
  final dynamic location;
  final Completer<GoogleMapController> mapController;
  final Set<Marker> markers;
  const LocationCardItem(
      {super.key,
      required this.index,
      required this.location,
      required this.mapController,
      required this.markers});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showLocationDialog(context, location);
        context.read<CardViewModel>().selectIndex(index);
        if (kDebugMode) {
          print('selected');
        }
        moveCameraToMarker(markers, mapController, location['name'], 18);
      },
      child: Card(
          color: context.watch<CardViewModel>().selectedIndex == index
              ? (Theme.of(context).brightness == Brightness.dark)
                  ? Colors.grey[600]
                  : Colors.grey[300]
              : Theme.of(context).cardColor,
          semanticContainer: true,
          elevation: 5,
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.24,
                      child: const Text(
                        'Location :',
                        textScaleFactor: 1.0,
                        // textScaleFactor: MediaQuery.of(context).textScaleFactor,
                        style: TextStyle(
                            color: AppColors.primaryColor, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * .020,
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * .60,
                      child: Text(
                        location['name'],
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .025,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.24,
                      child: const Text(
                        'Address :',
                        textScaleFactor: 1.0,
                        style: TextStyle(
                            color: AppColors.primaryColor, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * .020,
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * .60,
                      child: Text(
                        location['formatted_address'],
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
