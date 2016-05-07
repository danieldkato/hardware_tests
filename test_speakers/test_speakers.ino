/*
Generate a single white noise stimulus. Use to confirm 
that a speaker, the associated digital out pin and 
the connections in between are working.

Verified working on Build3 and hs05bruno8 as of 160507.

Important note: as of 160507, if running this sketch on 
hs05bruno8 (the Dell T3400 in the room 504), additional 
steps must be taken in order to compile. The computer 
uses a deprecated version of the Tones library that is 
critical for other programs run from that computer. In 
order to make it compatible with this script, open 
Arduino/libraries/Tone/Tone.cpp and change the 
preprocessor directive:

#include <wiring.h>

to

#include <Arduino.h>
*/

#include <Tone.h>

boolean once = false;
int spkrPin = 13;
int duration = 2000;

Tone cueTones[1];

void setup() {
  // put your setup code here, to run once:
  pinMode(spkrPin,OUTPUT);
  cueTones[0].begin(spkrPin);
  randomSeed(analogRead(4));

  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  if ( once == false){
      int start = millis();
      int now = millis();
      while ( now - start < duration ){
        int freq = random( 10000, 20000 );
        cueTones[0].play(freq);
        now = millis();
      }
    }
  cueTones[0].stop();
  once = true;
}
