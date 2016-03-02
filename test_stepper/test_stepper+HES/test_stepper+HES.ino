#include <Arduino.h>
#include <Stepper.h>

//Declare stepper constants and variables
const int MOTOR_STEPS = 200;
const int STPR1_PIN1 = 8;
const int STPR1_PIN2 = 6;
const int STPR1_ENBL = 7;
const int HALL_PIN = 1;
int hall_thresh = 50;
int hall_val = 500;
int stepCCW = -20;
long period = 2000;

//Instantiate stepper object
Stepper stpr1(MOTOR_STEPS, STPR1_PIN1, STPR1_PIN2) ;

void setup() {
  // put your setup code here, to run once:
  pinMode(STPR1_PIN1, OUTPUT);
  pinMode(STPR1_PIN2, OUTPUT);
  pinMode(STPR1_ENBL, OUTPUT);
  digitalWrite(STPR1_ENBL, LOW);
  stpr1.setSpeed(100);
}

void loop() {
  // put your main code here, to run repeatedly:

  stpr1Fwd();
  delay(period/2);
  stpr1Back();
  delay(period/2);
    
}

void stpr1Fwd(){
  digitalWrite(STPR1_ENBL, HIGH);
  delay(100);
  hall_val = analogRead(HALL_PIN);
  while ( hall_val > hall_thresh) {
    stpr1.step(1);
    delay(1);  // slight delay after movement to ensure proper step before next
    hall_val = analogRead(HALL_PIN);
  }
}

void stpr1Back(){
  stpr1.step(stepCCW);
  delay(200);
  digitalWrite(STPR1_ENBL, LOW);
}


