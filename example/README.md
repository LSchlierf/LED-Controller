# LED Controller example

This Arduino code is an example on how you could implement an LED controller using an ESP-32 to be controlled by the Flutter app.

## Functionality

This project uses an ESP-32 microcontroller to drive an LED strip while enabling Bluetooth remote control by an app. The code is pretty simple. It runs a loop that does two main things:

- Check for Bluetooth input from the app
- Run the animation

Upon detecting Bluetooth input from the app, the ESP-32 updates the mode / speed / brightness, and continues running the animation.

## Hardware setup

### General

The hardware setup isn't too complicated either. All you need is an ESP-32 connected to a WS2812b LED strip with a 470Ω resistor. Add a 1000 μF capacitor across the main power lines and you're done.

### Wiring diagram

Here is a wiring diagram to illustrate the setup:

![Wiring diagram](https://i.imgur.com/rwAGRA5.png)

## Code

### Code constants

At the top of the code, there are three code constants to configure:

```C++
#define LED_COUNT 300
```

This is the number of pixels your WS2812b strip has.

```C++
#define led_pin 27
```

This is the hardware pin on the ESP-32 that is connected to the 'DIN' pin of the LED strip.

```C++
#define effect_length 10
```

This is the length of some of the light effects that I provided. Use a divisor of LED_COUNT for smoother looking animations.

### Disclaimer: Epilepsy warning

I added a strobe light effect as an animated mode.  
This effect might trigger seizures in individuals with photosensitive epilepsy.  
For safety reasons, I have commented out the code that runs the animation for this mode (currently lines 150 - 160). In this state, activating this mode with the companion app will just turn the LEDs off.  
If you are absolutely certain that you want your light setup to support the strobe light effect, you can uncomment these lines.

ONLY USE THIS MODE IF YOU ARE ABSOLUTELY CERTAIN THAT NOBODY WITH PHOTOSENSITIVE EPILEPSY IS PRESENT.

Please be careful!  
Thank you.

## Contact

Please do not hesitate to reach out to me if you need help, have any questions about this project or found an error.  
I can be reached via Email: [LucasSchlierf@gmail.com](mailto:LucasSchlierf@gmail.com)

Cheers :)  
Lucas
