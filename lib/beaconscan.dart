import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class BeaconScan extends StatefulWidget {
  const BeaconScan(
      {Key? key,
      this.beaconuuid,
      this.smatrix,
      this.sname,
      this.spic,
      this.show,
      this.newId})
      : super(key: key);
  final String? beaconuuid;
  final String? smatrix, sname, spic;
  final String? show, newId;
  @override
  State<BeaconScan> createState() => _BeaconScanState();
}

String newPic = '';
String newEventName = '';
String newDesc = '';
String newTime = '';
String newDate = '';
String newShow = '';

class _BeaconScanState extends State<BeaconScan> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 143, 218, 253),
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Event Details'),
              backgroundColor: const Color.fromARGB(255, 143, 218, 253),
              leading: IconButton(
                icon: const Icon(Icons.home_rounded),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => Bacon(
                              sname: widget.sname,
                              smatrix: widget.smatrix,
                              spic: widget.spic,
                            )),
                  );
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Image.network(
                      newPic,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      newEventName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(newDesc),
                    const SizedBox(height: 5),
                    Text('Time: $newTime'),
                    const SizedBox(height: 5),
                    Text('Date: $newDate'),
                    if (newShow == 'Not Registered')
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 143, 218, 253),
                            ),
                            onPressed: () {
                              addevent(widget.newId);
                              initPlatformState();
                            },
                            child: const Text("Register",
                                style: TextStyle(fontSize: 20)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 143, 218, 253),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => Bacon(
                                          sname: widget.sname,
                                          smatrix: widget.smatrix,
                                          spic: widget.spic,
                                        )),
                              );
                            },
                            child: const Text("No Thanks",
                                style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    if (newShow == 'Registered')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 143, 218, 253),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => Bacon(
                                      sname: widget.sname,
                                      smatrix: widget.smatrix,
                                      spic: widget.spic,
                                    )),
                          );
                        },
                        child: const Text("Registered",
                            style: TextStyle(fontSize: 20)),
                      ),
                    if (newShow == 'View')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 143, 218, 253),
                        ),
                        onPressed: () {
                          initPlatformState();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => Bacon(
                                      sname: widget.sname,
                                      smatrix: widget.smatrix,
                                      spic: widget.spic,
                                    )),
                          );
                        },
                        child:
                            const Text("Close", style: TextStyle(fontSize: 20)),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (kDebugMode) {
      print('Problem ${widget.newId},${widget.beaconuuid},${widget.show}');
    }

    //take event details
    String passEventId = widget.newId.toString();
    String passMatrix = widget.smatrix.toString();
    final DatabaseReference databaseevent =
        FirebaseDatabase.instance.ref().child('/event/$passEventId');
    databaseevent.onValue.listen(
      (event) {
        for (final child in event.snapshot.children) {
          if (child.key.toString() == 'pic') newPic = child.value.toString();
          if (child.key.toString() == 'name') {
            newEventName = child.value.toString();
          }
          if (child.key.toString() == 'desc') newDesc = child.value.toString();
          if (child.key.toString() == 'time') newTime = child.value.toString();
          if (child.key.toString() == 'date') newDate = child.value.toString();
        }
      },
    );
    final DatabaseReference checkstudentevent = FirebaseDatabase.instance
        .ref()
        .child('/student_profile/$passMatrix/eventid/');
    final DataSnapshot snap = await checkstudentevent.get();
    String eventid = widget.newId.toString();
    if (widget.show == '') {
      if (snap.hasChild(eventid)) {
        newShow = 'Registered';
      } else {
        newShow = 'Not Registered';
      }
    } else {
      newShow = 'View';
    }

    return;
  }

//to register event under student id
  addevent(newId) async {
    final DatabaseReference checkstudentevent = FirebaseDatabase.instance
        .ref()
        .child('/student_profile/${widget.smatrix}/eventid/');
    final DataSnapshot snap = await checkstudentevent.get();
    if (snap.hasChild(newId)) {
      registerEvent('You already registered with this event');
      if (kDebugMode) {
        print('No need to register $newId');
      }
    } else {
      checkstudentevent.child(newId).set(widget.beaconuuid.toString());
      registerEvent('You successfully registered with this event');
      if (kDebugMode) {
        print('Event registered $newId');
      }
    }
  }

  registerEvent(String condition) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(condition),
          );
        });
  }
}
