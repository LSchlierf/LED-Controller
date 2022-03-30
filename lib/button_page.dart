import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:led_control/bluetooth_engine.dart';
import 'package:led_control/main.dart';

class ButtonPanel extends StatefulWidget {
  //TODO: make portrait only
  const ButtonPanel(
      {Key? key, required this.title, required this.engine, required this.type})
      : super(key: key);

  final String title;
  final BluetoothEngine engine;
  final deviceType type;

  @override
  State<StatefulWidget> createState() => _ButtonPanelState();
}

class _ButtonPanelState extends State<ButtonPanel> {
  double _brightness = 255;

  @override
  void initState() {
    super.initState();
    if (!_isConnected) {
      _tryConnecting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          makeConnectionIcon(widget.engine),
        ],
      ),
      body: ListView(
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            children: _modeButtons,
          ),
          const Divider(),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            children: _controlPanel,
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
            onChangeEnd: _isConnected
                ? (newValue) {
                    setState(() {
                      _brightness = newValue;
                      widget.engine.sendMessage(
                          Uint8List.fromList([0x05, _brightness.toInt()]));
                    });
                  }
                : null,
            onChanged: _isConnected
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

  bool get _isConnected {
    return widget.engine.isConnected;
  }

  bool get _isConnecting {
    return widget.engine.isConnecting;
  }

  bool get _isDisconnected {
    return widget.engine.isDisconnected;
  }

  void _tryConnecting() {
    setState(() {
      widget.engine.tryConnecting().whenComplete(() {
        setState(() {});
      });
    });
  }

  Widget _modeChangeButton(String label, List<int> command) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        onPressed: _isConnected
            ? () {
                widget.engine
                    .sendMessage(Uint8List.fromList(command))
                    .then((value) => {if (!value) _tryConnecting()});
              }
            : null,
        child: Text(label),
      ),
    );
  }

  List<Widget> get _controlPanel {
    return [
      _modeChangeButton("Lights off", [0x01, 0x00]),
      _modeChangeButton("Speed up", [0x02]),
      Padding(
          padding: const EdgeInsets.all(6.0),
          child: ElevatedButton(
              onPressed: _isDisconnected ? _tryConnecting : null,
              child: const Text("Connect"))),
      _modeChangeButton("Speed down", [0x03]),
    ];
  }

  List<Widget> get _modeButtons {
    switch (widget.type) {
      case deviceType.longboard:
        return [
          _modeChangeButton("Rainbow Boulevard", [0x00, 0x04]),
          _modeChangeButton("Bike lights", [0x00, 0x00]),
          _modeChangeButton("Highlights red", [0x00, 0x01]),
          _modeChangeButton("Animated rainbow 1", [0x01, 0x01]),
          _modeChangeButton("Highlights green", [0x00, 0x02]),
          _modeChangeButton("Animated rainbow 2", [0x01, 0x02]),
          _modeChangeButton("Highlights blue", [0x00, 0x03]),
          _modeChangeButton("Bouncing rainbow strip", [0x01, 0x03]),
          _modeChangeButton("Highlights multicolor", [0x00, 0x05]),
          _modeChangeButton("Christmas lights", [0x01, 0x04]),
          _modeChangeButton("Highlights police colors", [0x00, 0x06]),
          _modeChangeButton("Strobe light", [0x01, 0x05]),
        ];

      case deviceType.ledController:
        return [
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
        ];
    }
  }

  static Widget makeConnectionIcon(BluetoothEngine engine) {
    return IconButton(
      icon: Icon(
        engine.isConnecting
            ? Icons.bluetooth_searching
            : (engine.isConnected
                ? Icons.bluetooth_connected
                : Icons.bluetooth_disabled),
        color: engine.isConnected
            ? Colors.green
            : (engine.isDisconnected ? Colors.red : Colors.yellow),
      ),
      onPressed: null,
    );
  }
}
