import 'package:flutter/material.dart';

double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double unitHeightValue(BuildContext context) {
  return MediaQuery.of(context).size.height / 851;
}

double unitWidthValue(BuildContext context) {
  return MediaQuery.of(context).size.width / 393;
}
