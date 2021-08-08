import 'dart:async';
//import 'package:all_sensors/all_sensors.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

enum TtsState { playing, stopped }

class _HomeState extends State<Home> {
  final FlutterTts flutterTts = FlutterTts();
  dynamic languages;
  late String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool activated = false;
  int speak = 0;

  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  //bool _proximityValues = false;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: GestureDetector(
        onTap: () {
          print('tappedddddddddddddddddddddd');
        },
        child: Container(
          child: Column(
            children: [
              Text('Accelerometer: $accelerometer'),
              Text('UserAccelerometer: $userAccelerometer'),
              Text('Gyroscope: $gyroscope'),
              /*Text('Proximity: $_proximityValues'),
              _proximityValues == true
                  ? Text('${DateTime.now()}')
                  : Text('False'),*/
              Text('${accelerometer![2]}'),
              accelerometer[2] == '9.8'
                  ? Text('False')
                  : Text('${DateTime.now()}'),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      activated == false ? activated = true : activated = false;
                    });
                    //_speak(DateTime.now().toString());
                  },
                  child: Text(
                    'Speak',
                    style:
                        TextStyle(color: activated ? Colors.green : Colors.red),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    initTts();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            if (activated) {
              if (_accelerometerValues![2] > 9.8) {
                speak = 1;
                if (speak == 1) {
                  _speak(DateTime.now().toString());
                  speak = 0;
                }
              }
            } else {
              _stop();
            }

            //print(_accelerometerValues);
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    /*_streamSubscriptions.add(proximityEvents.listen((ProximityEvent event) {
      setState(() {
        _proximityValues = event.getValue();

        ///print(_proximityValues);
      });
    }));*/
  }

  initTts() {
    //_getLanguages();

    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  /*Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    print("pritty print ${languages}");
    if (languages != null) setState(() => languages);
  }*/

  Future _speak(String voiceText) async {
    await flutterTts.setVolume(0.4);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    var result = await flutterTts.speak(voiceText);
    if (result == 1) setState(() => ttsState = TtsState.playing);
    /*if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak('Hello');
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }*/
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }
}
