/*
 * Use this sketch in conjunction with record_speakers.m to generate 
 * a white noise stimulus and analyze the spectral content of the signal 
 * put out by the speakers.
 * 
 * The only things that need to be set by the user in this sketch are the 
 * HW pins; stimulus parameters will be provided by the MATLAB script.
 */

#include <Tone.h>

int spkrPin = 13;

int minFreq;
String minFreqStr;
boolean minFreqRec = false;

int maxFreq;
String maxFreqStr;
boolean maxFreqRec = false;

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

  //Get the stimulus duration from the MATLAB script
  while ( stimDurRec == false){
    stimDurStr = getLine();
    stimDur = stimDurStr.toInt() * 1000; //remember to convert to milliseconds
    Serial.println(stimDurStr); //echo back duration to confirm receipt
    stimDurRec = true;
  }

  //Get the minimum frequency from the MATLAB script
  while ( minFreqRec == false){
    minFreqStr = getLine();
    minFreq = minFreqStr.toInt();
    Serial.println(minFreqStr); //echo back minimum frequency to confirm receipt
    minFreqRec = true;
  }

  //Get the maximum frequency from the MATLAB script
  while ( maxFreqRec == false){
    maxFreqStr = getLine();
    maxFreq = maxFreqStr.toInt();
    Serial.println(maxFreqStr); //echo back maxmimum frequency to confirm receipt
    maxFreqRec = true;
  }
}


//Deliver stimulus:
void loop() {
  if( complete == false ){
    // put your main code here, to run repeatedly:
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

