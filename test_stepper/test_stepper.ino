/*
*Make a stepper rotate some number of steps one time,
independent of the hall effect sensors. Use this to test
that the stepper, the corresponding digital output pins
and the connections between are working.

Verified to work on Build3 160506. NOTE THAT ARDUINO 
MUST BE POWERED BY ~5V; stepper will otherwise draw 
too much current and Arduino will not be detected 
for some reason. 
*/

#include <Arduino.h>
#include <Stepper.h>

int steps = 100; //set the number of steps you want to perform here

//Declare stepper variables
const int MOTOR_STEPS = 200;
const int STPR1_PIN1 = 8;
const int STPR1_PIN2 = 6;
const int STPR1_ENBL = 7;

//Instantiate stepper object
Stepper stpr1(MOTOR_STEPS, STPR1_PIN1, STPR1_PIN2) ;

boolean once = false;

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
  if ( once == false ){

    digitalWrite( STPR1_ENBL, HIGH );
    stpr1.step( steps );
    digitalWrite( STPR1_ENBL, LOW ); 
    
    once = true;
  }
}
