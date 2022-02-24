import 'dart:convert';

import 'package:discovery_door/aux/colors.dart';
import 'package:discovery_door/aux/methods.dart';
import 'package:discovery_door/screens/main_menu.dart';

import 'package:discovery_door/screens/app_start/register.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _textControllerUsername = TextEditingController();
  final _textControllerPassword = TextEditingController();

  bool _passwordInvisible = true;
  bool _showError = false;
  String _password = '';

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.only(
        top: 175 * unitHeightValue(context),
        bottom: 65 * unitHeightValue(context),
      ),
      child: Image.asset(
        "assets/appimages/Museum.png",
        height: 95 * unitHeightValue(context),
      ),
    );
  }

  Widget _buildUsernameBox() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20 * unitHeightValue(context),
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: kLetter,
            ),
          ),
        ),
        height: 60 * unitHeightValue(context),
        width: 215 * unitWidthValue(context),
        child: TextField(
          controller: _textControllerUsername,
          style: TextStyle(
            color: kLetter,
            fontSize: 17 * unitWidthValue(context),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.person,
              color: kLetter,
            ),
            hintText: 'Username',
            hintStyle: TextStyle(
              color: kLetter,
              fontSize: 21 * unitWidthValue(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _visibilityIcon() {
    if (_password.isNotEmpty) {
      return IconButton(
        icon: Icon(
          Icons.visibility,
          color: kLetter,
        ),
        onPressed: () {
          setState(() {
            _passwordInvisible = !_passwordInvisible;
          });
        },
      );
    } else {
      return null;
    }
  }

  Widget _buildPasswordBox() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
          width: 1,
          color: kLetter,
        )),
      ),
      height: 60 * unitHeightValue(context),
      width: 215 * unitWidthValue(context),
      child: TextField(
        controller: _textControllerPassword,
        obscureText: _passwordInvisible,
        style: TextStyle(
          color: kLetter,
          fontSize: 17 * unitWidthValue(context),
        ),
        onChanged: (text) {
          setState(() {
            _password = text;
          });
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.lock,
              color: kLetter,
            ),
            hintText: 'Password',
            hintStyle: TextStyle(
              color: kLetter,
              fontSize: 21 * unitWidthValue(context),
            ),
            suffixIcon: _visibilityIcon()),
      ),
    );
  }

  Future<bool> _runLogin() async {
    String username = _textControllerUsername.text;
    String password = _textControllerPassword.text;

    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/loginUser?uName=$username&pw=$password'));

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

  Widget _buildLoginButton() {
    return ElevatedButton(
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
        final loginDone = _runLogin();

        loginDone.then((value) {
          if (value) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainMenuScreen(
                  username: _textControllerUsername.text,
                  showMuseum: false,
                ),
              ),
              (route) => false,
            );
          } else {
            setState(() {
              _password = '';
              _textControllerPassword.clear();
              _textControllerUsername.clear();
              _showError = true;
            });
          }
        });
      },
      child: Container(
        width: 200 * unitWidthValue(context),
        height: 50 * unitHeightValue(context),
        alignment: Alignment.center,
        child: Text(
          'LOGIN',
          style: TextStyle(
            fontSize: 25 * unitWidthValue(context),
            color: kLetter,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
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
        setState(() {
          _password = '';
          _textControllerPassword.clear();
          _textControllerUsername.clear();
          _showError = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegisterScreen(),
          ),
        );
      },
      child: Container(
        width: 125 * unitWidthValue(context),
        height: 35 * unitHeightValue(context),
        alignment: Alignment.center,
        child: Text(
          'REGISTER',
          style: TextStyle(
            fontSize: 15 * unitWidthValue(context),
            color: kLetter,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorNotification() {
    return Text(
      'Invalid Username or Password',
      style: TextStyle(
        color: _showError ? Colors.red : Colors.transparent,
        fontSize: 15 * unitWidthValue(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
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
          child: Column(
            children: [
              _buildLogo(),
              _buildErrorNotification(),
              _buildUsernameBox(),
              _buildPasswordBox(),
              SizedBox(
                height: 100 * unitHeightValue(context),
              ),
              _buildLoginButton(),
              SizedBox(
                height: 30 * unitHeightValue(context),
              ),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}
