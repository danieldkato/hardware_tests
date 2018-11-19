const int PWM_pin = 3;
const int timerPin = 11; // useful for syncing LED to other stuff
const int on_time = 2000;
const int off_time = 2000;
float duty_cycle = 50;

void setup() {
  // put your setup code here, to run once:
  pinMode(PWM_pin, OUTPUT);
  pinMode(timerPin, OUTPUT);

  // initial 10-ms flash to indicate beginning of script
  digitalWrite(PWM_pin, HIGH);
  digitalWrite(timerPin, HIGH);
  delay(10);
  digitalWrite(PWM_pin , LOW);
  digitalWrite(timerPin, LOW);
  delay(1000);
  
}

void loop() {
  // put your main code here, to run repeatedly:
  analogWrite(PWM_pin, int(floor((duty_cycle/100) * 255)));
  digitalWrite(timerPin, HIGH);
  delay(on_time);
  analogWrite(PWM_pin, LOW);
  digitalWrite(timerPin, LOW);
  delay(off_time);
}
