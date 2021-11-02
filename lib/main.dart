import 'dart:io';

import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<ActivityEvent> activityStream;
  ActivityEvent latestActivity = ActivityEvent.empty();
  List<GpsEvent> _events = [];
  ActivityRecognition activityRecognition = ActivityRecognition.instance;
  SuperCashEvents? _state = SuperCashEvents.CRUISING;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    /// Android requires explicitly asking permission
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.request().isGranted) {
        _startTracking();
      }
    }

    /// iOS does not
    else {
      _startTracking();
    }
  }

  void _startTracking() {
    activityStream =
        activityRecognition.startStream(runForegroundService: true);
    activityStream.listen(onData);
  }

  void onData(ActivityEvent activityEvent) {
    print(activityEvent.toString());
    setState(() {
      _events.add(GpsEvent(activityEvent, null));
      latestActivity = activityEvent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _events.add(GpsEvent(null, _state));
            });
          },
        ),
        appBar: AppBar(
          title: const Text('Activity Recognition'),
          actions: [
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.delete),
              ),
              onTap: () {
                setState(() {
                  _events = [];
                });
              },
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.share),
              ),
              onTap: () {
                Share.share(getListString(_events));
              },
            )
          ],
        ),
        bottomNavigationBar: Container(
          height: 200,
          width: 200,
          child: ListView(
            children: [
              ListTile(
                title: const Text('CRUISING'),
                leading: Radio<SuperCashEvents>(
                  value: SuperCashEvents.CRUISING,
                  groupValue: _state,
                  onChanged: (SuperCashEvents? value) {
                    setState(() {
                      _state = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('ENTERED'),
                leading: Radio<SuperCashEvents>(
                  value: SuperCashEvents.ENTERED,
                  groupValue: _state,
                  onChanged: (SuperCashEvents? value) {
                    setState(() {
                      _state = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('EXITED'),
                leading: Radio<SuperCashEvents>(
                  value: SuperCashEvents.EXITED,
                  groupValue: _state,
                  onChanged: (SuperCashEvents? value) {
                    setState(() {
                      _state = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('PARKED'),
                leading: Radio<SuperCashEvents>(
                  value: SuperCashEvents.PARKED,
                  groupValue: _state,
                  onChanged: (SuperCashEvents? value) {
                    setState(() {
                      _state = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('WALKING'),
                leading: Radio<SuperCashEvents>(
                  value: SuperCashEvents.WALKING,
                  groupValue: _state,
                  onChanged: (SuperCashEvents? value) {
                    setState(() {
                      _state = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        body: new Center(
            child: new ListView.builder(
                itemCount: _events.length,
                itemBuilder: (BuildContext context, int idx) {
                  final entry = _events[idx];
                  return entry.event != null
                      ? ListTile(
                          leading: Text(entry.event!.timeStamp
                              .toString()
                              .substring(0, 19)),
                          trailing: Text(
                              entry.event!.type.toString().split('.').last))
                      : ListTile(
                          leading: Text(entry.superEvent.toString()),
                        );
                })),
      ),
    );
  }

  String getListString(List<GpsEvent> list) {
    var logs = list.map((e) {
      return e.event != null ? e.event.toString() : e.superEvent.toString();
    });
    return logs.join(",");
  }
}

class GpsEvent {
  final ActivityEvent? event;
  final SuperCashEvents? superEvent;

  GpsEvent(this.event, this.superEvent);
}

enum SuperCashEvents { ENTERED, CRUISING, PARKED, WALKING, EXITED }
