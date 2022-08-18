import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'constants.dart';

class BLEConnection {
  final flutterReactiveBle = FlutterReactiveBle();

  late QualifiedCharacteristic writeCh;
  late QualifiedCharacteristic readCh;
  BLEConnection({required String deviceID}) {
    writeCh = QualifiedCharacteristic(
        serviceId: Constants().ServiceUUID,
        characteristicId: Constants().WriteUUID,
        deviceId: deviceID);
    readCh = QualifiedCharacteristic(
        serviceId: Constants().ServiceUUID,
        characteristicId: Constants().ReadUUID,
        deviceId: deviceID);
  }
  Future<void> send(String data) async {
    await flutterReactiveBle.writeCharacteristicWithResponse(writeCh,
        value: utf8.encode(data));
  }

  Future<List<int>> recv() async {
    List<int> result = [];
    int valLen =
        ByteData.sublistView(await _getPacket()).getUint32(0, Endian.little);

    while (result.length < valLen) {
      print("result.length=${result.length}, valLen=$valLen");
      result.addAll(await _getPacket());
    }
    print("Finished getting data");
    return result;
  }

  Future<Uint8List> _getPacket() async {
    print("Getting packet");
    List<int> response = await flutterReactiveBle.readCharacteristic(readCh);
    while (response.isEmpty) {
      response = await flutterReactiveBle.readCharacteristic(readCh);
      print(response);
    }
    print(response);
    print("Got packet of len ${response.length}");
    await flutterReactiveBle
        .writeCharacteristicWithoutResponse(readCh, value: []);
    await flutterReactiveBle
        .writeCharacteristicWithoutResponse(writeCh, value: [127]);

    return Uint8List.fromList(response);
  }
}
