import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

import 'constants.dart';
import 'select_wifi.dart';

class SelectHub extends StatefulWidget {
  const SelectHub({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectHubState();
}

class _SelectHubState extends State<SelectHub> {
  List<BLEDevice> BLEDeviceList = [];
  bool canRefresh = true;
  final flutterReactiveBle = FlutterReactiveBle();
  _SelectHubState() {
    flutterReactiveBle.deinitialize();
    flutterReactiveBle.initialize();

    getNewSearchData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Select Hub"),
          actions: [
            IconButton(
                onPressed: canRefresh ? refreshBLESearch : null,
                icon: Icon(Icons.refresh))
          ],
        ),
        body: BLEDeviceList.isEmpty
            ? SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 64, 0, 64),
                    child: Center(child: CircularProgressIndicator())))
            : SingleChildScrollView(
                child: Column(
                    children: BLEDeviceList.map((e) => BLEDeviceDisplay(
                        BLEDeviceData: e,
                        onClick: () {
                          setState(() {
                            flutterReactiveBle.deinitialize();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectWiFi(
                                        name: e.name, deviceID: e.id)));
                          });
                        })).toList())));
  }

  Stream<BLEDevice> getBLEDevices() async* {
    if (await Permission.location.request().isGranted) {
      List<BLEDevice> BLEDeviceList = [];
      yield* flutterReactiveBle.scanForDevices(
        withServices: [Constants().ServiceUUID],
      ).map((event) => BLEDevice(
          name: event.name,
          RSSI: event.rssi,
          device: event.manufacturerData,
          id: event.id));
    }
  }

  void refreshBLESearch() {
    setState(() {
      canRefresh = false;
    });
    print("Can't refresh");
    // According to https://github.com/NordicSemiconductor/Android-Scanner-Compat-Library/issues/18,
    // Android will prevent applications from starting and stopping scans more than 5 times in 30 seconds.

    Future.delayed(Duration(seconds: 10)).then((v) async {
      setState(() {
        canRefresh = true;
      });
      print("Can refresh");
    });

    flutterReactiveBle.deinitialize();
    flutterReactiveBle.initialize();
    setState(() {
      BLEDeviceList = [];
    });
    getNewSearchData();
  }

  void getNewSearchData() {
    getBLEDevices().listen((event) {
      print("$event");
      bool contains = false;
      for (BLEDevice d in BLEDeviceList) {
        if (d.name == event.name) {
          contains = true;
        }
      }
      if (!contains) {
        setState(() {
          BLEDeviceList.add(event);
        });
      }
    });
  }
}

class BLEDevice {
  String name;
  int RSSI;
  Uint8List device;
  String id;
  BLEDevice({
    required this.name,
    required this.RSSI,
    required this.device,
    required this.id,
  });
  @override
  bool operator ==(Object other) {
    return other is BLEDevice &&
        other.name == name &&
        other.device == device &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hashAll([name, device, id]);
}

class BLEDeviceDisplay extends StatelessWidget {
  final BLEDevice BLEDeviceData;
  GestureTapCallback? onClick;
  BLEDeviceDisplay(
      {Key? key, required this.BLEDeviceData, required this.onClick})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onClick,
        child: Padding(
            padding: EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16),
            child: Container(
                child: Row(
              children: [
                Icon(Icons.bluetooth, size: 36),
                Container(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${BLEDeviceData.name}"),
                      Text("RSSI: ${BLEDeviceData.RSSI}"),
                    ],
                  ),
                ),
              ],
            ))));
  }
}
