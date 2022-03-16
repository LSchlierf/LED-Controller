import 'dart:io';

import 'package:led_control/main.dart';
import 'package:path_provider/path_provider.dart';

class DeviceStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    if (!Directory(directory.path + '\\Devices').existsSync()) {
      Directory(directory.path + '\\Devices').createSync();
    }
    return directory.path + '\\Devices';
  }

  static Future<List<String>> get allDevices async {
    final directoryPath = await _localPath;
    final directory = Directory(directoryPath);
    return directory
        .list()
        .map((event) => event.path)
        .map((event) => event.substring(event.lastIndexOf("\\") + 1))
        .map((event) => event.contains("/") ? event.split("/")[1] : event)
        .map((event) => event.split(".")[0])
        .toList();
  }

  static Future<void> storeNewDevice(
      String name, String address, deviceType type) async {
    final String path = await _localPath;
    String entry = address + '\n' + type.index.toString();
    File file = File('$path/$name.txt');
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    file.writeAsStringSync(entry);
  }

  static Future<deviceType?> getDeviceType(String name) async {
    final String path = await _localPath;
    File file = File('$path/$name.txt');
    if (!file.existsSync()) return null;
    return deviceType.values[int.parse(file.readAsLinesSync()[1])];
  }

  static Future<String?> getAddress(String name) async {
    final String path = await _localPath;
    File file = File('$path/$name.txt');
    if (!file.existsSync()) return null;
    return file.readAsLinesSync()[0];
  }

  static Future<void> deleteDevice(String name) async {
    final String path = await _localPath;
    File('$path/$name.txt').deleteSync();
  }
}
