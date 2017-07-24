/* Minimal sketch for testing the use of Python's os.system() 
 *  method to open a shell and issue the command arduino.exe
 *  --upload in order to upload a sketch to the Arudino 

 * This sketch just issues a simple test message once it's  
 * been uploaded just to confirm to the computer that the
 * upload was successful.

 * One of the things that this made clear is that 
 * arduino.exe's upload command takes a REALLY LONG TIME 
 * (5-10 sec) to complete, and that if you open a serial 
 * connection from Python using serial.Serial() before 
 * arduino.exe completes the upload, then the Arduino will 
 * run the last sketch that was successfully uploaded to the 
 * board, resulting in the wrong sketch being run. */
boolean once = false;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  if ( once == false ){
    Serial.println("check it out 10003");
    once = true;
  }
}
