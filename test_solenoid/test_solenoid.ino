#define SOLENOID_PIN 3

const int closed_time = 50; // in milliseconds
const int open_time = 1000; // in milliseconds

void setup() {
  pinMode(SOLENOID_PIN, OUTPUT);
  digitalWrite(SOLENOID_PIN, LOW); // initialize to low (closed)
}

void loop() {
    digitalWrite(SOLENOID_PIN, HIGH);
    delay(open_time);
    digitalWrite(SOLENOID_PIN, LOW);
    delay(closed_time);
}
