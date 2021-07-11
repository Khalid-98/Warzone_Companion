import 'dart:async';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class INFO extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: info(),
    );
  }
}

// ignore: camel_case_types
class info extends StatefulWidget {
  @override
  _infoState createState() => _infoState();
}

// ignore: camel_case_types
class _infoState extends State<info> {
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
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
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Device Information',
            style: TextStyle(
              fontFamily: 'Graduate',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.only(left: 15),
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      child: Text('Connection Status: $_connectionStatus',
                          style: TextStyle(
                            fontFamily: 'Graduate',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          )),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<AndroidBatteryInfo>(
                      future: BatteryInfoPlugin().androidBatteryInfo,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            child: Text(
                                'Battery Health: ${snapshot.data.health.toUpperCase()}',
                                style: TextStyle(
                                  fontFamily: 'Graduate',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                )),
                          );
                        }
                        return Container(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: StreamBuilder<AndroidBatteryInfo>(
                  stream: BatteryInfoPlugin().androidBatteryInfoStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                                "Remaining energy: ${-(snapshot.data.remainingEnergy * 1.0E-9)} Watt-hours,",
                                style: TextStyle(
                                  fontFamily: 'Graduate',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                )),
                          ),
                          Expanded(
                            child: _getChargeTime(snapshot.data),
                          ),
                          Expanded(
                            child: Text("Voltage: ${(snapshot.data.voltage)} mV",
                                style: TextStyle(
                                  fontFamily: 'Graduate',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                )),
                          ),
                          Expanded(
                            child: Text(
                                "Charging status: ${(snapshot.data.chargingStatus.toString().split(".")[1])}",
                                style: TextStyle(
                                  fontFamily: 'Graduate',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                )),
                          ),
                          Expanded(
                            child: Text(
                                "Battery Level: ${(snapshot.data.batteryLevel)} %",
                                style: TextStyle(
                                  fontFamily: 'Graduate',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                )),
                          ),
                          Expanded(
                            child:
                                Text("Technology: ${(snapshot.data.technology)} ",
                                    style: TextStyle(
                                      fontFamily: 'Graduate',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    )),
                          ),
                          Expanded(
                            child: Text(
                                "Battery present: ${snapshot.data.present ? "Yes" : "False"} ",
                                style: TextStyle(
                                  fontFamily: 'Graduate',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                )),
                          ),
                          Expanded(
                              child: Text("Scale: ${(snapshot.data.scale)} ",
                                  style: TextStyle(
                                    fontFamily: 'Graduate',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  )),
                          ),
                        ],
                      );
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/info.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.6), BlendMode.dstATop))),
      ),
    );
  }

  Widget _getChargeTime(AndroidBatteryInfo data) {
    if (data.chargingStatus == ChargingStatus.Charging) {
      return data.chargeTimeRemaining == -1
          ? Text("Calculating charge time remaining",
          style: TextStyle(
            fontFamily: 'Graduate',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ))
          : Text(
              "Charge time remaining: ${(data.chargeTimeRemaining / 1000 / 60).truncate()} minutes",
          style: TextStyle(
            fontFamily: 'Graduate',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ));
    }
    return Text("Battery is full or not connected to a power source",
        style: TextStyle(
          fontFamily: 'Graduate',
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ));
  }
}
