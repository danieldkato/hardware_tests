/*  test_stepper_HES.ino
 *   
 * /////////////////////////////////////////////////////// 
 * Documentation table of contents:
 * I. OVERVIEW
 * II. REQUIREMENTS
 * III. INSTRUCTIONS
 *  
 * Last updated DDK 2017-08-24
 *  
 * /////////////////////////////////////////////////////// 
 * I. OVERVIEW:
 * 
 * Simple sketch to make a stepper motor repeatedly rotate 
 * back and forth some number of steps. The number of steps 
 * after which the stepper reverses direction is determined 
 * by feedback from a hall effect sensor. Use this sketch to 
 * test that the stepper, the stepper motor driver, the hall 
 * effect sensor, the corresponding input and output pins and 
 * the connections between are working. 
 * 
 * 
 * //////////////////////////////////////////////////////
 * II. REQUIREMENTS:
 * 
 * 1) A stepper motor driver (e.g. Pololu A4988) connected to 
 *    a custom OM2 Arduino shield. The stepper motor driver should
 *    plug into the pins inscribed in the large rectangle printed
 *    on top surface of the OM2. Note that the orientation of the 
 *    stepper driver DOES matter; the driver's VMOT pin should go 
 *    into the pin connected to the OM2 decoupling capacitor. To find 
 *    the VMOT pin on the stepper motor driver, see the stepper motor 
 *    driver wiring diagram at:
 *    
 *    https://www.pololu.com/product/1182
 *    
 *    If necessary, assemble a new OM2 using the wiring diagram at: 
 *    
 *    https://www.dropbox.com/home/Bruno%20Lab%20Share/openmaze_shields?preview=OM2_160703.png
 *    
 * 2) A bipolar stepper motor connected to the OM2 shield. Wires 
 *    from stepper motor should plug into the four OM2 pins adjacent
 *    to the label 'STEPPER'. For details on which wires should go        
 *    to which pins, see the stepper motor driver wiring diagram (link above)
 *    and stepper motor wiring diagram at https://www.pololu.com/product/1205.
 *    
 * 3) An Arduino microcontroller. The OM2 shield should only fit into   
 *    Ardunio one way. 
 * 
 * 4) The Arduino shield MUST be powered by ~5V; the stepper will 
 *    otherwise draw too much current and the Arduino will
 *    not be detected. 
 * 
 * 5) The stepper motor driver must be configured for the microstep resolution 
 *    specified in this sketch. This must be accomplished in hardware, as this
 *    code does not make any provisions for controlling the microstep resolution
 *    programatically. To accomplish this, pull the appropriate combination of 
 *    stepper motor driver pins M1-M3 HIGH by connecting them via jumper 
 *    cable to 5V. See link above for M1-M3 logic levels corresponding
 *    to each microstep resolution.
 * 
 * 6) Hall effect sensor connected to Arduino microcontroller power, ground 
 *    and analog in lines. 
 * 
 * 7) Magnet mounted to stepper motor. 
 *  
 * 
 * /////////////////////////////////////////////////////
 * III. INSTRUCTIONS:
 * 
 * 1) Ensure that the pins specified in this sketch match the
 *    pins connected to the stepper motor and hall effect sensor. 
 * 
 * 2) Ensure that the stepper motor driver is configured for 
 *    he microstep resolution specified in this sketch.
 * 
 * 3) Upload the sketch to the Arduino microcontroller. 
 * 
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
  digitalWrite(DIR_PIN, LOW);
  hall_val = analogRead(HALL_PIN);
  while(hall_val>hall_thresh){
    rotate_one_step(); //how to deal with direction??
    //delay(1);
    hall_val = analogRead(HALL_PIN);
  }
  Serial.println("stepper extended");
}

void back(){
  digitalWrite(DIR_PIN, HIGH);
  //delay(1);
  for(int i = 0; i < numSteps; i++){rotate_one_step();}
  Serial.println("stepper retracted");
}


