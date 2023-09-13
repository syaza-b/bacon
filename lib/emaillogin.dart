import 'package:bacon/adminlogin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'main.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});
  @override
  State<StatefulWidget> createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> with WidgetsBindingObserver {
  //declare global variables
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String loginMessage = '';
  Object? studentname, studentmatrix, studentpic = '';
  var tapNumber = 0;

  //referencing path of firebase realtime database at student profile nodes
  final DatabaseReference database =
      FirebaseDatabase.instance.ref().child('/student_profile');

  // For logging in, student id and password is compared with inside database
  // ignore: non_constant_identifier_names
  Future<void> _LogginIn() async {
    String username = usernameController.text;
    String password = passwordController.text;
    DatabaseEvent userwhere = await database.child(username).once();
    studentmatrix = userwhere.snapshot.key;
    if (studentmatrix != null) {
      DatabaseEvent event = await database.child(username).once();
      Object? pass = event.snapshot.child('pwd').value;
      if (kDebugMode) {
        print(pass);
      }
      //success login
      if (password == pass) {
        studentname = event.snapshot.child('name').value;
        studentpic = event.snapshot.child('pic').value;

        _changePage(studentname.toString(), studentmatrix.toString(),
            studentpic.toString());
      } else {
        setState(() {
          loginMessage = "Wrong Password or Username";
        });
      }
    }
  }

  //if student id and password match, open app home page
  void _changePage(
      String studentname, String studentmatrix, String studentpic) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => Bacon(
                sname: studentname,
                smatrix: studentmatrix,
                spic: studentpic,
              )),
    );
  }

  //check if clicks is enough to
  void _adminOpen() {
    if (tapNumber == 5) {
      tapNumber = 0;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AdminLogin()));
    }
  }

  //build login interface
  @override
  Widget build(BuildContext context) {
    //referring to branch child in json

    return Material(
      color: const Color.fromARGB(255, 0, 0, 0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //admin mode if click logo 5 times
            GestureDetector(
                child: CircleAvatar(
                  radius: 50,
                  child: Image.asset('asset/image/umslogo.png'),
                ),
                onTap: () {
                  tapNumber++;
                  _adminOpen();
                }),
            //student id input
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Student ID",
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
                _LogginIn();
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
