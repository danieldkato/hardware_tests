
/* Last updated DDK 6/22/16 
 *  
 * OVERVIEW: 
 * Simple sketch for setting a stepper's enable pin to LOW. 
 * After running a sketch like test_stepper_HES.ino, the 
 * stepper's enable pin may be left on HIGH even when a 
 * subsequent sketch is uploaded. This can cause the H-bridges to 
 * overheat. Use this sketch to force the enable pin to 
 * LOW in order to ensure that none of the components
 * overheat. 
 *
 * INSTRUCTIONS:
 * Make sure that the ENBL pin specified in this sketch
 * matches the enable pin number specified in the last 
 * sketch to run on the Arduino, then upload to the 
 * microcontroller. 
 */

const int ENBL = 7;

void setup() {
  // put your setup code here, to run once:
  pinMode(ENBL, OUTPUT);
  digitalWrite(ENBL, LOW);
}

void loop() {
  // put your main code here, to run repeatedly:

}
