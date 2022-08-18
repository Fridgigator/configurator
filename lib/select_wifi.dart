import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:configurator/wifi_credentials.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:messagepack/messagepack.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

import 'connection.dart';
import 'constants.dart';

class SelectWiFi extends StatefulWidget {
  String name;
  String deviceID;
  SelectWiFi({Key? key, required this.name, required this.deviceID})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _SelectWiFiState();
}

class _SelectWiFiState extends State<SelectWiFi> {
  List<WiFiDevice> WiFiDeviceList = [];
  bool canRefresh = true;
  BLEConnection? bleConnection;
  StreamSubscription<ConnectionStateUpdate>? _connectionStreamUpdate;
  final flutterReactiveBle = FlutterReactiveBle();

  @override
  initState() {
    super.initState();
    () async {
      await flutterReactiveBle.deinitialize();
      await flutterReactiveBle.initialize();
      getNewSearchData();
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Select WiFi"),
          actions: [
            IconButton(
                onPressed: canRefresh ? refreshBLESearch : null,
                icon: Icon(Icons.refresh))
          ],
        ),
        body: WiFiDeviceList.isEmpty
            ? SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 64, 0, 64),
                    child: Center(child: CircularProgressIndicator())))
            : SingleChildScrollView(
                child: Column(
                    children: WiFiDeviceList.map((e) => WiFiDeviceDisplay(
                        wifiDeviceData: e,
                        onClick: () {
                          setState(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WiFiCredentials()));
                          });
                        })).toList())));
  }

  void refreshBLESearch() async {
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

    developer.log("refreshing", name: 'my.app.category');
    await _connectionStreamUpdate?.cancel();
    setState(() {
      WiFiDeviceList = [];
    });
    getNewSearchData();
  }

  void getNewSearchData() {
    print("deviceID=${widget.deviceID}");
    _connectionStreamUpdate = flutterReactiveBle
        .connectToAdvertisingDevice(
      id: widget.deviceID,
      withServices: [Constants().ServiceUUID],
      prescanDuration: const Duration(seconds: 5),
      servicesWithCharacteristicsToDiscover: {
        Constants().ServiceUUID: [Constants().ReadUUID, Constants().WriteUUID]
      },
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionState) async {
      await updateConnectionState(connectionState);
    }, onError: (dynamic error) {
      print("error: $error");
    });
  }

  Future<void> updateConnectionState(
      ConnectionStateUpdate connectionState) async {
    print("state=${connectionState.connectionState}");
    switch (connectionState.connectionState) {
      case DeviceConnectionState.connecting:
        print("Connecting");
        bleConnection = null;
        break;
      case DeviceConnectionState.disconnected:
        print("Disconnected");
        bleConnection = null;
        break;
      case DeviceConnectionState.disconnecting:
        print("Disconnecting");
        bleConnection = null;
        break;
      case DeviceConnectionState.connected:
        try {
          bleConnection = BLEConnection(deviceID: widget.deviceID);
          await bleConnection?.send("{\"type\":1}");
          print("Sent");
          List<int>? wifiListData = await bleConnection?.recv();
          if (wifiListData != null) {
            final u = Unpacker.fromList(wifiListData);
            List<Object?> list = u.unpackList();
            print("l.length=${list.length}");
            for (Object? l in list) {
              print("l=$l");
            }
            setState(() {
              WiFiDeviceList = list
                  .map((e) {
                    if (e is List) {
                      return WiFiDevice(
                        name: e[0],
                        bssid: e[1],
                        channel: e[2],
                        isEncrypted: e[3],
                      );
                    } else {
                      return null;
                    }
                  })
                  .where((element) => element != null)
                  .map((e) => e!)
                  .toList();
            });
          }
          print("recv");
          print(wifiListData);
          if (wifiListData != null) {
            print(wifiListData);
          }
        } catch (e) {
          setState(() {
            WiFiDeviceList = [];
          });
        }
    }
  }
}

class WiFiDevice {
  String name;
  List<int> bssid;
  int channel;
  bool isEncrypted;
  WiFiDevice({
    required this.name,
    required this.bssid,
    required this.channel,
    required this.isEncrypted,
  });
  @override
  bool operator ==(Object other) {
    return other is WiFiDevice &&
        other.name == name &&
        listEquals(bssid, other.bssid);
  }

  @override
  int get hashCode => Object.hashAll([name, channel, bssid, isEncrypted]);
}

class WiFiDeviceDisplay extends StatelessWidget {
  final WiFiDevice wifiDeviceData;
  GestureTapCallback? onClick;
  WiFiDeviceDisplay(
      {Key? key, required this.wifiDeviceData, required this.onClick})
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
                Icon(wifiDeviceData.isEncrypted ? Icons.wifi_lock : Icons.wifi,
                    size: 36),
                Container(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${wifiDeviceData.name}"),
                      Text("Is Encrypted: ${wifiDeviceData.isEncrypted}"),
                    ],
                  ),
                ),
              ],
            ))));
  }
}
