import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:led_control/bluetooth_engine.dart';

class LedcontrolButtonPanel extends StatefulWidget {
  //TODO: make portrait only
  const LedcontrolButtonPanel(
      {Key? key, required this.title, required this.engine})
      : super(key: key);

  final String title;
  final BluetoothEngine engine;

  @override
  State<StatefulWidget> createState() => _LedcontrolButtonPanelState();
}

class _LedcontrolButtonPanelState extends State<LedcontrolButtonPanel> {
  bool _connected = false;
  double _brightness = 255;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bluetooth,
              color: _connected ? Colors.green : Colors.red,
            ),
            onPressed: null,
          ),
        ],
      ),
      body: ListView(
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            children: [
              _modeChangeButton("Animated rainbow 1", [0x01, 0x01]),
              _modeChangeButton("Animated rainbow 2", [0x01, 0x02]),
              _modeChangeButton("Bouncing rainbow strip", [0x01, 0x03]),
              _modeChangeButton("Christmas lights", [0x01, 0x04]),
              _modeChangeButton("Strobe light", [0x01, 0x05]),
              _modeChangeButton("Fire brigade lights", [0x01, 0x06]),
              _modeChangeButton("Portal lights", [0x01, 0x07]),
              _modeChangeButton("Police lights", [0x01, 0x08]),
              _modeChangeButton("Knight rider", [0x01, 0x09]),
              _modeChangeButton("Warm white", [0x01, 0x0A]),
            ],
          ),
          const Divider(),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            children: [
              _modeChangeButton("Lights off", [0x01, 0x00]),
              _modeChangeButton("Speed up", [0x02]),
              Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: ElevatedButton(
                      onPressed: _connected ? null : () => {tryConnecting()},
                      child: const Text("Connect"))),
              _modeChangeButton("Speed down", [0x03]),
            ],
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Brightness: ${_brightness ~/ 2.55}%',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Slider(
            value: _brightness,
            min: 0,
            max: 255,
            onChangeEnd: _connected
                ? (newValue) {
                    setState(() {
                      _brightness = newValue;
                      widget.engine.sendMessage(
                          Uint8List.fromList([0x05, _brightness.toInt()]));
                    });
                  }
                : null,
            onChanged: _connected
                ? (newValue) {
                    setState(() {
                      _brightness = newValue;
                    });
                  }
                : null,
          ),
          const Divider(),
        ],
      ),
    );
  }

  void tryConnecting() {
    widget.engine.tryConnecting();
    setState(() {
      _connected = widget.engine.connection != null &&
          widget.engine.connection!.isConnected;
    });
  }

  Padding _modeChangeButton(String label, List<int> command) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        onPressed: _connected
            ? () {
                widget.engine
                    .sendMessage(Uint8List.fromList(command))
                    .then((value) => {if (!value) tryConnecting()});
              }
            : null,
        child: Text(label),
      ),
    );
  }
}
