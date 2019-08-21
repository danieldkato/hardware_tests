/* Last updated DDK 6/7/16
 *  
 * OVERVIEW:
 * This is the Arduino-side code for a simple program that
 * transmits an arbitrary, user-defined test string from 
 * Python to an Arduino microcontroller, then has the Arduino 
 * append an acknowledgement message to the received string 
 * and echo it back to the desktop.
 * 
 * The acknowledgement message can be edited in this sketch.
 * 
 * REQUIREMENTS:
 * This sketch was originally intended for use with the 
 * Python script marco_polo.py running on a connected desktop, 
 * but it will echo any message it receives from any program 
 * as long as the message terminates in a newline ("\n")
 * character.
 * 
 * The baud rate specified in this sketch must match the
 * baud rate specified in the corresponding desktop program.
 * 
 * INSTRUCTIONS:
 * It is not necessary to upload this sketch from the 
 * Arduino ID before running marco_polo.py; the latter
 * will issue a system call to arduino.exe to upload the
 * sketch.
 * 
 * If using in conjunction with a desktop-side program
 * that does not automatically upload this sketch to the
 * Arduino, then this sketch must be uploaded to the board
 * from the Arduino IDE before running the desktop program.
 */
String acknowledgeString = " ACK";

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  Serial.print(readLine());
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
        inputString+=acknowledgeString;
        inputString+="\n DBG\n"; 
        stringComplete=true;
      }
    }
  }
  return inputString;
}

