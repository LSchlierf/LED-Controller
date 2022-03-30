import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:led_control/bluetooth_engine.dart';
import 'package:led_control/button_page.dart';
import 'package:led_control/device_storage.dart';
import 'package:led_control/edit_device_page.dart';
import 'package:led_control/main.dart';

class MainPage extends StatefulWidget {
  final String title;
  const MainPage({Key? key, required this.title}) : super(key: key);
  @override
  createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final Map<int, String> _deviceNames = <int, String>{};
  final Map<int, Widget> _deviceWidgets = <int, Widget>{};
  final Map<int, BluetoothEngine> _deviceEngines = <int, BluetoothEngine>{};
  int _deviceID = 0;

  @override
  void initState() {
    super.initState();
    _loadAllDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return EditDevicePage(
                      reloadCallback: _loadAllDevices,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: max(_deviceNames.length * 2 - 1, 0),
        itemBuilder: (context, index) {
          if (index.isOdd) return const Divider();
          return _deviceWidgets.values.elementAt(index ~/ 2);
        },
      ),
    );
  }

  Container _makeDeviceWidget(String deviceName, int id) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
      child: GestureDetector(
        onTap: () => _selectDevice(id),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                deviceName,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletDevice(id),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editDevice(id),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right),
                  onPressed: () => _selectDevice(id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAllDevices() async {
    List<String> deviceNames = await DeviceStorage.allDevices;
    for (String name in deviceNames) {
      if (!_deviceNames.containsValue(name)) {
        setState(() {
          _reloadAllDevices(deviceNames);
        });
        return;
      }
    }
    for (String name in _deviceNames.values) {
      if (!deviceNames.contains(name)) {
        setState(() {
          _reloadAllDevices(deviceNames);
        });
        break;
      }
    }
  }

  void _reloadAllDevices(List<String> names) {
    _deviceEngines.clear();
    _deviceWidgets.clear();
    _deviceNames.clear();
    for (String name in names) {
      setState(() {
        _addTile(name);
      });
    }
  }

  void _addTile(String name) {
    _deviceNames.putIfAbsent(_deviceID, () => name);
    _deviceWidgets.putIfAbsent(
        _deviceID, () => _makeDeviceWidget(name, _deviceID));
    _addEngine(name, _deviceID);
    _deviceID++;
  }

  Future<void> _addEngine(String name, int id) async {
    String? address = await DeviceStorage.getAddress(name);
    BluetoothEngine engine =
        BluetoothEngine(device: BluetoothDevice(address: address!));
    _deviceEngines.putIfAbsent(id, () => engine);
  }

  Future<void> _editDevice(int id) async {
    String deviceName = _deviceNames[id]!;
    deviceType? type = await DeviceStorage.getDeviceType(deviceName);
    String? deviceAddres = await DeviceStorage.getAddress(deviceName);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return EditDevicePage(
            reloadCallback: _loadAllDevices,
            oldDeviceName: deviceName,
            oldDeviceAddress: deviceAddres!,
            oldDeviceType: type!,
          );
        },
      ),
    );
  }

  Future<void> _selectDevice(int id) async {
    String deviceName = _deviceNames[id]!;
    BluetoothEngine engine = _deviceEngines[id]!;
    deviceType? type = await DeviceStorage.getDeviceType(deviceName);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ButtonPanel(title: deviceName, engine: engine, type: type!);
        },
      ),
    );
  }

  Future<void> _deletDevice(int id) async {
    String deviceName = _deviceNames[id]!;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete device'),
          content:
              Text('Are you sure you want to delete the device "$deviceName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                DeviceStorage.deleteDevice(deviceName)
                    .whenComplete(_loadAllDevices);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
