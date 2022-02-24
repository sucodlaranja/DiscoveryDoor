import 'dart:convert';

import 'package:discovery_door_admin/aux/colors.dart';
import 'package:discovery_door_admin/aux/methods.dart';
import 'package:discovery_door_admin/data/museum.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _showMoreMuseum = false;
  bool _isEditing = false;
  bool _isLoading = false;
  String _oldName = '';

  final _textControllerName = TextEditingController();
  final _textControllerPrice = TextEditingController();
  final _textControllerLocation = TextEditingController();
  final _textControllerLatitude = TextEditingController();
  final _textControllerLongitude = TextEditingController();
  final _textControllerWebsite = TextEditingController();
  final _textControllerContact = TextEditingController();
  final _textControllerCategory = TextEditingController();
  late List<TextEditingController> _photoTextControllers;

  List<Museum> _museums = [];

  @override
  void initState() {
    super.initState();

    _photoTextControllers = [];
    for (var i = 0; i < 5; i++) {
      _photoTextControllers.add(TextEditingController());
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) => _loadMuseums());
  }

  Future<List<Museum>> _getMuseums() async {
    final response = await http.get(
        Uri.parse('https://backenddiscoverdoor.azurewebsites.net/allMuseums'));

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      return json.map<Museum>((json) => Museum.fromJson(json)).toList();
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  void _loadMuseums() {
    final museums = _getMuseums();

    museums.then((value) {
      _museums = value;
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Image.asset(
          'assets/appimages/Museum.png',
          height: 35,
          fit: BoxFit.cover,
        ),
        const SizedBox(
          width: 15,
        ),
        Text(
          'DISCOVERYDOOR',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kLetter,
          ),
        ),
      ],
    );
  }

  Widget _buildAddMuseumButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _showMoreMuseum = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 5,
          bottom: 5,
        ),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(30))),
        child: Row(
          children: [
            Icon(
              Icons.add,
              color: Colors.blue.shade800,
              size: 22,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                'ADD MUSEUM',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTitle() {
    return Container(
      padding: const EdgeInsets.only(
        left: 225,
        right: 225,
      ),
      width: screenWidth(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'MUSEUMS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          _buildAddMuseumButton(),
        ],
      ),
    );
  }

  Widget _buildStarIcon(double limit, double size, Color color) {
    return Container(
      height: limit,
      width: limit,
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
          22,
          18,
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
            22,
            13,
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
      width: 50,
      height: 25,
      alignment: Alignment.center,
      child: Text(
        price,
        style: const TextStyle(
          fontSize: 15,
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
      width: 9 * museum.category.length.toDouble(),
      height: 25,
      alignment: Alignment.center,
      child: Text(
        museum.category,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDataLine(IconData icon, Color color, String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 30,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            name,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosList(List<String> photos) {
    List<Widget> widgetList = photos
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                e,
                height: 130,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
        .toList();

    if (widgetList.isNotEmpty) {
      widgetList.removeAt(0);
    }

    return SizedBox(
      width: 300,
      child: ListView(
        padding: const EdgeInsets.only(top: 5),
        children: widgetList,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Future<bool> _removeMuseumByName(String nome) async {
    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/removeMuseum?mName=$nome'));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  void _removeMuseum(String nome) {
    setState(() {
      _isLoading = true;
    });
    final remove = _removeMuseumByName(nome);

    remove.then((value) {
      _loadMuseums();
    });
  }

  Widget _buildMuseumBox(Museum museum) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 150,
        right: 150,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            height: 150,
            width: screenWidth(context),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    museum.photos.isNotEmpty ? museum.photos[0] : '',
                    height: 130,
                    width: 130,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 40,
                    right: 40,
                    top: 10,
                    bottom: 10,
                  ),
                  child: SizedBox(
                    width: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          museum.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                          ),
                          child: _buildMuseumCategory(museum),
                        ),
                        _buildMuseumPrice(museum),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 450,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDataLine(
                          Icons.room, Colors.red.shade900, museum.address),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: _buildDataLine(
                            Icons.web, Colors.blue.shade700, museum.website),
                      ),
                      _buildDataLine(
                          Icons.phone, Colors.yellow.shade800, museum.contact),
                    ],
                  ),
                ),
                _buildPhotosList(museum.photos),
                const SizedBox(
                  width: 25,
                ),
                Container(
                  alignment: Alignment.center,
                  width: 100,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                        _showMoreMuseum = true;
                        _oldName = museum.name;
                        _textControllerName.text = museum.name;
                        _textControllerPrice.text = museum.price.toString();
                        _textControllerLocation.text = museum.address;
                        _textControllerLatitude.text = museum.lat.toString();
                        _textControllerLongitude.text = museum.lng.toString();
                        _textControllerWebsite.text = museum.website;
                        _textControllerContact.text = museum.contact;
                        _textControllerCategory.text = museum.category;

                        for (var i = 0; i < museum.photos.length; i++) {
                          _photoTextControllers[i].text = museum.photos[i];
                        }
                      });
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blue.shade900,
                      size: 30,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: 100,
                  child: IconButton(
                    onPressed: () => _removeMuseum(museum.name),
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade900,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 10,
            thickness: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildMuseumsList() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 150),
        child: SpinKitFadingCube(
          color: kScreenDark,
          size: 30,
        ),
      );
    }

    // Museum m = Museum(
    //   name: 'name',
    //   website: 'website',
    //   price: 1,
    //   contact: 'contact',
    //   address: 'address',
    //   photos: [
    //     'https://1.bp.blogspot.com/-1xh_q31AheY/UQWK7qxhEOI/AAAAAAAABuc/WlRd8yRIgSI/s1600/Museu+do+Ipiranga+-+Leitura+das+Lentes+(2).jpg',
    //   ],
    //   category: 'category',
    //   lat: 1,
    //   lng: 1,
    //   evaluation: 2,
    // );

    List<Widget> widgetList = _museums.map((e) => _buildMuseumBox(e)).toList();

    // widgetList.add(_buildMuseumBox(m));

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.only(top: 5),
        children: widgetList,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
      ),
    );
  }

  Widget _buildTextLine(
      String name, TextEditingController controller, bool fullLine) {
    final width = fullLine ? 1150 : 500;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: width.toDouble(),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black.withOpacity(0.8),
              width: 1.5,
            ),
          ),
        ),
        child: TextField(
          maxLines: 1,
          controller: controller,
          style: TextStyle(
            color: Colors.black.withOpacity(0.8),
            fontSize: 22,
          ),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.only(left: 15),
            hintText: name,
            hintStyle: TextStyle(
              fontSize: 25,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosURLList() {
    List<Widget> widgetList = [];

    for (var i = 0; i < _photoTextControllers.length; i++) {
      var j = i + 1;
      widgetList.add(_buildTextLine(
          'PHOTO' + j.toString(), _photoTextControllers[i], true));
    }

    return Container(
      padding: const EdgeInsets.only(
        left: 50,
        right: 50,
      ),
      height: 150,
      child: ListView(
        padding: const EdgeInsets.only(top: 5),
        children: widgetList,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
      ),
    );
  }

  Future<bool> _editOrAddMuseum() async {
    final name = _textControllerName.text;
    final price = _textControllerPrice.text;
    final location = _textControllerLocation.text;
    final lat = _textControllerLatitude.text;
    final lng = _textControllerLongitude.text;
    final website = _textControllerWebsite.text;
    final contact = _textControllerContact.text;
    final category = _textControllerCategory.text;

    String photos = '';
    int count = 0;

    for (var item in _photoTextControllers) {
      if (item.text.isNotEmpty) count++;
    }

    if (count > 1) {
      for (var item in _photoTextControllers) {
        if (item.text.isNotEmpty) {
          if (photos != '') {
            photos = photos + ',';
          }
          final photo = item.text;
          photos = photos + photo;
        }
      }
    } else if (count == 1) {
      for (var item in _photoTextControllers) {
        if (item.text.isNotEmpty) {
          photos = item.text;
          break;
        }
      }
    }

    final String type = _isEditing ? 'editMuseum' : 'newMuseum';
    final names =
        _isEditing ? 'oldName=$_oldName&newName=$name' : 'mName=$name';

    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/$type?$names&price=$price&location=$location&web=$website&contact=$contact&category=$category&lat=$lat&lon=$lng&pics=$photos'));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  Widget _buildAddMuseuPopUp() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.center,
        width: screenWidth(context),
        height: screenHeight(context),
        color: Colors.black.withOpacity(0.6),
        child: Container(
          width: 1250,
          height: 800,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 50),
                width: 1250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTextLine('NAME', _textControllerName, true),
                    _buildTextLine('PRICE', _textControllerPrice, true),
                    _buildTextLine('LOCATION', _textControllerLocation, true),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 50,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTextLine(
                              'LATITUDE', _textControllerLatitude, false),
                          _buildTextLine(
                              'LONGITUDE', _textControllerLongitude, false),
                        ],
                      ),
                    ),
                    _buildTextLine('WEBSITE', _textControllerWebsite, true),
                    _buildTextLine('CONTACT', _textControllerContact, true),
                    _buildTextLine('CATEGORY', _textControllerCategory, true),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Divider(
                        height: 0,
                        thickness: 0.5,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    _buildPhotosURLList(),
                    Divider(
                      height: 0,
                      thickness: 0.5,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 740,
                  left: 1000,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        _textControllerName.clear();
                        _textControllerPrice.clear();
                        _textControllerLocation.clear();
                        _textControllerLatitude.clear();
                        _textControllerLongitude.clear();
                        _textControllerWebsite.clear();
                        _textControllerContact.clear();
                        _textControllerCategory.clear();

                        for (var item in _photoTextControllers) {
                          item.clear();
                        }

                        _isEditing = false;
                        _showMoreMuseum = false;
                      }),
                      child: Container(
                        alignment: Alignment.center,
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.5)),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10 * unitWidthValue(context),
                    ),
                    InkWell(
                      onTap: () {
                        final editOrAdd = _editOrAddMuseum();

                        editOrAdd.then((value) {
                          setState(() {
                            _textControllerName.clear();
                            _textControllerPrice.clear();
                            _textControllerLocation.clear();
                            _textControllerLatitude.clear();
                            _textControllerLongitude.clear();
                            _textControllerWebsite.clear();
                            _textControllerContact.clear();
                            _textControllerCategory.clear();

                            for (var item in _photoTextControllers) {
                              item.clear();
                            }

                            _isEditing = false;
                            _showMoreMuseum = false;
                            _isLoading = true;
                            _loadMuseums();
                          });
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kScreenDark,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.5)),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: kScreenDark,
            title: _buildTitle(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  ),
                  icon: Icon(
                    Icons.logout,
                    color: kLetter,
                    size: 35,
                  ),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              _buildListTitle(),
              const Divider(
                height: 25,
                thickness: 2,
                indent: 100,
                endIndent: 100,
              ),
              _buildMuseumsList(),
            ],
          ),
        ),
        if (_showMoreMuseum) _buildAddMuseuPopUp(),
      ],
    );
  }
}
