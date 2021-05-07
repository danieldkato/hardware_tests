const int LEDpin = 10;
const int timerPin = 11; // useful for syncing LED to other stuff
const int on_time = 2000;
const int off_time = 2000;

void setup() {
  // put your setup code here, to run once:
  pinMode(LEDpin, OUTPUT);
  pinMode(timerPin, OUTPUT);

  // initial 10-ms flash to indicate beginning of script
  digitalWrite(LEDpin, HIGH);
  digitalWrite(timerPin, HIGH);
  delay(10);
  digitalWrite(LEDpin, LOW);
  digitalWrite(timerPin, LOW);
  delay(1000);
  
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(LEDpin, HIGH);
  digitalWrite(timerPin, HIGH);
  delay(on_time);
  digitalWrite(LEDpin, LOW);
  digitalWrite(timerPin, LOW);
  delay(off_time);
}
