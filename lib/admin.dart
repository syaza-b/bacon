import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'emaillogin.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final DatabaseReference database =
      FirebaseDatabase.instance.ref().child('/event');
  final eventquery =
      FirebaseDatabase.instance.ref().child('/event').orderByKey();
  String id = '',
      name = '',
      desc = '',
      place = '',
      time = '',
      date = '',
      type = '',
      status = '',
      pic = '';
  TextEditingController namec = TextEditingController();
  TextEditingController datec = TextEditingController();
  TextEditingController timec = TextEditingController();
  TextEditingController typec = TextEditingController();
  TextEditingController statusc = TextEditingController();
  TextEditingController idc = TextEditingController();

  showMore() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Column(
            children: [
              Text(
                'Add new event or Edit Event',
                textAlign: TextAlign.center,
              ),
              Text(
                'To edit event, type same Event ID',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                    fontSize: 15),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: idc,
                  decoration: const InputDecoration(
                    labelText: "Event ID",
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0,
                              0)), // Underline color when not focused
                    ),
                  ),
                ),
                TextField(
                  controller: namec,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0,
                              0)), // Underline color when not focused
                    ),
                  ),
                ),
                TextField(
                  controller: datec,
                  decoration: const InputDecoration(
                    labelText: "Date",
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0,
                              0)), // Underline color when not focused
                    ),
                  ),
                ),
                TextField(
                  controller: timec,
                  decoration: const InputDecoration(
                    labelText: "Time",
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0,
                              0)), // Underline color when not focused
                    ),
                  ),
                ),
                TextField(
                  controller: typec,
                  decoration: const InputDecoration(
                    labelText: "Type",
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0,
                              0)), // Underline color when not focused
                    ),
                  ),
                ),
                TextField(
                  controller: statusc,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0,
                              0)), // Underline color when not focused
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      update(idc, namec, datec, timec, statusc, typec);
                    },
                    child: Icon(Icons.add))
              ],
            ),
          ),
        );
      },
    );
  }

  update(idc, namec, datec, timec, statusc, typec) async {
    // Call the set() method to add the new data to the database.
    final String id = idc.text;
    final String name = namec.text;
    final String date = datec.text;
    final String time = timec.text;
    final String status = statusc.text;
    final String type = typec.text;

    final Map<String, dynamic> newEventData = {
      'name': name,
      'date': date,
      'time': time,
      'status': status,
      'type': type,
    };

    database.child(id).set(newEventData);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 43, 128, 168),
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'UMSKAL Beacons [Admin]',
                style: TextStyle(fontSize: 18),
              ),
              backgroundColor: const Color.fromARGB(255, 43, 128, 168),
              leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.admin_panel_settings)),
              actions: [
                //logout
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EmailLogin()));
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: FirebaseDatabaseDataTable(
                query: database,
                columnLabels: {
                  'name': Text('Name'),
                  'date': Text('Date'),
                  'time': Text('Time'),
                  'type': Text('Type'),
                  'status': Text('Status'),
                },
                rowsPerPage: 6,
                showCheckboxColumn: false,
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showMore();
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
