import 'package:flutter/material.dart';
import 'admin.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String loginMessage = '';

  void _logginIn() {
    String username = usernameController.text;
    String password = passwordController.text;
    //check username and password
    if (password == "Abc1234" && username == "Administrator") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Admin()),
      );
    } else {
      setState(() {
        loginMessage = "Wrong Password or Username";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 14, 5, 56),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              child: Image.asset('asset/image/umslogo.png'),
            ),
            //admin id input
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Admin ID",
                labelStyle:
                    TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // Underline color when not focused
                ),
              ),
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            //password input
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                labelStyle:
                    TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // Underline color when not focused
                ),
              ),
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            const SizedBox(height: 20),
            //sign in button
            ElevatedButton(
              onPressed: () {
                _logginIn();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 143, 218, 253),
                ),
              ),
              //child: const Text("Login"),
              //lets update mayas detail to test
              child: const Text("Login"),
            ),
            const SizedBox(height: 20),
            Text(
              loginMessage,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ],
        ),
      ),
    );
  }
}
