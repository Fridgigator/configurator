import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import 'SelectHub.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refridgigator setup',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Refridgigator setup'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() async {
    var status = await Permission.location.status;
    print(await Permission.location.request());
  }

  @override
  Widget build(BuildContext context) {
    return SelectHub();
  }
}

/*
  final characteristic = QualifiedCharacteristic(
            serviceId: Uuid.parse("170e6a4c-af9e-4a1f-843e-e4fb5e165c62"),
            characteristicId:
                Uuid.parse("7eb1afe1-e0c6-4539-86a3-1b293ff80588"),
            deviceId: "24:0A:C4:58:E0:D2");
        final response =
            await flutterReactiveBle.readCharacteristic(characteristic);
        print("response=$response");
        await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
            value: "Hi Hi\x00".runes.map((e) => e).toList());
        await flutterReactiveBle.deinitialize();
        */

