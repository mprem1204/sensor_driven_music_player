import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sensors_plus/sensors_plus.dart';

class LoopAudio extends StatefulWidget {
  final int songId;
  final String songName;

  LoopAudio({required this.songId, required this.songName});

  @override
  _LoopAudioState createState() => _LoopAudioState();
}

class _LoopAudioState extends State<LoopAudio> {
  late AudioPlayer _audioPlayer;
  String _songUrl = '';
  String _songImage = '';
  double _accelerometerValueX = 0.0;
  double _accelerometerValueY = 0.0;
  double _accelerometerValueZ = 0.0;
  bool _isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();
  String _pageState = 'YET_TO_MAKE_API_CALL';
  AccelerometerEvent? _accelerometerEvent;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadSongUrl();

    _startAccelerometer();
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      // addmin and event listenr foe Accelerometer
      setState(() {
        _accelerometerValueX = event.x ?? 0.0;
        _accelerometerValueY = event.y ?? 0.0;
        _accelerometerValueZ = event.z ?? 0.0;
      });
      _adjustPlayBackRate();
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });
  }

  void _adjustPlayBackRate() {
    double currentRate = 1.0;

    double instabilityLevel = calculateInstabilityLevel();

    double newTempo = currentRate + (instabilityLevel);

    newTempo = newTempo.clamp(1.0, 10.0);

    print(newTempo);

    _audioPlayer.setPlaybackRate(newTempo);
  }


  // If the mobile phone is stable across any access then the tempo rate is normal othervise the tempo rate will accelerate base on the instability level  
  double calculateInstabilityLevel() {
    double instabilityLevel = _accelerometerValueX.abs() + _accelerometerValueY.abs() + _accelerometerValueZ.abs();
    if (instabilityLevel < 11) return 0;
    else if (instabilityLevel < 12) return 0.1;
    else if (instabilityLevel < 14) return 0.6;
    else if (instabilityLevel < 15) return 0.7;
    else if (instabilityLevel < 17) return 2;
    else return 5;
  }

  Future<void> _loadSongUrl() async {
    try {
      final String apiUrl = 'https://freesound.org/apiv2/sounds/${widget.songId}/?token=ZO8Ny9tMBLKCQw3DOAIhYD8glC9IUTkh8gnDGuQW';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String songUrl = data['previews']['preview-hq-mp3'];
        final String songImage = data['images']['waveform_m'];
        setState(() {
          _songUrl = songUrl;
          _songImage = songImage;
          _pageState = 'API_CALL_RESOLVED_SUCCESS';
        });

        _playSong();
      } else {
        setState(() {
          _pageState = 'API_CALL_RESOLVED_FAILED';
        });
        print('Failed to load song details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading song details: $e');
    }
  }

  Future<void> _playSong() async {   //  Play Handler
    if (_songUrl.isNotEmpty) {
      await _audioPlayer.play(UrlSource(_songUrl));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _pauseSong() async {   // Pause handler
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {  // cleanup when component is about to unmount
    _audioPlayer.pause();
    _audioPlayer.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return _pageState == 'YET_TO_MAKE_API_CALL'
        ? Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
                title: Text(
                  'Accelerometer',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                backgroundColor: Color(0xFF0C44A3),
                elevation: 4,
                centerTitle: true,
                iconTheme: IconThemeData(color: Colors.white)),
            body: Column(
              children: [
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AccelerometerCard('x-value', _accelerometerValueX),
                      AccelerometerCard('y-value', _accelerometerValueY),
                      AccelerometerCard('z-value', _accelerometerValueZ),
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Image.network(
                            _songImage,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    widget.songName.split(' ').first,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                Container(height: 10),
                              ],
                            ),
                          ),
                          Container(height: 5),
                        ],
                      ),
                    )),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    if (_position != null &&
                        _duration != null &&
                        _duration.inMilliseconds > 0 &&
                        _position.inMicroseconds > 0)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _position.inMilliseconds /
                                _duration.inMilliseconds,
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_position.inMilliseconds / 1000).toStringAsFixed(2)}s',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${(_duration.inMilliseconds / 1000).toStringAsFixed(2)}s',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isPlaying ? _pauseSong : _playSong,
                      child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                  ]),
                )
              ],
            ),
          );
  }
}

class AccelerometerCard extends StatelessWidget {   // Stateless Resusable Component
  final String label;
  final double value;

  AccelerometerCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          color: Color(0xFF0C44A3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ));
  }
}
