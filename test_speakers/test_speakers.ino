/*
Generate a single white noise stimulus. Use to confirm 
that speaker, associated digital out pin and connections 
are working.
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
