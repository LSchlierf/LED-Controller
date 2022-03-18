import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:led_control/bluetooth_engine.dart';

class ButtonPageLongboard extends StatelessWidget {
  final BluetoothDevice device;

  const ButtonPageLongboard({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Longboard",
        home: LongboardButtonPanel(
          title: "Longboard",
          engine: BluetoothEngine(device: device),
        ),
        theme: ThemeData.dark());
  }
}

class LongboardButtonPanel extends StatefulWidget {
  //TODO: make portrait only
  const LongboardButtonPanel(
      {Key? key, required this.title, required this.engine})
      : super(key: key);

  final String title;
  final BluetoothEngine engine;

  @override
  State<StatefulWidget> createState() => _LongBoardButtonPanelState();
}

class _LongBoardButtonPanelState extends State<LongboardButtonPanel> {
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
