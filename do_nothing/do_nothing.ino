/* A sketch that sets all output pins to LOW. 
 * Upload to an Arduino to make it stop running 
 * all other programs.
*/

const int numPins = 14;

void setup() {
  // put your setup code here, to run once:
  for (int i = 1; i < numPins + 1; i++){
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }
}

void loop() {
  // put your main code here, to run repeatedly:

}
