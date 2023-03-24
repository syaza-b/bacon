import 'package:bacon/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  void _showButtonPressDialog(BuildContext context, String provider) {
    //shud put some condition if signed in then open app
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Bacon()),
    );
    if (kDebugMode) {
      print("What is click $provider");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SignInButtonBuilder(
              text: 'Get going with Email',
              icon: Icons.email,
              onPressed: () {
                _showButtonPressDialog(context, 'Email');
              },
              backgroundColor: Colors.blueGrey[700]!,
              width: 220.0,
            ),
            Divider(),
            SignInButton(
              Buttons.Google,
              onPressed: () {
                _showButtonPressDialog(context, 'Google');
              },
            ),
            Divider(),
            SignInButton(
              Buttons.FacebookNew,
              onPressed: () {
                _showButtonPressDialog(context, 'FacebookNew');
              },
            ),
          ]),
    );
  }
}
