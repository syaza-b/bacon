import 'package:bacon/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Divider(),
            SignInButton(
              Buttons.Google,
              onPressed: () {
                signInWithGoogle();
                FirebaseAuth.instance.userChanges().listen((User? user) {
                  if (user != null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Bacon()));
                  }
                });
              },
            ),
            const Divider(),
            SignInButton(Buttons.FacebookNew, onPressed: () {
              signInWithFacebook();
            }),
          ]),
    );
  }
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

signInWithFacebook() {
  const Dialog(
    child: Text('Not yet.'),
  );
}
