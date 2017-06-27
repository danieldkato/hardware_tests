/* Last updated DDK 6/7/16
 *  
 * OVERVIEW: 
 * This sketch constitutes the Arduino-side code for  
 * `get_speaker_spectrogram`, a program for generating a white
 * noise stimulus from an Arduino-controlled speaker, 
 * recording the output through a prepolarized mircrophone,
 * then generating a spectrogram of the speaker output in
 * MATLAB. 
 * 
 * 
 * REQUIREMENTS:
 * This sketch is intended for use with the MATLAB script
 * `get_speaker_spectrogram.m` running on a connected desktop
 * computer. 
 * 
 * The baud rates specified in this sketch and in the desktop-
 * side code must agree. 
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
 * Upload this sketch to an Arduino then run `get_speaker_spectrogram.m`
 * on a connected desktop computer. 
 * 
 * 
 * DESCRIPTION:
 * The parameters of the white noise stimulus - i.e., the 
 * duration, the minimum frequency and the maxmimum frequency 
 * - are decided by the MATLAB script and sent over the serial 
 * connection to the Arduino. The Arduino thus waits to
 * receive three trial parameters before playing the stimulus.
 */

#include <Tone.h>

int spkrPin = 5;

int minFreq;
String minFreqStr;
boolean minFreqRec = false;

int maxFreq;
String maxFreqStr;
boolean maxFreqRec = false;

int preStimDur;
String preStimStr;
boolean preStimRec = false;

int stimDur;
String stimDurStr;
boolean stimDurRec = false;

Tone cueTones[1];

boolean complete = false;

//Initialize pins and receive stimulus parameters:
void setup() {
  // put your setup code here, to run once:

  pinMode(spkrPin, OUTPUT);
  cueTones[0].begin(spkrPin);
  randomSeed(analogRead(4));
  
  Serial.begin(9600);
  delay(2000);

  //Get the pre-stimulus duration from the MATLAB script
  while ( preStimRec == false){
    preStimStr = getLine();
    preStimDur = preStimStr.toInt() * 1000; //remember to convert to milliseconds
    Serial.println("ACK pre-stimulus duration = " + preStimStr + " seconds"); //echo back duration to confirm receipt
    preStimRec = true;
  }

  //Get the stimulus duration from the MATLAB script
  while ( stimDurRec == false){
    stimDurStr = getLine();
    stimDur = stimDurStr.toInt() * 1000; //remember to convert to milliseconds
    Serial.println("ACK stimulus duration = " + stimDurStr + " seconds"); //echo back duration to confirm receipt
    stimDurRec = true;
  }

  //Get the minimum frequency from the MATLAB script
  while ( minFreqRec == false){
    minFreqStr = getLine();
    minFreq = minFreqStr.toInt();
    Serial.println("ACK minimum stimulus frequency = " + minFreqStr + " Hz"); //echo back minimum frequency to confirm receipt
    minFreqRec = true;
  }

  //Get the maximum frequency from the MATLAB script
  while ( maxFreqRec == false){
    maxFreqStr = getLine();
    maxFreq = maxFreqStr.toInt();
    Serial.println("ACK maximum stimulus frequency = " + maxFreqStr + " Hz"); //echo back maxmimum frequency to confirm receipt
    maxFreqRec = true;
  }
}


//Deliver stimulus:
void loop() {
  if( complete == false && Serial.available()){
    // put your main code here, to run repeatedly:
    delay(preStimDur);
    long start = millis();
    long now = millis();
    while ( now - start < stimDur ){
      int freq = random( minFreq, maxFreq);
      cueTones[0].play(freq);
      now = millis(); 
    }
    cueTones[0].stop();
    complete = true;
  }
}


//Function for reading lines (as opposed to individual characters) from serial input buffer
String getLine(){
  String inputString = "";
  boolean lineComplete = false;
  
  while (lineComplete == false){
    if (Serial.available()){
        char inChar = Serial.read();
        if(inChar == '\n'){
          lineComplete = true;
          break; 
        }
        inputString += inChar; 
      }
   }

  return inputString;
}

