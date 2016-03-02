#include <Tone.h>

String inputString="";
boolean stringComplete=false;
int speakerPin=13;
Tone testTones[1];

int once = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(19200);
  
  pinMode(speakerPin,OUTPUT);
  testTones[0].begin(speakerPin);
  
}

void loop() {
  // put your main code here, to run repeatedly:
  serialEvent();
  
  if(stringComplete){

    Serial.println(inputString);
    
    //test that this conditional has been reached by playing tone from Arduino
    testTones[0].play(16000);
    delay(500);
    testTones[0].stop();
    
    inputString="";
    stringComplete=false;
  }
}

void serialEvent(){
  while(Serial.available()){
    char inChar=Serial.read();
    inputString+=inChar;
    if (inChar=='\n'){
      stringComplete=true;
    }
  }
}

