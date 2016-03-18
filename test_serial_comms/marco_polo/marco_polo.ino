/*Minimal sketch for reading serial input, appending "ACK" 
(for "acknowledge"), then echoing back to computer.*/
//#include <Tone.h>

String inputString="";
String acknowledgeString = "ACK";
boolean stringComplete=false;
int speakerPin=13;

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
    inputString="";
    stringComplete=false;
  }
}

void serialEvent(){
  while(Serial.available()){
    char inChar=Serial.read();
    if (inChar!='\n'){
      inputString+=inChar;  
    }
    else {
      inputString+=acknowledgeString+"\n";
      stringComplete=true;
    }
  }
}

