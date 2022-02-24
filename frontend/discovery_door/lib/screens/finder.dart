import 'dart:convert';

import 'package:discovery_door/data/directions.dart';
import 'package:discovery_door/data/directions_repository.dart';
import 'package:discovery_door/data/museum.dart';
import 'package:discovery_door/aux/methods.dart';
import 'package:discovery_door/screens/main_menu.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class FinderScreen extends StatefulWidget {
  final String username;
  final List<String> categories;

  const FinderScreen(
      {Key? key, required this.username, required this.categories})
      : super(key: key);

  @override
  _FinderScreenState createState() => _FinderScreenState();
}

class _FinderScreenState extends State<FinderScreen> {
  bool _isLoading = true;
  int _price = 0;
  int _distance = 0;
  int _stars = 5;

  final _prices = [1, 5, 10, 15, 20, 30, 50, 100];
  final _distances = [0.5, 1, 2.5, 5, 7.5, 10, 15, 20];

  late List<String> categories;
  int _categorySelected = 0;

  late List<Museum> _museums;
  late List<Directions?> _directions;

  @override
  void initState() {
    super.initState();

    categories = widget.categories;
    categories.insert(0, 'All');
    WidgetsBinding.instance!.addPostFrameCallback((_) => _loadMuseums());
  }

  Future<List<Museum>> _getMuseumsByFilter() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final lat = position.latitude;
    final lng = position.longitude;

    final category =
        _categorySelected == 0 ? 'all' : categories[_categorySelected];

