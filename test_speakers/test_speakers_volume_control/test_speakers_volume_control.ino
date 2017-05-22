/* Last updated DDK 5/22/17
 * 
 * OVERVIEW:
 * Play a pure tone at four decreasing volume steps (1 sec each) 
 * using the Arduino Volume library. Use this sketch to confirm that 
 * a speaker, the associated digital out pin, and the connections in 
 * between are working, and that the system is compatible with the 
 * Arduino Volume library.
 * 
 * 
 * REQUIREMENTS:
 * This sketch requires the Arduino Volume library by Connor Nishijima.
 * This library can be downloaded using the Arduino IDE's Library Manager 
 * or cloned or downloaded directly from https://github.com/connornishijima/arduino-volume1.git
 * 
 * The speaker MUST BE CONNECTED TO OUTPUT PIN 5 IF RUNNING ON AN ARDUINO 
 * UNO. If running on a different Arduino board, see https://github.com/connornishijima/arduino-volume1#supported-pins  
 * for supported pins.
 * 
 * There must be a resistor in line between the Arduino output pin 
 * and the speaker input terminal.
 * 
 * As of 160507, if running this sketch on hs05bruno8 
 * (the Dell T3400 in the room 504), additional steps must
 * be taken in order to compile. The computer uses a 
 * deprecated version of the Tones library that is critical
 * for other programs run on that computer. In order to make
 * it compatible with this script, open  
 * 
 * Arduino/libraries/Tone/Tone.cpp
 * 
 * and change the preprocessor directive:
 * 
 * #include <wiring.h>
 * 
 * to
 * 
 * #include <Arduino.h>
 * 
 * 
 * INSTRUCTIONS:
 * Ensure that the speaker is connected to a supported pin (pins 5 or 6
 * for an Arduino Uno). Upload to the Arduino microcontroller. 
 * 
 * 
 * TODO:
 * As of 170523, this doesn't seem to work great at
 * lower volumes - discrete pulses are clearly 
 * discernible.
 */

#include <Arduino.h>
#include "Volume.h"

boolean once = false;
int duration = 1000;
unsigned long start;
Volume vol;

void setup() {
  // put your setup code here, to run once:
  randomSeed(analogRead(4));
  vol.begin();
}

void loop(){
    byte volumes[4] = {255, 127, 12, 0};
    if (once == false){
      for(int i = 0; i < 4; i++){
        vol.tone(440, volumes[i]);
        vol.delay(duration);
      }
    once = true;
    }
}
