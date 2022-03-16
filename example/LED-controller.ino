#include <BluetoothSerial.h>
#include <Adafruit_NeoPixel.h>

//adjust the following values to fit your setup:

//the length of your ws2812b strips in pixels:
#define LED_COUNT 36

//the arduino pin the LEDS are connected to:
#define led_pin 27

//the length of the animated strips
#define effect_length 6

//adjust the above values to fit your setup

/*
commands:
00: set mode
01: speed up
02: slow down
04: set speed
05: set brightness
*/
int tempo[] = {0, 20, 20, 30, 40, 50};
int tempoincrement[] = {0, 3, 3, 3, 3, 5};
int last = LED_COUNT - 1;
int length = effect_length - 1;
int mode, lasttime, timepassed, pixel;
float increment = 65536 / LED_COUNT;
bool direction;
uint16_t color;
uint32_t colorbuf;
BluetoothSerial Bluetooth;
Adafruit_NeoPixel strip(LED_COUNT, led_pin, NEO_GRB + NEO_KHZ800);

void setup() {
  Bluetooth.begin("LED-Controller");
  lasttime = millis();
  strip.begin();
}

void loop() {
  checkbluetooth();
  checktime();
}

void checkbluetooth() {
  if(Bluetooth.available()){
    switch(Bluetooth.read()){

      case 0: //new mode
        mode = Bluetooth.read();
        break;

      case 1: //speed up
        tempo[mode] = max(0, (tempo[mode] - tempoincrement[mode]));
        break;

      case 2: //slow down
        tempo[mode] += tempoincrement[mode];
        break;

      case 4: //new speed
        tempo[mode] = gettempo(Bluetooth.read());
        break;

      case 5: //brightness
        strip.setBrightness(Bluetooth.read());
        break;

    }
  }
}

void checktime() {
  timepassed = millis() - lasttime;
  if(timepassed > tempo[mode]){
    runanimation();
    lasttime = millis();
  }
}

void runanimation() {
  strip.clear();
  switch (mode) {

    case 0: //off

      break;

    case 1: //rainbow 1
      color += 182;
      for(int i = 0; i < LED_COUNT; i++){
        colorbuf = strip.ColorHSV((color + (i * increment)));
        strip.setPixelColor(i, colorbuf);
      }
      break;

    case 2: //rainbow 2
      color += 182;
      strip.fill(strip.ColorHSV(color));
      break;

    case 3: //bouncing strip
      color += 182;
      colorbuf = strip.ColorHSV(color);
      if (direction) {
        pixel++;
        if ((pixel + length) > last - 1) {
          direction = false;
        }
      }
      else {
        pixel--;
        if (pixel < 1) {
          direction = true;
        }
      }
      strip.fill(colorbuf, pixel, effect_length);
      break;

    case 4: //strobe light
      color++;
      if(color > 23) {
        color = 0;
      }
      if((color%6 == 0) || ((color - 2)%6 == 0)) {
        strip.fill(strip.Color(255, 255, 255));
      }
      break;

    case 5: //fire brigade lights
      pixel++;
      if(pixel >= LED_COUNT){
        pixel = 0;
      }
      for(int i = 0; i < effect_length; i++){
        int pos = pixel + i;
        if(pos >= LED_COUNT){
          pos -= LED_COUNT;
        }
        strip.setPixelColor(pos, 0, 0, 255);
        pos += LED_COUNT / 2;
        
        if(pos >= LED_COUNT){
          pos -= LED_COUNT;
        }
        strip.setPixelColor(pos, 0, 0, 255);
      }

      break;

    default:

      mode = 0;
      runAnimation();

      break;
      
  }
  strip.show();
}

int gettempo(int val) {
  return val;
}
