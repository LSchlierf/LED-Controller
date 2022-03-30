import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothEngine {
  final BluetoothDevice device;
  BluetoothConnection? connection;
  connectionState _state = connectionState.disconnected;
  Future<BluetoothConnection>? _waiting;

  BluetoothEngine({required this.device}) {
    tryConnecting();
  }

  connectionState get state {
    if (_state != connectionState.connecting) {
      _state = connection != null && connection!.isConnected
          ? connectionState.connected
          : connectionState.disconnected;
    }
    return _state;
  }

  bool get isConnected {
    return state == connectionState.connected;
  }

  bool get isConnecting {
    return state == connectionState.connecting;
  }

  bool get isDisconnected {
    return state == connectionState.disconnected;
  }

  Future<bool> sendMessage(Uint8List data) async {
    if (_state != connectionState.connected) {
      if (!await tryConnecting()) return false;
    }
    try {
      connection!.output.add(data);
      await connection!.output.allSent;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> tryConnecting() async {
    if (_state == connectionState.disconnected) {
      _state = connectionState.connecting;
      _waiting = BluetoothConnection.toAddress(device.address).catchError((e) {
        _waiting = null;
        _state = connectionState.disconnected;
      });
      var value = await _waiting!;
      connection = value;
      if (value.isConnected) {
        _state = connectionState.connected;
      } else {
        _state = connectionState.disconnected;
      }
      _waiting = null;
      return value.isConnected;
    } else if (_state == connectionState.connected) {
      return true;
    } else {
      await _waiting;
    }
    return _state == connectionState.connected;
  }
}

enum connectionState {
  disconnected,
  connecting,
  connected,
}
