import 'package:flutter/material.dart';

class SelectWiFi extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SelectWiFiState();
}

class _SelectWiFiState extends State<SelectWiFi> {
  _SelectWiFiState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Select WiFi"),
        ),
        body: Text("Hi"));
  }
}
