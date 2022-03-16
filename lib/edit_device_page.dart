import 'package:flutter/material.dart';
import 'package:led_control/device_storage.dart';
import 'package:led_control/main.dart';

class EditDevicePage extends StatefulWidget {
  const EditDevicePage(
      {Key? key,
      required this.reloadCallback,
      this.oldDeviceAddress,
      this.oldDeviceName,
      this.oldDeviceType})
      : super(key: key);

  final Function reloadCallback;
  final String? oldDeviceName;
  final String? oldDeviceAddress;
  final deviceType? oldDeviceType;

  @override
  createState() => EditDevicePageState();
}

class EditDevicePageState extends State<EditDevicePage> {
  String _newDeviceName = '';
  String _newDeviceAddress = '';
  deviceType _newDeviceType = deviceType.ledController;
  bool _isName = false;
  bool _isAddress = false;
  bool _anyChange = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.oldDeviceName != null) {
      _newDeviceName = widget.oldDeviceName!;
      _nameController.text = _newDeviceName;
      _isName = true;
    }
    if (widget.oldDeviceAddress != null) {
      _newDeviceAddress = widget.oldDeviceAddress!;
      _addressController.text = _newDeviceAddress;
      _isAddress = true;
    }
    if (widget.oldDeviceType != null) {
      _newDeviceType = widget.oldDeviceType!;
    }
  }

  @override
  void deactivate() {
    _newDeviceName = _nameController.value.text;
    _newDeviceAddress = _addressController.value.text;
    if (_anyChange && _isAddress && _isName) {
      if (widget.oldDeviceName != null) {
        DeviceStorage.deleteDevice(widget.oldDeviceName!).then((value) {
          DeviceStorage.storeNewDevice(
                  _newDeviceName, _newDeviceAddress, _newDeviceType)
              .then((value) => widget.reloadCallback.call());
        });
      } else {
        DeviceStorage.storeNewDevice(
                _newDeviceName, _newDeviceAddress, _newDeviceType)
            .then((value) => widget.reloadCallback.call());
      }
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit device configuration'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              style: const TextStyle(
                fontSize: 20,
              ),
              controller: _nameController,
              decoration: InputDecoration(
                errorText: _isName ? null : 'Name is required',
                border: const OutlineInputBorder(),
                hintText: 'Enter a name',
              ),
              onChanged: (value) {
                setState(() {
                  _isName = value.trim().isNotEmpty;
                  _anyChange = true;
                });
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              style: const TextStyle(
                fontSize: 20,
              ),
              controller: _addressController,
              decoration: InputDecoration(
                errorText: _isAddress ? null : 'Address is required',
                border: const OutlineInputBorder(),
                hintText: 'Enter an address',
              ),
              onChanged: (value) {
                setState(() {
                  _isAddress = value.trim().isNotEmpty;
                  _anyChange = true;
                });
              },
            ),
          ),
          const Divider(),
          const Text(
            'Device Type:',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          DropdownButton(
              value: _newDeviceType,
              items: deviceType.values
                  .map<DropdownMenuItem<deviceType>>((e) =>
                      DropdownMenuItem<deviceType>(
                          value: e,
                          child:
                              Text(e.toString().split(".")[1].toUpperCase())))
                  .toList(),
              onChanged: (deviceType? newValue) {
                _anyChange = true;
                setState(() {
                  _newDeviceType = newValue!;
                });
              })
        ],
      ),
    );
  }
}
