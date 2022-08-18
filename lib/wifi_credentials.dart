import 'package:flutter/material.dart';

class WiFiCredentials extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WiFiCredentialsState();
}

class _WiFiCredentialsState extends State<WiFiCredentials> {
  _SelectWiFiState() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Username/Password"),
        ),
        body: Text("Username, Password"));
  }
}
