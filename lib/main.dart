// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'emaillogin.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'beaconscan.dart';

//main app function is here, redirected login first then home page
//firebase realtime database is initialized here too
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAmmZ8LOIYkeA6wyu6YrJj4m5FZPhRvEH0',
          appId: '1:128338547880:android:d758dd2d2eb92533b95e9d',
          messagingSenderId: '128338547880',
          projectId: 'bacon-70636',
          databaseURL:
              'https://bacon-70636-default-rtdb.asia-southeast1.firebasedatabase.app/'));
  runApp(const MaterialApp(
    home: EmailLogin(),
    title: 'UMSKAL Beacon App',
    // Add other app properties here as needed
  ));
}

class Bacon extends StatefulWidget {
  //passed student profile from login page
  const Bacon({Key? key, this.sname, this.smatrix, this.spic})
      : super(key: key);
  final String? sname;
  final String? smatrix;
  final String? spic;
  @override
  // ignore: library_private_types_in_public_api
  _BaconState createState() => _BaconState();
}

//declare global variables
String beaconname = '';
String _beaconuuid = '';
final eventref = FirebaseDatabase.instance.ref('/beacon/$_beaconuuid/eventid');
String eventId = '';
String eventname = '';
String beaconrec = '';

class _BaconState extends State<Bacon> with WidgetsBindingObserver {
  //declare local variables

  //initialize firebase notification
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //variables for beacon
  String _tag = "Beacons Plugin";
  var isRunning = false;
  String _newProxi = '', _prevProxi = '';
  double beaconDistance = 0;
  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();
  bool showButton = false,
      // ignore: unused_field
      _isInForeground = true,
      _isBeaconInRange = false,
      _proxiChange = false;

  //variables for student profile to be shown in home page
  String? name, emailAddress, photoUrl;

  //show event list using array variables
  List<String> eventIdList = [];
  List<String> eventNamesList = [];

  //page initial state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    userLogin();
    initPlatformState();
    showEventList();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS =
        const DarwinInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: null);
  }

  //check if app is in background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  //called to properly close the beacon scanner observer
  @override
  void dispose() {
    beaconEventsController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

//check if user login using google (deprecated) or student id
  void userLogin() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (final providerProfile in user.providerData) {
        // Name, email address, and profile photo URL
        name = providerProfile.displayName;
        emailAddress = providerProfile.email;
        photoUrl = providerProfile.photoURL;
      }
    } else {
      name = widget.sname;
      emailAddress = widget.smatrix;
      photoUrl = widget.spic;
    }
  }

