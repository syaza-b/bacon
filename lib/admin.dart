import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'emaillogin.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  String eventname = "",
      eventdesc = "",
      eventpic = "",
      eventdate = "",
      eventtime = "",
      eventstatus = "",
      eventtype = "",
      eventid = "",
      place = "";
  final DatabaseReference database =
      FirebaseDatabase.instance.ref().child('/event');
  Query dbRef = FirebaseDatabase.instance.ref().child('/event');
  showEvent() {
    database.onValue.listen(
      (event) async {
        for (final child in event.snapshot.children) {
          eventid = child.key.toString();
          print(eventid);
          DataCell(Text(eventid));
          for (var child2 in child.children) {
            if (child2.key.toString() == 'name') {
              eventname = child2.value.toString();
              print(eventname);
            }
            if (child2.key.toString() == 'pic') {
              eventpic = child2.value.toString();
            }
            if (child2.key.toString() == 'date') {
              eventdate = child2.value.toString();
            }
            if (child2.key.toString() == 'time') {
              eventtime = child2.value.toString();
            }
            if (child2.key.toString() == 'status') {
              eventstatus = child2.value.toString();
            }
            if (child2.key.toString() == 'type') {
              eventtype = child2.value.toString();
            }
            if (child2.key.toString() == 'place') {
              place = child2.value.toString();
              final DatabaseReference placecheck =
                  FirebaseDatabase.instance.ref().child('/beacon/$place');
              DatabaseEvent placewhere =
                  await placecheck.child('/beaconname').once();
              place = placewhere.snapshot.value.toString();
              print(place);
            }
          }
        }
      },
    );
  }

  Widget listItem() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 200,
      color: Colors.lightBlueAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            '/asset/img/default_avatar.jpeg',
            height: 50,
          ),
          const Text('ID',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300)),
          const Text('Name',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300)),
          const Text('Type',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300)),
          const Text('Description',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300)),
          const Text('Date',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300)),
          const Text('Time',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300)),
          const Text('Place',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300)),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.visibility_off)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.delete_forever)),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 91, 164, 198),
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'UMSKAL Beacons [Admin]',
                  style: TextStyle(fontSize: 20),
                ),
                backgroundColor: const Color.fromARGB(255, 152, 186, 202),
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
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Title(
                      color: const Color.fromARGB(255, 30, 57, 105),
                      child: const Text(
                        "Events",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  listItem(),
                ],
              ));
        },
      ),
    );
  }
}
