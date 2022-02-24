import 'dart:convert';

import 'package:discovery_door_admin/aux/colors.dart';
import 'package:discovery_door_admin/aux/methods.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Widget _buildPageTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20),
      child: Row(
        children: [
          Image.asset(
            'assets/appimages/Museum.png',
            height: 40,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            'DISCOVERYDOOR',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w700,
              color: kLetter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 175),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        child: Image.network(
          'https://i0.wp.com/mundoviajar.com.br/wp-content/uploads/2018/07/Braga-Portugal-4-scaled.jpg?resize=1300%2C867&ssl=1',
          height: 300 * unitHeightValue(context),
          width: 400 * unitWidthValue(context),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUsernameBox() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
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
        height: 50,
        width: 225,
        child: TextField(
          controller: _textControllerUsername,
          style: TextStyle(
            color: kLetter,
            fontSize: 22,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.person,
              color: kLetter,
              size: 25,
            ),
            hintText: 'Username',
            hintStyle: TextStyle(
              color: kLetter.withOpacity(0.5),
              fontSize: 25,
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
          size: 25,
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
      height: 50,
      width: 225,
      child: TextField(
        controller: _textControllerPassword,
        obscureText: _passwordInvisible,
        style: TextStyle(
          color: kLetter,
          fontSize: 22,
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
              size: 25,
            ),
            hintText: 'Password',
            hintStyle: TextStyle(
              color: kLetter.withOpacity(0.5),
              fontSize: 25,
            ),
            suffixIcon: _visibilityIcon()),
      ),
    );
  }

  Future<bool> _tryLogin() async {
    final username = _textControllerUsername.text;

    final response = await http.get(Uri.parse(
        'https://backenddiscoverdoor.azurewebsites.net/loginAdmin?aName=$username&pw=$_password'));

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      return json;
    } else {
      throw Exception('Failed to connect to backend');
    }
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 250),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45),
            side: BorderSide(
              color: kLetter,
              width: 1.25,
            ),
          ),
          elevation: 0,
        ),
        onPressed: () {
          final didLog = _tryLogin();

          didLog.then((value) {
            if (value) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/museumsMenu',
                (route) => false,
              );
            } else {
              setState(() {
                _showError = true;
                _password = '';
                _textControllerPassword.clear();
                _textControllerUsername.clear();
              });
            }
          });
          // Navigator.pushNamedAndRemoveUntil(
          //   context,
          //   '/museumsMenu',
          //   (route) => false,
          // );
        },
        child: Container(
          width: 230,
          height: 50,
          alignment: Alignment.center,
          child: Text(
            'LOGIN',
            style: TextStyle(
              fontSize: 25,
              color: kLetter,
            ),
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
        fontSize: 12,
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
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageTitle(),
                  Row(
                    children: [
                      _buildImage(),
                      Padding(
                        padding: const EdgeInsets.only(left: 350),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 200,
                            ),
                            _buildErrorNotification(),
                            _buildUsernameBox(),
                            _buildPasswordBox(),
                            _buildLoginButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
