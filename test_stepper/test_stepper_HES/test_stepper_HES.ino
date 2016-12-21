/* Last updated DDK 6/7/16
 *  
 * OVERVIEW:
 * Simple sketch to make a stepper motor repeatedly rotate 
 * back and forth some number of steps. The number of steps 
 * after which the stepper reverses direction is determined 
 * by feedback from a hall effect sensor. Use this sketch to 
 * test that the stepper, the hall effect sensor, the 
 * corresponding input and output pins and the connections 
 * between are working.
 * 
 * 
 * REQUIREMENTS:
 * 1) Stepper motor connected to Arduino microcontroller in 2-pin configuration. 
 * 2) Hall effect sensor connected to Arduino microcontroller power, ground and analog in lines. 
 * 3) Magnet mounted to stepper motor. The magnet should be close enough 
 *    to the hall effect sensor to exploit the sensor's dynamic range
 *    as the motor completes the specified number of steps in either 
 *    direction. 
 * 4) The Arduino MUST be powered by ~5V; the stepper will 
 *    otherwise draw too much current and the Arduino will
 *    not be detected. 
 *  
 * 
 * INSTRUCTIONS:
 * Ensure that the pins specified in this sketch match the
 * pins connected to the stepper motor and hall effect sensor. 
 * Upload the sketch to the Arduino microcontroller. 
 */

#include <Arduino.h>
#include <Stepper.h>

//Declare stepper constants and variables
const int FULLSTP_PER_ROTATION = 200;
const int STP_PIN = 6;
const int DIR_PIN = 8;
const int HALL_PIN = 0;
int stepHalfDelay = 1500; // microseconds
int microstep = 8;
int hall_thresh = 50;
int hall_val = 500;
long period = 2000;
int rotDeg = 50;
int numSteps = floor((rotDeg/360.0) * FULLSTP_PER_ROTATION) * microstep;

void setup() {
  // put your setup code here, to run once:
  pinMode(STP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:

  fwd();
  delay(period/2);
  back();
  delay(period/2);
    
}

void rotate_one_step()
{
  digitalWrite(STP_PIN, HIGH);
  delayMicroseconds( stepHalfDelay / microstep );
  digitalWrite(STP_PIN, LOW);
  delayMicroseconds( stepHalfDelay / microstep );
}

void fwd(){
  digitalWrite(DIR_PIN, HIGH);
  hall_val = analogRead(HALL_PIN);
  while(hall_val>hall_thresh){
    rotate_one_step(); //how to deal with direction??
    //delay(1);
    hall_val = analogRead(HALL_PIN);
  }
  Serial.println("stepper extended");
}

void back(){
  digitalWrite(DIR_PIN, LOW);
  //delay(1);
  for(int i = 0; i < numSteps; i++){rotate_one_step();}
  Serial.println("stepper retracted");
}


