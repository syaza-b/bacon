// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bacon());
}

class Bacon extends StatefulWidget {
  const Bacon({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BaconState createState() => _BaconState();
}

String beaconId = 'Holy-IOT';

class _BaconState extends State<Bacon> with WidgetsBindingObserver {
  //declare vars
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String _tag = "Beacons Plugin";
  var isRunning = false;
  bool _isBeaconInRange = false;
  String beaconName = '';
  double beaconDistance = 0;
  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();
  bool isNear = false, showButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();

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

  @override
  void dispose() {
    beaconEventsController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      //Prominent disclosure
      await BeaconsPlugin.setDisclosureDialogMessage(
          title: "Background Locations",
          message:
              "Bacon app collects location data to enable Beacon Scanning Feature even when the app is closed or not in use");

      //Only in case, you want the dialog to be shown again. By Default, dialog will never be shown if permissions are granted.
      //await BeaconsPlugin.clearDisclosureDialogShowFlag(false);
    }

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
    BeaconsPlugin.listenToBeacons(beaconEventsController);

    //await BeaconsPlugin.addRegion(
    // "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    await BeaconsPlugin.addRegion(
        beaconId, "fda50693-a4e2-4fb1-afcf-c6eb07657825");

    //BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");

    BeaconsPlugin.setForegroundScanPeriodForAndroid(
        foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);

    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
        backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);

    beaconEventsController.stream.listen(
        (data) {
          if (data.isNotEmpty && isRunning) {
            showButton = true;
            Map<String, dynamic> beaconData = json.decode(data);
            setState(() {
              beaconDistance = double.parse(beaconData['distance']);
            });

            isNear = data.contains('Near');
            if (_isBeaconInRange && !isNear) {
              // User has exited the beacon region
              _showNotification('Exiting beacon area');
              showButton = false;
              //_isBeaconInRange = false;
            } else if (!_isBeaconInRange && isNear) {
              // User has entered the beacon region
              _showNotification('Entering beacon area');
              _isBeaconInRange = true;
              showButton = true;
            }
            if (kDebugMode) {
              print('Beacons Data Received:  $data');
            }
          } else if (data.isEmpty && isRunning) {
            if (kDebugMode) {
              print('Beacons Data Got:  $data');
            }
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bacon Beacons'),
            backgroundColor: Colors.amber,
          ),
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isRunning
                        ? (_isBeaconInRange
                            ? Text(
                                'Found beacon $beaconId and is it $beaconDistance meter(s) away from you')
                            : const Text('No beacon found'))
                        : const Text('Scanning is off'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.amber),
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
                Visibility(
                  visible: showButton,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber),
                      onPressed: () async {
                        launchUrl(Uri.parse(
                            'https://cdn-icons-png.flaticon.com/512/590/590796.png'));
                      },
                      child: const Text("Read More",
                          style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ]),
        );
      }),
    );
  }

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
      await flutterLocalNotificationsPlugin.show(
          rng.nextInt(100000), _tag, subtitle, platformChannelSpecifics,
          payload: 'item x');
    });
  }
}
