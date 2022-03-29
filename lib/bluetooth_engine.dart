import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothEngine {
  final BluetoothDevice device;
  BluetoothConnection? connection;

  BluetoothEngine({required this.device}) {
    BluetoothConnection.toAddress(device.address).then((_connection) {
      connection = _connection;
    });
  }

  Future<bool> sendMessage(Uint8List data) async {
    tryConnecting();
    try {
      connection!.output.add(data);
      await connection!.output.allSent;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> tryConnecting() async {
    if (connection == null || !connection!.isConnected) {
      BluetoothConnection.toAddress(device.address).then((value) {
        connection = value;
        return value.isConnected;
      });
    } else {
      return true;
    }
    return false;
  }
}
