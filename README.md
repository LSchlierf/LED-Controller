# Flutter LED controller app

[![wakatime](https://wakatime.com/badge/user/ee0b2e88-680b-47cf-ba7c-afd0e1637329/project/7ad04104-14cf-4a65-8aad-b4430038226b.svg)](https://wakatime.com/badge/user/ee0b2e88-680b-47cf-ba7c-afd0e1637329/project/7ad04104-14cf-4a65-8aad-b4430038226b)

This is the repository for my LED-Control flutter app. It allows you to control the lighting setup of something similar to [my longboard lighting project](https://github.com/LSchlierf/Glowboard-Bluetooth).

## Showcase

This is what the app looks like:

| Main Page | Device Settings Page | Control Panel (disconnected) | Control Panel (connected) |
| --- | --- | --- | --- |
![Main page](https://i.imgur.com/heEwVCA.jpeg) | ![settings page](https://i.imgur.com/aT0kZM4.jpeg) | ![disconnected](https://i.imgur.com/htGTRsB.jpeg) | ![connected](https://i.imgur.com/xO44uEt.jpeg) |

You can add your own device by pressing the '+' Button on the main page and specify the Bluetooth Address and device type in the settings page. Once you stored a device, you can click on it on the main page. This takes you to the control panel. Once connected via the 'Connect' Button, all the other Buttons and the slider activate.  
With these you can control the mode that the light setup is displaying, as well as the brightness of the LEDs.

## Functionality

The app uses the [flutter_bluetooth_serial library by edufolly](https://github.com/edufolly/flutter_bluetooth_serial) to communicate with an ESP-32 that is driving an LED strip.  
That may be a setup similar to [my longboard lighting project](https://github.com/LSchlierf/Glowboard-Bluetooth) or a simple ESP-32 running [this code](example/LED-controller.ino).  
The app communicates with the ESP-32 using bluetooth serial. When sending a new command, the app sends an 8-bit integer as a command identifier plus additional integers as data values (e.g. the specific brightness to set).  
I have provided an [example](example/README.md) for the ESP-32 code, however you are welcome to modify it or implement your own device types both for the ESP-32 as well as adding your own types to the flutter app.

## Roadmap

- [x] Basic functionality
- [x] Connection status update and display
- [x] BT address settings
- [x] Support for different device types
- [x] Bluetooth engines as global variables for uninterrupted connection
- [ ] Pause/play button for animated modes
- [ ] Nearby device discovery
- [ ] RGB color selection
- [ ] Refactor control panel code into parent and child classes
- [ ] App Icon

## Contact

Please do not hesitate to reach out to me if you need help, have any questions about this project or found an error.  
I can be reached via Email: [LucasSchlierf@gmail.com](mailto:LucasSchlierf@gmail.com)

Cheers :)  
Lucas
