import 'package:flutter/material.dart';

double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double unitHeightValue(BuildContext context) {
  if (MediaQuery.of(context).size.height > MediaQuery.of(context).size.width) {
    return MediaQuery.of(context).size.height / 851;
  } else {
    return MediaQuery.of(context).size.height / 500;
  }
}

double unitWidthValue(BuildContext context) {
  if (MediaQuery.of(context).size.height > MediaQuery.of(context).size.width) {
    return MediaQuery.of(context).size.width / 393;
  } else {
    return MediaQuery.of(context).size.width / 1000;
  }
}
