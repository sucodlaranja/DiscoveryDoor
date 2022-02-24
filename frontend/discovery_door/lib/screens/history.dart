import 'package:discovery_door/aux/methods.dart';
import 'package:discovery_door/data/museum.dart';
import 'package:discovery_door/data/regist.dart';

import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final List<Regist> history;
  const HistoryScreen({Key? key, required this.history}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<Regist> _history;

  @override
  void initState() {
    super.initState();
    _history = widget.history;
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

  Widget _buildRegist(Regist regist) {
    final museum = regist.museum;
    return Container(
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
                    Padding(
                      padding:
                          EdgeInsets.only(left: 10 * unitWidthValue(context)),
                      child: SizedBox(
                        width: 80 * unitWidthValue(context),
                        child: _buildMuseumCategory(museum),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 7 * unitHeightValue(context),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timelapse,
                      color: Colors.black,
                      size: 20 * unitHeightValue(context),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 10 * unitWidthValue(context)),
                      child: Text(
                        regist.tempoDeViagem.toString() + ' m',
                        style: TextStyle(
                          fontSize: 17.5 * unitHeightValue(context),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 7 * unitHeightValue(context)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                        size: 20 * unitHeightValue(context),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10 * unitWidthValue(context)),
                        child: Text(
                          regist.date,
                          style: TextStyle(
                            fontSize: 17.5 * unitHeightValue(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    if (_history.isEmpty) {
      return Container(
        alignment: Alignment.center,
        width: screenWidth(context),
        child: Text(
          'History is empty.',
          style: TextStyle(
            fontSize: 25 * unitWidthValue(context),
          ),
        ),
      );
    }

    List<Widget> widgetList = _history
        .map(
          (e) => Column(
            children: [
              _buildRegist(e),
              SizedBox(
                height: 10 * unitHeightValue(context),
              ),
            ],
          ),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        top: 30 * unitHeightValue(context),
        left: 10 * unitWidthValue(context),
        right: 10 * unitWidthValue(context),
      ),
      child: ListView(
        padding: const EdgeInsets.only(top: 5),
        children: widgetList,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
      ),
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
          'History',
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
          child: _buildDataList(),
        ),
      ),
    );
  }
}
