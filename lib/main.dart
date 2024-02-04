import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import './audio_list.dart';
import 'loop_audio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Example',
      home: InternetConnectivity(child: AudioListPage()),   // check if the client is connected to the internet
    );
  }
}

class InternetConnectivity extends StatefulWidget {
  final Widget child;

  InternetConnectivity({required this.child});

  @override
  _InternetConnectivityState createState() =>
      _InternetConnectivityState();
}

class _InternetConnectivityState extends State<InternetConnectivity> {
  late bool? _hasInternet;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;



  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status');
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    print('******************************************************************************');
    print(result);
    print('******************************************************************************');
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionStatus == null) {
      return LoadingScreen();
    } else if (_connectionStatus == ConnectivityResult.none) {
      return NoInternetScreen();
    } else {
      return widget.child;
    }
  }
}

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('No Internet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please connect to the internet'),
            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}


class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
