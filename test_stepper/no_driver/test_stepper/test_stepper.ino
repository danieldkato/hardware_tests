/* test_stepper.ino
 *  
 *  ////////////////////////////////////////////////////////
 *  Documentation table of contents:
 * I. OVERVIEW
 * II. REQUIREMENTS
 * III. INSTRUCTIONS
 *  
 * Last updated DDK 2017-08-24
 *  
 * ///////////////////////////////////////////////////////// 
 * I. OVERVIEW:
 * 
 * Simple sketch to make a stepper motor rotate some number 
 * of steps once, independent of any hall effect sensors.
 * Use this to test that the stepper and all associated digital 
 * output pins and the connections are working.
 * 
 * Verified to work on Build3 160506.
 * 
 * 
 * ////////////////////////////////////////////////////////////
 * II. REQUIREMENTS:
 * 
 * 1) Bipolar stepper motor connected to H-bridge (e.g. L293D) in 
 *    2-pin configuration. For instructions on how to achieve this, see: 
 *    http://www.tigoe.net/pcomp/code/circuits/motors/stepper-motors/
 * 
 * 2) Arduino microcrontroller configured to control H-bridge. See
 *    link above for detailed instructions on circuit configuration. 
 * 
 * 3) The Arduino MUST be powered by ~5V; the stepper will otherwise 
 *    draw too much current and the Arduino will not be detected. 
 *  
 * 
 * ////////////////////////////////////////////////////////////
 * III. INSTRUCTIONS:
 * 
 * Ensure that the pins specified in this sketch match the
 * pins connected to the stepper motor. Upload the sketch to
 * the Arduino microcontroller. 
 * 
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