    final price = _prices[_price];
    final distance = _distances[_distance];

    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/getMuseumByFilters?radius=$distance&lat=$lat&lon=$lng&price=$price&score=$_stars&theme=$category'));

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      return json.map<Museum>((json) => Museum.fromJson(json)).toList();
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  void _loadDirections() async {
    for (var m in _museums) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final directions = await DirectionsRepository().getDirections(
        origin: LatLng(position.latitude, position.longitude),
        destination: LatLng(m.lat, m.lng),
        transport: 2,
      );
      _directions.add(directions);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _loadMuseums() {
    setState(() {
      _isLoading = true;
    });
    final museums = _getMuseumsByFilter();

    museums.then((value) {
      _museums = value;
      _directions = [];
      _loadDirections();
    });
  }

  Widget _buildSliderRow(bool isDistance) {
    final val =
        isDistance ? _distances[_distance.toInt()] : _prices[_price.toInt()];
    final type = isDistance ? ' Km' : ' €';
    return Row(
      children: [
        Container(
          width: 90 * unitWidthValue(context),
          alignment: Alignment.center,
          child: Text(
            val.toString() + type,
            style: TextStyle(
              fontSize: 20 * unitWidthValue(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: isDistance ? _distance.toDouble() : _price.toDouble(),
            onChanged: (value) {
              setState(() {
                isDistance ? _distance = value.toInt() : _price = value.toInt();
              });
            },
            divisions: isDistance ? _distances.length - 1 : _prices.length - 1,
            max: isDistance ? _distances.length - 1 : _prices.length - 1,
            activeColor: Colors.blue.shade800,
            onChangeEnd: (value) {
              _loadMuseums();
            },
          ),
        ),
      ],
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

  Widget _buildStarWithBorder(int number, double size1, double size2) {
    final insideColor = number <= _stars ? Colors.yellow.shade600 : Colors.grey;
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
    return InkWell(
      onTap: () {
        setState(() {
          _stars = number;
        });
        _loadMuseums();
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

  Widget _buildCategoryButton(int index) {
    final color =
        _categorySelected == index ? Colors.blue.shade800 : Colors.transparent;
    final colorL =
        _categorySelected == index ? Colors.white : Colors.blue.shade800;
    final category = categories[index];

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(45),
          side: BorderSide(
            color: Colors.blue.shade800,
            width: 1.25 * unitWidthValue(context),
          ),
        ),
        elevation: 0,
      ),
      onPressed: () {
        setState(() {
          _categorySelected = index;
        });
        _loadMuseums();
      },
      child: Container(
        width: 15 * category.length * unitWidthValue(context),
        height: 40 * unitHeightValue(context),
        alignment: Alignment.center,
        child: Text(
          category,
          style: TextStyle(
            fontSize: 22 * unitWidthValue(context),
            color: colorL,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return SizedBox(
      width: screenWidth(context),
      height: 60 * unitHeightValue(context),
      child: ListView.builder(
        itemBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: 5 * unitWidthValue(context),
              right: 5 * unitWidthValue(context),
              top: 5 * unitHeightValue(context),
              bottom: 5 * unitHeightValue(context),
            ),
            child: _buildCategoryButton(index),
          );
        },
        itemCount: categories.length,
        shrinkWrap: true,
        padding: EdgeInsets.all(5),
        scrollDirection: Axis.horizontal,
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
      width: 50 * unitWidthValue(context),
      height: 25 * unitHeightValue(context),
      alignment: Alignment.center,
      child: Text(
        price,
        style: TextStyle(
          fontSize: 15 * unitWidthValue(context),
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
      width: 9 * museum.category.length * unitWidthValue(context),
      height: 25 * unitHeightValue(context),
      alignment: Alignment.center,
      child: Text(
        museum.category,
        style: TextStyle(
          fontSize: 15 * unitWidthValue(context),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMuseumInfo(Museum museum) {
    final index = _museums.indexOf(museum);
    final duration =
        _directions[index] == null ? 'und' : _directions[index]!.totalDuration;
    final distance =
        _directions[index] == null ? 'und' : _directions[index]!.totalDistance;

    return InkWell(
      onTap: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenuScreen(
            username: widget.username,
            showMuseum: true,
            museum: museum,
          ),
        ),
        (route) => false,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        padding: EdgeInsets.all(5 * unitHeightValue(context)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                museum.photos[0],
                height: 125 * unitHeightValue(context),
                width: 125 * unitWidthValue(context),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10 * unitWidthValue(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 215 * unitWidthValue(context),
                    child: Text(
                      museum.name,
                      style: TextStyle(
                        fontSize: 20 * unitWidthValue(context),
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  Row(
                    children: [
                      _buildMuseumStars(0, museum.evaluation),
                      _buildMuseumStars(1, museum.evaluation),
                      _buildMuseumStars(2, museum.evaluation),
                      _buildMuseumStars(3, museum.evaluation),
                      _buildMuseumStars(4, museum.evaluation),
                    ],
                  ),
                  _buildMuseumCategory(museum),
                  SizedBox(
                    height: 7 * unitHeightValue(context),
                  ),
                  Row(
                    children: [
                      _buildMuseumPrice(museum),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 15 * unitWidthValue(context),
                          right: 5 * unitWidthValue(context),
                        ),
                        child: Icon(
                          Icons.directions_walk,
                          size: 20 * unitWidthValue(context),
                        ),
                      ),
                      Text(
                        duration! + '  -  ' + distance!,
                        style: TextStyle(
                          fontSize: 15 * unitWidthValue(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuseumList() {
    if (_isLoading) {
      return Expanded(
        child: SpinKitFadingCube(
          size: 30 * unitWidthValue(context),
          color: Colors.blue.shade800,
        ),
      );
    }

    if (_museums.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No museums for the given filters.',
            style: TextStyle(
              fontSize: 20 * unitWidthValue(context),
            ),
          ),
        ),
      );
    }

    List<Widget> widgetList = _museums
        .map(
          (e) => Column(
            children: [
              _buildMuseumInfo(e),
              SizedBox(
                height: 10 * unitHeightValue(context),
              ),
            ],
          ),
        )
        .toList();

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          left: 10 * unitWidthValue(context),
          right: 10 * unitWidthValue(context),
        ),
        child: ListView(
          padding: const EdgeInsets.only(top: 5),
          children: widgetList,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.black.withOpacity(0.15),
      thickness: 2.5 * unitHeightValue(context),
      indent: 15 * unitWidthValue(context),
      endIndent: 15 * unitWidthValue(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        title: Text(
          'Finder',
          style: TextStyle(
            fontSize: 27.5 * unitHeightValue(context),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 60 * unitHeightValue(context),
      ),
      body: Container(
        color: Colors.blue.shade800,
        height: screenHeight(context),
        padding: EdgeInsets.only(top: 95 * unitHeightValue(context)),
        child: Container(
          width: screenWidth(context),
          height: screenHeight(context),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 10 * unitHeightValue(context),
              ),
              _buildSliderRow(true),
              _buildSliderRow(false),
              _buildDivider(),
              _buildStarsRow(),
              _buildDivider(),
              _buildCategoriesList(),
              _buildDivider(),
              _buildMuseumList(),
            ],
          ),
        ),
      ),
    );
  }
}