//where most beacon and firebase function is run
  Future<void> initPlatformState() async {
    //only android, this is permission for locations, while using the app is the only way for the app to work
    if (Platform.isAndroid) {
      //Prominent disclosure
      await BeaconsPlugin.setDisclosureDialogMessage(
          title: "Background Locations",
          message:
              "Click 'While using the app' for beacon scanning features to work");

      //Only in case, you want the dialog to be shown again. By Default, dialog will never be shown if permissions are granted.
      //await BeaconsPlugin.clearDisclosureDialogShowFlag(false);
    }

    //when app is in background, notification beacon monitoring started is shown
    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        log('Method: $call.method' as num);
        if (call.method == 'scannerReady') {
          _showNotification("Beacons monitoring started..");
          await BeaconsPlugin.startMonitoring();
          setState(() {
            isRunning = true;
          });
        } else if (call.method == 'isPermissionDialogShown') {
          _showNotification(
              "Prominent disclosure message is shown to the user!");
        }
      });
    } else if (Platform.isIOS) {
      _showNotification("Beacons monitoring started..");
      await BeaconsPlugin.startMonitoring();
      setState(() {
        isRunning = true;
      });
    }

    //listen beacon
    BeaconsPlugin.listenToBeacons(beaconEventsController);

    //await BeaconsPlugin.addRegion(
    // "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    await BeaconsPlugin.addRegion(
        beaconname, "fda50693-a4e2-4fb1-afcf-c6eb07657825");

    //BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");

    BeaconsPlugin.setForegroundScanPeriodForAndroid(
        foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);

    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
        backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);

    //listening for beacon
    beaconEventsController.stream.listen(
        (data) async {
          if (data.isNotEmpty && isRunning == true) {
            showButton = true;
            Map<String, dynamic> beaconData = json.decode(data);

            //take value from beacon stream to global variables
            setState(() {
              beaconDistance = double.parse(beaconData['distance']);
              _newProxi = beaconData['proximity'];
              _beaconuuid = beaconData['uuid'];
              _isBeaconInRange = true;
            });

            //check if beacon is registered in realtime database
            final DatabaseReference database =
                FirebaseDatabase.instance.ref().child('/beacon');
            DatabaseEvent beaconnode =
                await database.child('/$_beaconuuid/beaconname').once();
            Object? beaconnameobj = beaconnode.snapshot.value;
            beaconname = beaconnameobj.toString();

            if (kDebugMode) {
              print(
                  'Beacon $_beaconuuid name from Firebase Realtime DB is $beaconname');
            }

            //problem 1 : this part of  new proxi noti logic is not captured, probably for real physical beacon only
            //see changes in stream
            if (_newProxi != _prevProxi) {
              _proxiChange = true;
            } else {
              _proxiChange = false;
            }
            //set new as prev data
            _prevProxi = _newProxi;
            if (beaconDistance <= 0.5) {
              // User has entered the beacon region : new proxi noti
              if (_proxiChange == true) {
                _showNotification('Entering region $beaconname');
              }
              showButton = true;
            } else {
              // User has exited the beacon region : new proxi noti
              if (_proxiChange == true) {
                _showNotification('Exiting region $beaconname');
              }
              showButton = false;
              _isBeaconInRange = false;
            }

            if (kDebugMode) {
              print('Beacons Data Received:  $data');
            }
          } else if (data.trim().isEmpty || !isRunning) {
            if (kDebugMode) {
              print('No beacon is found');
            }

            showButton = false;
            _isBeaconInRange = false;
          }
        },
        onDone: () {},
        onError: (error) {
          log('Error: $error' as num);
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);

    if (!mounted) return;
  }

