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
 * See link for documentation on using Volume library.
 * 
 * The speaker MUST BE CONNECTED TO OUTPUT PIN 5 IF RUNNING ON AN ARDUINO 
 * UNO. If running on a different Arduino board, see https://github.com/connornishijima/arduino-volume1#supported-pins  
 * for supported pins.
 * 
 * There must be a resistor in line between the Arduino output pin 
 * and the speaker input terminal.
 * 
 * 
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
 * 
 * IMPORTANT NOTE: once you've called begin() on a Volume object,
 * you MUST resort the library's vol.dely(), vol.millis(), 
 * vol.micros(), etc. in place of the standard Arduino 
 * timekeeping functions. This is because beginning the Volume
 * object increases the speed of Timer0, which is used for the 
 * standard Arduino timekeeping functions. For more information,
 * see https://github.com/connornishijima/arduino-volume1#limitations
 */

#include <Arduino.h>
#include "Volume.h"

boolean once = false;
int duration = 500;
unsigned long start;
byte volumes[4] = {255, 127, 12, 0};
Volume vol;

void setup() {
  // put your setup code here, to run once:
  randomSeed(analogRead(4));
  vol.begin();
}

void loop(){
    
    vol.noTone();  
    /* ^ This line is here to stop the final call to tone() 
     * at the end of the 'if' block; for some reason it stops 
     * the tone from EVER playing if it's placed inside or 
     * after the 'if' block, but it seems to work properly if 
     * it's called at the beginning of the next pass of loop()
     */
    
    if (once == false){

      // Sweep through four different volumes
      for(int i = 0; i < 4; i++){
        vol.tone(440, volumes[i]);
        vol.delay(duration);
      }

      /* Insert a delay here to show how the standard
       * Arduino delay() function doesn't work properly 
       * once vol.begin() has been called, and that vol.delay()
       * must be called instead
      */
      //delay(3000); // this will wait for only 1/64th as long as the delay specified in the input argument
      vol.delay(3000); // this will wait for the amount of time specified in the input argument
      

      // Play a probe tone to indicate when the delay is done
      vol.tone(440, volumes[0]);
      vol.delay(duration);
    
      once = true;
    }
}
