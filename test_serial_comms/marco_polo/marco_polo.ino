/*Minimal sketch for reading serial input, appending "ACK" 
(for "acknowledge"), then echoing back to computer.*/
String acknowledgeString = " ACK";

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  Serial.println(readLine());
}

String readLine(){
  String inputString="";
  boolean stringComplete=false;
  
  while(stringComplete==false){
    if(Serial.available()){
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
  return inputString;
}

