import 'dart:convert';

import 'package:discovery_door/aux/colors.dart';
import 'package:discovery_door/aux/methods.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _textControllerUsername = TextEditingController();
  final TextEditingController _textControllerPassword1 =
      TextEditingController();
  final TextEditingController _textControllerPassword2 =
      TextEditingController();
  bool _showUsernameError = false;
  bool _showPasswordError = false;
  bool _showRegisterDone = false;
  bool _password1Invisible = true;
  bool _password2Invisible = true;
  String _password1 = '';
  String _password2 = '';

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.only(
        top: 90 * unitHeightValue(context),
        bottom: FocusScope.of(context).hasFocus
            ? 50 * unitHeightValue(context)
            : 100 * unitHeightValue(context),
      ),
      child: Image.asset(
        "assets/appimages/Museum.png",
        height: 95 * unitHeightValue(context),
      ),
    );
  }

  Widget _buildUsernameError() {
    return Text(
      "Username is taken",
      style: TextStyle(
        color: _showUsernameError ? Colors.red : Colors.transparent,
        fontSize: 15 * unitHeightValue(context),
      ),
    );
  }

  Widget _buildUsernameBox() {
    return Container(
      height: 50 * unitHeightValue(context),
      width: 215 * unitWidthValue(context),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: kLetter,
          ),
        ),
      ),
      child: TextField(
        maxLines: 1,
        controller: _textControllerUsername,
        style: TextStyle(
          color: kLetter,
          fontSize: 18.5 * unitHeightValue(context),
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.person,
            color: kLetter,
            size: 24 * unitWidthValue(context),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.only(left: 15 * unitWidthValue(context)),
          hintText: 'Username',
          hintStyle: TextStyle(
            fontSize: 22 * unitWidthValue(context),
            color: kLetter,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordError() {
    return SizedBox(
      height: 25 * unitHeightValue(context),
      child: Center(
        child: Text(
          "Passwords don't match",
          style: TextStyle(
            color: _showPasswordError ? Colors.red : Colors.transparent,
            fontSize: 15 * unitHeightValue(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPassword1Box() {
    return Padding(
      padding: EdgeInsets.only(bottom: 25 * unitHeightValue(context)),
      child: Container(
        height: 50 * unitHeightValue(context),
        width: 215 * unitWidthValue(context),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: kLetter,
            ),
          ),
        ),
        child: TextField(
          maxLines: 1,
          obscureText: _password1Invisible,
          controller: _textControllerPassword1,
          style: TextStyle(
            color: kLetter,
            fontSize: 18.5 * unitHeightValue(context),
          ),
          textAlignVertical: TextAlignVertical.center,
          onChanged: (text) {
            setState(() {
              _password1 = text;
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: kLetter,
              size: 24 * unitWidthValue(context),
            ),
            suffixIcon: _visibilityIcon1(),
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.only(left: 15 * unitWidthValue(context)),
            hintText: 'Password',
            hintStyle: TextStyle(
              fontSize: 22 * unitWidthValue(context),
              color: kLetter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassword2Box() {
    return Container(
      height: 50 * unitHeightValue(context),
      width: 215 * unitWidthValue(context),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: kLetter,
          ),
        ),
      ),
      child: TextField(
        maxLines: 1,
        obscureText: _password2Invisible,
        controller: _textControllerPassword2,
        style: TextStyle(
          color: kLetter,
          fontSize: 18.5 * unitHeightValue(context),
        ),
        textAlignVertical: TextAlignVertical.center,
        onChanged: (text) {
          setState(() {
            _password2 = text;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: kLetter,
            size: 24 * unitWidthValue(context),
          ),
          suffixIcon: _visibilityIcon2(),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.only(left: 15 * unitWidthValue(context)),
          hintText: 'Password',
          hintStyle: TextStyle(
            fontSize: 22 * unitWidthValue(context),
            color: kLetter,
          ),
        ),
      ),
    );
  }

  Widget? _visibilityIcon1() {
    if (_password1.isNotEmpty) {
      return IconButton(
        icon: Icon(
          Icons.visibility,
          color: kLetter,
        ),
        onPressed: () {
          setState(() {
            _password1Invisible = !_password1Invisible;
          });
        },
      );
    } else {
      return null;
    }
  }

  Widget? _visibilityIcon2() {
    if (_password2.isNotEmpty) {
      return IconButton(
        icon: Icon(
          Icons.visibility,
          color: kLetter,
          size: 24 * unitWidthValue(context),
        ),
        onPressed: () {
          setState(() {
            _password2Invisible = !_password2Invisible;
          });
        },
      );
    } else {
      return null;
    }
  }

  Future<bool> _runRegister() async {
    String username = _textControllerUsername.text;
    String password = _textControllerPassword1.text;

    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/register?uName=$username&pw=$password'));

    if (response.statusCode == 200) {
      bool didLog = jsonDecode(response.body);

      if (didLog == false) {
        return false;
      }
      return true;
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  Future<bool> _runValidateUsername() async {
    String username = _textControllerUsername.text;

    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/validateUsername?uName=$username'));

    if (response.statusCode == 200) {
      bool didLog = jsonDecode(response.body);

      if (didLog == false) {
        return false;
      }
      return true;
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  Widget _buildRegisterButton() {
    return Padding(
      padding: EdgeInsets.only(top: 100 * unitHeightValue(context)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45),
            side: BorderSide(
              color: kLetter,
              width: 1.25 * unitWidthValue(context),
            ),
          ),
          elevation: 0,
        ),
        onPressed: () {
          final usernameFree = _runValidateUsername();

          usernameFree.then((value) {
            if (value) {
              final password1 = _textControllerPassword1.text;
              final password2 = _textControllerPassword2.text;

              if (password2 == password1) {
                final registerDone = _runRegister();
                registerDone.then((value) {
                  setState(() {
                    _showRegisterDone = true;
                    _showUsernameError = false;
                    _showPasswordError = false;
                  });
                });
              } else {
                setState(() {
                  _showPasswordError = true;
                  _showUsernameError = false;
                  _showRegisterDone = false;
                });
              }
            } else {
              setState(() {
                _showUsernameError = true;
                _showRegisterDone = false;
              });
            }
            setState(() {
              _textControllerPassword1.clear();
              _textControllerPassword2.clear();
              _textControllerUsername.clear();
              _password1 = '';
              _password2 = '';
            });
          });
        },
        child: Container(
          width: 200 * unitWidthValue(context),
          height: 50 * unitHeightValue(context),
          alignment: Alignment.center,
          child: Text(
            'REGISTER',
            style: TextStyle(
              fontSize: 21 * unitWidthValue(context),
              color: kLetter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterDone() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Sign in completed!",
        style: TextStyle(
          color: _showRegisterDone ? Colors.black : Colors.transparent,
          fontSize: 16 * unitHeightValue(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth(context),
      height: screenHeight(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kScreenDark,
            kScreenLight,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SizedBox(
            width: screenWidth(context),
            height: screenHeight(context),
            child: Column(
              children: [
                _buildLogo(),
                _buildUsernameError(),
                _buildUsernameBox(),
                _buildPasswordError(),
                _buildPassword1Box(),
                _buildPassword2Box(),
                _buildRegisterButton(),
                _buildRegisterDone(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
