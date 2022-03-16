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

  void tryConnecting() {
    if (connection == null || !connection!.isConnected) {
      BluetoothConnection.toAddress(device.address).then((_connection) {
        connection = _connection;
      });
    }
  }
}