//build home page interface
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 143, 218, 253),
        ),
        useMaterial3: true,
      ),
      //header shows profile picture
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'UMSKAL Beacons',
              style: TextStyle(fontSize: 20),
            ),
            backgroundColor: const Color.fromARGB(255, 143, 218, 253),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(photoUrl ?? ''),
                backgroundColor: const Color.fromARGB(255, 143, 218, 253),
                radius: 50,
              ),
            ),
            //problem 2 : need to clicked button twice for value to be set to next page
            //show list of event button
            actions: [
              IconButton(
                icon: const Icon(Icons.list_alt_rounded),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Events that you are registered'),
                        content: ListView.builder(
                          itemCount: eventNamesList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(eventNamesList[index]),
                              onTap: () {
                                stopOperation('View', eventIdList[index]);

                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              //logout button
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _signOut();
                  if (kDebugMode) {
                    print(FirebaseAuth.instance.authStateChanges());
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmailLogin()));
                },
              ),
            ],
          ),
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //show student name
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Hi $name',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                //problem 3 : need to clicked button twice for value to be set to next page
                //problem 4 : need loading animation considering how long it takes for the scan to happens, user can accidentally clicked twice while it was pending
                //problem 5 : reclicking button after moving back from next page at "Read More" will increase scanning time and broke the app

                //the scanner button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isRunning
                        ? (_isBeaconInRange
                            ? Text(
                                'Found beacon $beaconname and is it $beaconDistance meter(s) away from you')
                            : const Text('No beacon found'))
                        : const Text('Scanning is off'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 143, 218, 253),
                    ),
                    onPressed: () async {
                      if (isRunning) {
                        await BeaconsPlugin.stopMonitoring();
                        showButton = false;
                      } else {
                        initPlatformState();
                        await BeaconsPlugin.startMonitoring();
                      }
                      setState(() {
                        isRunning = !isRunning;
                      });
                    },
                    child: Text(isRunning ? 'Stop Scanning' : 'Start Scanning',
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                //"Read More" button to change page to beaconscan.dart where event details is shown
                Visibility(
                  visible: showButton,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                      title: Text(
                        displayName(),
                        textAlign: TextAlign.center,
                      ),
                      subtitle: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 143, 218, 253),
                        ),
                        onPressed: () async {
                          stopOperation('', '');
                        },
                        child: const Text("Show More",
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ),
              ]),
        );
      }),
    );
  }

  //fetch from db for list of event, when clicked on event, show more event details
  Future<String> eventcheck() async {
    //check if this beacon has event
    final DatabaseReference databasebeacon =
        FirebaseDatabase.instance.ref().child('/beacon/$_beaconuuid/event/');
    DatabaseEvent checkid = await databasebeacon.once();
    eventId = checkid.snapshot.value.toString();
    final DataSnapshot snap = await databasebeacon.get();
    if (snap.hasChild(eventId)) {
      final DatabaseReference databaseevents =
          FirebaseDatabase.instance.ref().child('/event/$eventId/name/');
      DatabaseEvent checkevent = await databaseevents.once();
      eventname = checkevent.snapshot.value.toString();
      return eventname;
    } else {
      return eventname = 'No event in this area';
    }
  }

  //to return string, not ass async function (cannot return asycn type to text widget)
  String displayName() {
    eventcheck();
    return eventname;
  }

  //firebase notification default template
  void _showNotification(String subtitle) {
    var rng = Random();
    Future.delayed(const Duration(seconds: 5)).then((result) async {
      var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'ID Bacon Beacon', 'Channel Bacon',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          icon: '@drawable/ic_notification');
      var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      // ignore: prefer_typing_uninitialized_variables
      var flutterLocalNotificationsPlugin;
      await flutterLocalNotificationsPlugin.show(
          rng.nextInt(100000), _tag, subtitle, platformChannelSpecifics,
          payload: 'item x');
    });
  }

  // problem 6 : beacon scanning is not closed properly even tho, dispose and isRunning is closed using setState
  Future<void> stopOperation(showwhat, events) async {
    //stopped beacon scanning when "Read More" is clicked
    if (events == '') {
      setState(() {
        dispose();
        showButton = false;
        isRunning = false;
      });
      events = eventId;
      beaconrec = _beaconuuid;
    }
    //take event details for list of events registered
    else {
      await checkBeacon(beaconrec, events);
    }
    //change to beaconscan page
    changePage(beaconrec, showwhat, events);

    if (kDebugMode) {
      print('Haiya $beaconrec, but like $events');
    }
  }

  //change to beaconscan page to read more about event details

  changePage(beaconrec, showwhat, events) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => BeaconScan(
                beaconuuid: beaconrec,
                smatrix: widget.smatrix,
                sname: widget.sname,
                spic: widget.spic,
                show: showwhat,
                newId: events,
              )),
    );
  }

  //to get beaconid of event, place of event
  checkBeacon(beaconwhere, events) async {
    final DatabaseReference show = FirebaseDatabase.instance
        .ref()
        .child('student_profile/${widget.smatrix}/eventid/');
    DatabaseEvent beaconwhat = await show.child(events).once();
    beaconrec = beaconwhat.snapshot.value!.toString();
  }

  //to show list of event that student successfully registered
  showEventList() {
    final DatabaseReference show = FirebaseDatabase.instance
        .ref()
        .child('student_profile/${widget.smatrix}/eventid/');
    final DatabaseReference eventname =
        FirebaseDatabase.instance.ref().child('/event');
    eventNamesList.clear();
    eventIdList.clear();
    show.onValue.listen(
      (event) async {
        for (final child in event.snapshot.children) {
          DatabaseEvent showEvent =
              await eventname.child('/${child.key.toString()}/name').once();
          Object? name = showEvent.snapshot.value;
          eventNamesList.add(name.toString());
          eventIdList.add(child.key.toString());
          setState(() {});
        }
      },
    );
  }
}

//for google logout (deprecated)
Future<void> _signOut() async {
  var proid = FirebaseAuth.instance.currentUser!.providerData[0].providerId;
  if (proid == 'google.com') {
    await GoogleSignIn().signOut();
  }
  await FirebaseAuth.instance.signOut();
}
