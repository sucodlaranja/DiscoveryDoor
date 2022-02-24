import 'dart:async';
import 'dart:convert';

import 'package:discovery_door/aux/colors.dart';
import 'package:discovery_door/data/directions_repository.dart';
import 'package:discovery_door/data/museum.dart';
import 'package:discovery_door/data/regist.dart';
import 'package:discovery_door/data/review.dart';
import 'package:discovery_door/aux/methods.dart';
import 'package:discovery_door/screens/app_start/splash_screen.dart';
import 'package:discovery_door/data/directions.dart';
import 'package:discovery_door/screens/finder.dart';
import 'package:discovery_door/screens/history.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MainMenuScreen extends StatefulWidget {
  final String username;
  final bool showMuseum;
  final Museum? museum;

  const MainMenuScreen(
      {Key? key, required this.username, required this.showMuseum, this.museum})
      : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(41.550278, -8.42),
    zoom: 12,
  );

  late String _username;

  int _stars = 0;
  int _starsLO = 0;
  int _transport = 1;

  double _swipe = 680;

  late DateTime _start;
  late DateTime _stop;

  bool _showEndDrive = false;
  bool _isDriving = false;
  bool _showMuseumData = false;
  bool _showChooseTransport = false;
  bool _showAddReview = false;
  bool _isPosting = false;
  bool _logOut = false;

  late Museum _museum;
  late Position _currentPosition;

  final Completer<GoogleMapController> _controllerGoogleMapComp = Completer();
  late GoogleMapController _googleMapController;
  late Directions? _info;

  final _textControllerSearch = TextEditingController();
  final _textControllerReview = TextEditingController();
  bool _museumError = false;

  @override
  void initState() {
    _info = null;
    _username = widget.username;
    _showMuseumData = widget.showMuseum;
    if (widget.museum != null) _museum = widget.museum!;
    super.initState();
  }

  void _locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);

    _googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _museumLocation(double lat, double lng) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;

    LatLng latLngPosition = LatLng(lat, lng);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);
    _googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    final directions = await DirectionsRepository().getDirections(
      origin: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      destination: latLngPosition,
      transport: _transport,
    );

    setState(() {
      _info = directions;
    });
    if (_info != null) {
      _googleMapController
          .animateCamera(CameraUpdate.newLatLngBounds(_info!.bounds!, 100.0));
    }
  }

  Widget _buildSearchField() {
    final width = _showMuseumData ? 250 : 275;

    return Container(
      height: 40 * unitHeightValue(context),
      width: width * unitWidthValue(context),
      decoration: BoxDecoration(
        border: Border.all(
          color: kScreenDark,
          width: 1.25 * unitWidthValue(context),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: TextField(
        maxLines: 1,
        controller: _textControllerSearch,
        style: TextStyle(
          color: kScreenDark,
          fontSize: 18.5 * unitHeightValue(context),
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          filled: true,
          suffixIcon: _buildSearchButton(),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          fillColor: Colors.white,
          contentPadding: EdgeInsets.only(left: 15 * unitWidthValue(context)),
          hintText: 'Search',
          hintStyle: TextStyle(
            fontSize: 20 * unitHeightValue(context),
            color: kScreenDark.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return InkWell(
      child: Icon(
        Icons.search,
        color: kScreenDark,
      ),
      onTap: () {
        final FocusScopeNode currentScope = FocusScope.of(context);
        if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
        _runSearch();
      },
    );
  }

  Future<Museum> _getMuseumByName(String name) async {
    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/getMuseumByName?mName=$name'));

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      return Museum.fromJson(json);
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  void _runSearch() {
    final name = _textControllerSearch.text;
    final museum = _getMuseumByName(name);

    museum.then((value) {
      if (value.name.isEmpty) {
        setState(() {
          _museumError = true;
          _textControllerSearch.clear();
        });
      } else {
        setState(() {
          _museumLocation(value.lat, value.lng);

          _textControllerSearch.clear();
          _museum = value;
          _swipe = 680;
          _showMuseumData = true;
        });
      }
    });
  }

  Widget _buildErrorPopUp() {
    return Container(
      alignment: Alignment.center,
      width: screenWidth(context),
      height: screenHeight(context),
      color: Colors.black.withOpacity(0.6),
      child: Container(
        width: 300 * unitWidthValue(context),
        height: 170 * unitHeightValue(context),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15 * unitHeightValue(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10 * unitWidthValue(context),
                      right: 10 * unitWidthValue(context),
                    ),
                    child: Icon(
                      Icons.warning_amber,
                      color: kScreenDark,
                      size: 32 * unitWidthValue(context),
                    ),
                  ),
                  Text(
                    'Museum not found!',
                    style: TextStyle(
                      fontSize: 20 * unitWidthValue(context),
                      color: kScreenDark,
                      decoration: TextDecoration.none,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 15 * unitHeightValue(context),
                left: 15 * unitWidthValue(context),
              ),
              child: Text(
                'Try searching for a different museum name.',
                style: TextStyle(
                  color: kScreenDark.withOpacity(0.6),
                  fontSize: 10.5 * unitWidthValue(context),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 35 * unitHeightValue(context),
                left: 225 * unitWidthValue(context),
              ),
              child: GestureDetector(
                onTap: () => setState(() {
                  _museumError = false;
                }),
                child: Container(
                  alignment: Alignment.center,
                  width: 60 * unitWidthValue(context),
                  height: 40 * unitHeightValue(context),
                  decoration: BoxDecoration(
                    color: kScreenDark,
                    borderRadius: const BorderRadius.all(Radius.circular(12.5)),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22 * unitHeightValue(context),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String text, GestureTapCallback onTap) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 22 * unitWidthValue(context),
        ),
      ),
      onTap: onTap,
    );
  }

  Future<List<Regist>> _getUserHistory() async {
    final name = _username;

    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/getHistory?uName=$name'));

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      return json.map<Regist>((json) => Regist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 30 * unitHeightValue(context),
          ),
          _buildDrawerItem(
            'Histórico',
            () => _getUserHistory().then(
              (value) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                    history: value,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15 * unitHeightValue(context),
          ),
          _buildDrawerItem(
              'Terminar Sessão',
              () => setState(() {
                    _logOut = true;
                  })),
        ],
      ),
    );
  }

  void _setAppRate() async {
    http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/rateSystem?uName=$_username&score=$_starsLO'));
  }

  Widget _buildTransportButton(IconData icon, String name, int transport) {
    return InkWell(
      onTap: () {
        setState(() {
          _transport = transport;
          _museumLocation(_museum.lat, _museum.lng);
          _showChooseTransport = false;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 15 * unitWidthValue(context)),
        height: 50 * unitHeightValue(context),
        width: screenWidth(context),
        child: Row(
          children: [
            Icon(
              icon,
              size: 25 * unitWidthValue(context),
            ),
            SizedBox(
              width: 10 * unitWidthValue(context),
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: 24 * unitWidthValue(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChooseTransport() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          alignment: Alignment.center,
          width: screenWidth(context),
          height: screenHeight(context),
          color: Colors.black.withOpacity(0.6),
          child: Container(
            width: 300 * unitWidthValue(context),
            height: 240 * unitHeightValue(context),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15 * unitHeightValue(context)),
                  child: Container(
                    width: screenWidth(context),
                    alignment: Alignment.center,
                    child: Text(
                      'Choose transport',
                      style: TextStyle(
                        fontSize: 25 * unitWidthValue(context),
                        color: kScreenDark,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1 * unitHeightValue(context),
                  height: 20 * unitHeightValue(context),
                  endIndent: 50 * unitWidthValue(context),
                  indent: 50 * unitWidthValue(context),
                ),
                _buildTransportButton(Icons.directions_car, 'Driving', 1),
                _buildTransportButton(Icons.directions_walk, 'Walking', 2),
                _buildTransportButton(Icons.directions_bike, 'Bicycling', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      initialCameraPosition: _initialCameraPosition,
      polylines: {
        if (_info != null)
          Polyline(
            polylineId: const PolylineId('overview_polyline'),
            color: Colors.red,
            width: 5,
            points: _info!.polylinePoints!
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList(),
          ),
      },
      onMapCreated: (controller) {
        _controllerGoogleMapComp.complete(controller);
        _googleMapController = controller;

        if (widget.museum == null) {
          _locatePosition();
        } else {
          _museumLocation(_museum.lat, _museum.lng);
        }
      },
    );
  }

  Widget _buildMyLocationButton() {
    final top = _showMuseumData
        ? (_swipe - 50 * unitHeightValue(context)) * unitHeightValue(context)
        : screenHeight(context) - 200 * unitHeightValue(context);

    return Padding(
      padding: EdgeInsets.only(
        top: top,
        left: screenWidth(context) - 70 * unitWidthValue(context),
      ),
      child: InkWell(
        onTap: _locatePosition,
        child: Container(
          padding: EdgeInsets.all(7 * unitWidthValue(context)),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.gps_fixed,
            color: kScreenDark,
            size: 25 * unitWidthValue(context),
          ),
        ),
      ),
    );
  }

  Future<List<String>> _getCategories() async {
    final response = await http.get(
        Uri.parse('https://backenddiscoverdoor.azurewebsites.net/getThemes'));

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      List<String> categories = List.from(json);
      return categories;
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  Widget _buildFinderButton() {
    return Padding(
      padding: EdgeInsets.only(
          top: screenHeight(context) - 125 * unitHeightValue(context),
          left: screenWidth(context) - 125 * unitWidthValue(context)),
      child: InkWell(
        onTap: () {
          final categories = _getCategories();

          categories.then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinderScreen(
                  username: _username,
                  categories: value,
                ),
              ),
            );
          });
        },
        child: Container(
          width: 105 * unitWidthValue(context),
          height: 105 * unitHeightValue(context),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Image.asset(
              "assets/appimages/Museum.png",
              height: 45 * unitHeightValue(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMuseumPrice(Museum museum) {
    final price = museum.price < 0
        ? 'Free'
        : museum.price == 0
            ? 'Undef'
            : museum.price.toString() + ' €';

    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow.shade700,
        borderRadius: const BorderRadius.all(Radius.circular(45)),
      ),
      width: 70 * unitWidthValue(context),
      height: 35 * unitHeightValue(context),
      alignment: Alignment.center,
      child: Text(
        price,
        style: TextStyle(
          fontSize: 18 * unitWidthValue(context),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMuseumCategory(Museum museum) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: const BorderRadius.all(Radius.circular(45)),
      ),
      width: 12 * museum.category.length * unitWidthValue(context),
      height: 35 * unitHeightValue(context),
      alignment: Alignment.center,
      child: Text(
        museum.category,
        style: TextStyle(
          fontSize: 18 * unitWidthValue(context),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStarIcon(double limit, double size, Color color) {
    return Container(
      height: limit * unitHeightValue(context),
      width: limit * unitHeightValue(context),
      alignment: Alignment.center,
      child: Icon(
        Icons.star,
        color: color,
        size: size,
      ),
    );
  }

  Widget _buildMuseumStars(double index, double evaluation) {
    final double value = index > evaluation.floor()
        ? 0
        : index == evaluation.floor()
            ? evaluation - evaluation.floor()
            : 1;
    return Stack(
      children: [
        _buildStarIcon(
          30,
          25 * unitHeightValue(context),
          Colors.grey.shade900,
        ),
        ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              stops: [
                value,
                value,
              ],
              colors: [
                Colors.yellow.shade600,
                Colors.grey.shade600,
              ]).createShader(bounds),
          child: _buildStarIcon(
            30,
            17 * unitHeightValue(context),
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosList() {
    List<Widget> widgetList = _museum.photos
        .map(
          (e) => Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  e,
                  height: 160 * unitHeightValue(context),
                  width: 200 * unitWidthValue(context),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 10 * unitWidthValue(context),
              ),
            ],
          ),
        )
        .toList();

    return SizedBox(
      height: 160 * unitHeightValue(context),
      width: screenWidth(context),
      child: ListView(
        children: widgetList,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _buildMuseumDataLine(IconData icon, Color color, String text) {
    return Container(
      padding: EdgeInsets.only(top: 10 * unitHeightValue(context)),
      width: screenWidth(context),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 22 * unitWidthValue(context),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5 * unitWidthValue(context)),
            child: Text(
              text,
              style: TextStyle(fontSize: 14 * unitWidthValue(context)),
            ),
          )
        ],
      ),
    );
  }

  _openWebsite() async {
    if (await canLaunch(_museum.website)) {
      await launch(_museum.website);
    } else {
      throw 'Could not launch $_museum.website';
    }
  }

  Widget _buildMuseumWebsite() {
    return InkWell(
      onTap: () => _openWebsite(),
      child: Container(
        padding: EdgeInsets.only(top: 10 * unitHeightValue(context)),
        width: screenWidth(context),
        child: Row(
          children: [
            Icon(
              Icons.web,
              color: Colors.blue.shade900,
              size: 22 * unitWidthValue(context),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5 * unitWidthValue(context)),
              child: Text(
                _museum.website,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 14 * unitWidthValue(context),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddReviewButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _showAddReview = true;
        });
      },
      child: Container(
        width: 95 * unitWidthValue(context),
        height: 35 * unitHeightValue(context),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade900,
              width: 0.75,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              Icons.message,
              size: 20 * unitHeightValue(context),
              color: Colors.blue.shade900,
            ),
            Text(
              'Review',
              style: TextStyle(
                fontSize: 16 * unitWidthValue(context),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsTitle() {
    return Padding(
      padding: EdgeInsets.only(
        top: 17.5 * unitHeightValue(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontSize: 23.5 * unitWidthValue(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          _buildAddReviewButton()
        ],
      ),
    );
  }

  Widget _buildCommentBox(Review review) {
    return Padding(
      padding: EdgeInsets.all(7 * unitWidthValue(context)),
      child: Container(
        padding: EdgeInsets.only(
          top: 10 * unitHeightValue(context),
          bottom: 10 * unitHeightValue(context),
          left: 10 * unitWidthValue(context),
          right: 10 * unitWidthValue(context),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 25 * unitWidthValue(context)),
              width: screenWidth(context),
              child: Text(
                review.username,
                style: TextStyle(
                  fontSize: 16 * unitWidthValue(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 25 * unitWidthValue(context)),
              width: screenWidth(context),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 0.6,
                    child: _buildMuseumStars(0, review.evaluation),
                  ),
                  Transform.scale(
                    scale: 0.6,
                    child: _buildMuseumStars(1, review.evaluation),
                  ),
                  Transform.scale(
                    scale: 0.6,
                    child: _buildMuseumStars(2, review.evaluation),
                  ),
                  Transform.scale(
                    scale: 0.6,
                    child: _buildMuseumStars(3, review.evaluation),
                  ),
                  Transform.scale(
                    scale: 0.6,
                    child: _buildMuseumStars(4, review.evaluation),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 25 * unitWidthValue(context),
                bottom: 20 * unitHeightValue(context),
              ),
              width: screenWidth(context),
              child: Text(
                review.date,
                style: TextStyle(
                  fontSize: 13 * unitWidthValue(context),
                ),
              ),
            ),
            Text(
              review.text,
              style: TextStyle(
                fontSize: 16 * unitWidthValue(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuseumDataList() {
    List<Widget> widgetList = [];

    if (_swipe < 660) {
      widgetList.add(_buildPhotosList());
      widgetList.add(
        _buildMuseumDataLine(Icons.room, Colors.red.shade900, _museum.address),
      );
      widgetList.add(
        _buildMuseumWebsite(),
      );
      widgetList.add(
        _buildMuseumDataLine(Icons.phone, Colors.black, _museum.contact),
      );
      widgetList.add(_buildCommentsTitle());

      if (_museum.reviews.isEmpty) {
        widgetList.add(
          Padding(
            padding: EdgeInsets.all(20 * unitWidthValue(context)),
            child: Container(
              height: 100 * unitHeightValue(context),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  'Sem comentários!',
                  style: TextStyle(
                    fontSize: 20 * unitWidthValue(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        List<Widget> wl =
            _museum.reviews.map((e) => _buildCommentBox(e)).toList();

        widgetList.addAll(wl);
      }
    }

    return Expanded(
      child: ListView(
        children: widgetList,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(top: 20 * unitHeightValue(context)),
      ),
    );
  }

  Widget _buildMuseumPage() {
    final duration = _info == null ? 'und' : _info!.totalDuration;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: _swipe * unitHeightValue(context)),
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _swipe += details.delta.dy;
              });
            },
            onVerticalDragEnd: (details) {
              if (_swipe > 720) {
                setState(() {
                  _showMuseumData = false;
                  _info = null;
                });
              } else if (_swipe > screenHeight(context) / 2) {
                setState(() {
                  _swipe = 680;
                });
              } else {
                setState(() {
                  _swipe = 100;
                });
              }
            },
            child: Container(
              color: Colors.transparent,
              height: 30 * unitHeightValue(context),
              width: screenWidth(context),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                height: 10 * unitHeightValue(context),
                width: 175 * unitWidthValue(context),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
              left: 10 * unitWidthValue(context),
              right: 10 * unitWidthValue(context),
              top: 10 * unitWidthValue(context),
            ),
            width: screenWidth(context),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: 10 * unitWidthValue(context)),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 250 * unitWidthValue(context),
                            child: Text(
                              _museum.name,
                              style: TextStyle(
                                fontSize: 22 * unitWidthValue(context),
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          SizedBox(
                            width: 250 * unitWidthValue(context),
                            child: Row(
                              children: [
                                _buildMuseumStars(0, _museum.evaluation),
                                _buildMuseumStars(1, _museum.evaluation),
                                _buildMuseumStars(2, _museum.evaluation),
                                _buildMuseumStars(3, _museum.evaluation),
                                _buildMuseumStars(4, _museum.evaluation),
                                InkWell(
                                  onTap: () => setState(() {
                                    _showChooseTransport = true;
                                  }),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 20 * unitWidthValue(context),
                                          right: 5 * unitWidthValue(context),
                                        ),
                                        child: Icon(
                                          _transport == 1
                                              ? Icons.drive_eta
                                              : _transport == 2
                                                  ? Icons.directions_walk
                                                  : Icons.directions_bike,
                                          size: 20 * unitWidthValue(context),
                                        ),
                                      ),
                                      Text(
                                        duration!,
                                        style: TextStyle(
                                          fontSize:
                                              15 * unitWidthValue(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 40 * unitHeightValue(context),
                            width: 250 * unitWidthValue(context),
                            child: Row(
                              children: [
                                _buildMuseumPrice(_museum),
                                SizedBox(
                                  width: 10 * unitWidthValue(context),
                                ),
                                _buildMuseumCategory(_museum),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        _museum.photos[0],
                        height: 110 * unitHeightValue(context),
                        width: 110 * unitWidthValue(context),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10 * unitHeightValue(context),
                ),
                _buildMuseumDataList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogOutPopUp() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          alignment: Alignment.center,
          width: screenWidth(context),
          height: screenHeight(context),
          color: Colors.black.withOpacity(0.6),
          child: Container(
            width: 300 * unitWidthValue(context),
            height: 200 * unitHeightValue(context),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15 * unitHeightValue(context)),
                  child: Container(
                    width: screenWidth(context),
                    alignment: Alignment.center,
                    child: Text(
                      'Rate us!',
                      style: TextStyle(
                        fontSize: 28 * unitWidthValue(context),
                        color: kScreenDark,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1 * unitHeightValue(context),
                  height: 20 * unitHeightValue(context),
                  endIndent: 50 * unitWidthValue(context),
                  indent: 50 * unitWidthValue(context),
                ),
                _buildStarsRow(),
                Padding(
                  padding: EdgeInsets.only(
                    top: 15 * unitHeightValue(context),
                    left: 185 * unitWidthValue(context),
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _setAppRate();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SplashScreen(),
                        ),
                        (route) => false,
                      );
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      width: 100 * unitWidthValue(context),
                      height: 50 * unitHeightValue(context),
                      decoration: BoxDecoration(
                        color: Colors.red.shade800,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Text(
                        'LOG OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22 * unitHeightValue(context),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _addToHistory() async {
    final time = _stop.difference(_start).inMinutes;

    final name = _museum.name;
    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/addToHistory?uName=$_username&mName=$name&tot=$time'));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  Widget _buildEndDrivingPopUp() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.center,
        width: screenWidth(context),
        height: screenHeight(context),
        color: Colors.black.withOpacity(0.6),
        child: Container(
          width: 300 * unitWidthValue(context),
          height: 150 * unitHeightValue(context),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth(context),
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 15 * unitHeightValue(context)),
                child: Text(
                  'Did you reach your destination?',
                  style: TextStyle(
                    fontSize: 18 * unitWidthValue(context),
                    color: kScreenDark,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 40 * unitHeightValue(context),
                  left: 35 * unitWidthValue(context),
                  right: 35 * unitWidthValue(context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _museumLocation(_museum.lat, _museum.lng);
                        _showEndDrive = false;
                      }),
                      child: Container(
                        alignment: Alignment.center,
                        width: 100 * unitWidthValue(context),
                        height: 50 * unitHeightValue(context),
                        decoration: BoxDecoration(
                          color: kScreenDark,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.5)),
                        ),
                        child: Text(
                          'Não',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19 * unitHeightValue(context),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10 * unitWidthValue(context),
                    ),
                    GestureDetector(
                      onTap: () {
                        final add = _addToHistory();

                        add.then((value) {
                          setState(() {
                            _info = null;
                            _showMuseumData = false;
                            _showEndDrive = false;
                          });
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 100 * unitWidthValue(context),
                        height: 50 * unitHeightValue(context),
                        decoration: BoxDecoration(
                          color: kScreenDark,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.5)),
                        ),
                        child: Text(
                          'Sim',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18 * unitHeightValue(context),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitButton() {
    final color = _isDriving ? Colors.red.shade800 : Colors.blue.shade800;
    final text = _isDriving ? 'Stop' : 'Visit';

    final top = _swipe < 300
        ? screenHeight(context) - 75 * unitHeightValue(context)
        : (_swipe - 45 * unitHeightValue(context)) * unitHeightValue(context);

    final left = _swipe < 300
        ? screenWidth(context) - 125 * unitWidthValue(context)
        : 30 * unitWidthValue(context);

    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isDriving = !_isDriving;
          });

          if (_isDriving) {
            _start = DateTime.now();
            _locatePosition();
          } else {
            setState(() {
              _stop = DateTime.now();
              _showEndDrive = true;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(45)),
          ),
          width: 110 * unitWidthValue(context),
          height: 40 * unitHeightValue(context),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 5 * unitWidthValue(context)),
                child: Icon(
                  Icons.subdirectory_arrow_right,
                  color: Colors.white,
                  size: 25 * unitHeightValue(context),
                ),
              ),
              SizedBox(
                width: 55 * unitWidthValue(context),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 20 * unitWidthValue(context),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarWithBorder(int number, double size1, double size2) {
    final insideColor = _logOut
        ? number <= _starsLO
            ? Colors.yellow.shade600
            : Colors.grey
        : number <= _stars
            ? Colors.yellow.shade600
            : Colors.grey;
    return Stack(
      children: [
        _buildStarIcon(
          50,
          size1 * unitHeightValue(context),
          Colors.grey.shade900,
        ),
        _buildStarIcon(
          50,
          size2 * unitHeightValue(context),
          insideColor,
        ),
      ],
    );
  }

  Widget _buildStarButton(int number) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_logOut) {
            _starsLO = number;
          } else {
            _stars = number;
          }
        });
      },
      child: _buildStarWithBorder(number, 45, 35),
    );
  }

  Widget _buildStarsRow() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20 * unitWidthValue(context),
        right: 20 * unitWidthValue(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStarButton(1),
          _buildStarButton(2),
          _buildStarButton(3),
          _buildStarButton(4),
          _buildStarButton(5),
        ],
      ),
    );
  }

  Future<bool> _createReview() async {
    final mName = _museum.name;
    final comment = _textControllerReview.text;

    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/review?uName=$_username&mName=$mName&score=$_stars&comment=$comment'));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  Widget _buildAddReview() {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              alignment: Alignment.center,
              width: screenWidth(context),
              height: screenHeight(context),
              color: Colors.black.withOpacity(0.6),
              child: Container(
                width: 300 * unitWidthValue(context),
                height: 435 * unitHeightValue(context),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(top: 15 * unitHeightValue(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10 * unitWidthValue(context),
                              right: 10 * unitWidthValue(context),
                            ),
                            child: Icon(
                              Icons.comment,
                              color: Colors.blue.shade700,
                              size: 30 * unitWidthValue(context),
                            ),
                          ),
                          Text(
                            'Review the Museum',
                            style: TextStyle(
                              fontSize: 20 * unitWidthValue(context),
                              color: kScreenDark,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1 * unitHeightValue(context),
                      height: 10 * unitHeightValue(context),
                      endIndent: 50 * unitWidthValue(context),
                      indent: 50 * unitWidthValue(context),
                    ),
                    _buildStarsRow(),
                    Divider(
                      color: Colors.black,
                      thickness: 1 * unitHeightValue(context),
                      height: 10 * unitHeightValue(context),
                      endIndent: 50 * unitWidthValue(context),
                      indent: 50 * unitWidthValue(context),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10 * unitWidthValue(context)),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 10 * unitHeightValue(context),
                          bottom: 10 * unitHeightValue(context),
                        ),
                        height: 225 * unitHeightValue(context),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          expands: true,
                          controller: _textControllerReview,
                          style: TextStyle(
                            color: kScreenDark,
                            fontSize: 18.5 * unitHeightValue(context),
                          ),
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.only(
                              left: 15 * unitWidthValue(context),
                              right: 15 * unitWidthValue(context),
                            ),
                            hintText: 'Write a comment here',
                            hintStyle: TextStyle(
                              fontSize: 15 * unitHeightValue(context),
                              color: kScreenDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10 * unitHeightValue(context),
                        left: 150 * unitWidthValue(context),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              _stars = 0;
                              _textControllerReview.clear();
                              _showAddReview = false;
                            }),
                            child: Container(
                              alignment: Alignment.center,
                              width: 60 * unitWidthValue(context),
                              height: 40 * unitHeightValue(context),
                              decoration: BoxDecoration(
                                color: Colors.red.shade800,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.5)),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18 * unitHeightValue(context),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10 * unitWidthValue(context),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPosting = true;
                              });
                              final review = _createReview();

                              review.then((value) {
                                print(_museum.name);
                                final museum = _getMuseumByName(_museum.name);

                                museum.then((value) {
                                  setState(() {
                                    _stars = 0;
                                    _museum = value;
                                    _textControllerReview.clear();
                                    _isPosting = false;
                                    _showAddReview = false;
                                  });
                                });
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 60 * unitWidthValue(context),
                              height: 40 * unitHeightValue(context),
                              decoration: BoxDecoration(
                                color: kScreenDark,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.5)),
                              ),
                              child: Text(
                                'Post',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18 * unitHeightValue(context),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isPosting)
          Container(
            alignment: Alignment.topCenter,
            width: screenWidth(context),
            height: screenHeight(context),
            padding: EdgeInsets.only(top: 700 * unitHeightValue(context)),
            child: SpinKitFadingCube(
              color: Colors.white,
              size: 30 * unitHeightValue(context),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          drawer: _buildDrawer(),
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: kScreenDark,
                  size: 40 * unitHeightValue(context),
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: [
              if (_showMuseumData)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/appimages/Museum.png",
                    width: 50 * unitWidthValue(context),
                  ),
                ),
            ],
            title: _buildSearchField(),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ),
          body: Stack(
            children: [
              _buildMap(),
              if (_swipe > 400) _buildMyLocationButton(),
              if (!_showMuseumData) _buildFinderButton(),
              if (_showMuseumData) _buildMuseumPage(),
              if (_showMuseumData) _buildVisitButton(),
            ],
          ),
        ),
        if (_museumError) _buildErrorPopUp(),
        if (_showAddReview) _buildAddReview(),
        if (_showChooseTransport) _buildChooseTransport(),
        if (_logOut) _buildLogOutPopUp(),
        if (_showEndDrive) _buildEndDrivingPopUp(),
      ],
    );
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }
}
