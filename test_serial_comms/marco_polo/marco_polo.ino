/*Minimal sketch for reading serial input, prepending "ACK" 
(for "acknowledge"), then echoing back to computer.*/
//#include <Tone.h>

String inputString="ACK ";
boolean stringComplete=false;
int speakerPin=13;
//Tone testTones[1];

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  
  pinMode(speakerPin,OUTPUT);
  //testTones[0].begin(speakerPin);
}

void loop() {
  // put your main code here, to run repeatedly:
  serialEvent();
  
  if(stringComplete){

    Serial.println(inputString);
    
    //test that this conditional has been reached by playing tone from Arduino
    /*
    testTones[0].play(16000);
    delay(500);
    testTones[0].stop();
    */
    
    inputString="ACK ";
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

