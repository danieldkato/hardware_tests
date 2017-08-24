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
 * 1) Stepper motor connected to stepper motor driver, e.g. Pololu A4988. 
 * 
 * 2) Arduino microcontroller configured to supply TTL input, logic power,  
 *    and ground to stepper motor driver. This will typically be through
 *    a Arduino shield custom-designed for a stepper motor dirver (e.g., an OM2).
 * 
 * 3) The driver must be configured for the microstep resolution specified 
 *    in this sketch. If the diver is connected to the Arduino through an OM2 
 *    shield, this can be accomplished in hardware; the motor driver pins 
 *    M1-M3 can be pulled HIGH by connecting them via jumper cable to the 
 *    5V rail. See https://www.pololu.com/product/1182 for M1-M3
 *    logic levels corresponding to each microstep resolution.
 * 
 * 4) The Arduino shield MUST be powered by ~5V; the stepper will 
 *    otherwise draw too much current and the Arduino will
 *    not be detected. 
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

const int FULLSTP_PER_ROTATION = 200;
const int STP_PIN = 6;
const int DIR_PIN = 8;
int stepHalfDelay = 1000;
int microstep = 8;
int period = 2000;
int rotDeg = 90;
int numSteps = floor((rotDeg/360.0) * FULLSTP_PER_ROTATION) * microstep;

void setup() {
  // put your setup code here, to run once:
 
  Serial.begin(9600);
  Serial.println(String(numSteps));
  
  pinMode(STP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);

  digitalWrite(DIR_PIN, LOW);
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
  delay(1);
  for(int i = 0; i < numSteps; i++){rotate_one_step(); delay(1);}
  Serial.println("stepper retracted");
}

void back(){
  digitalWrite(DIR_PIN, HIGH);
  delay(1);
  for(int i = 0; i < numSteps; i++){rotate_one_step(); delay(1);}
  Serial.println("stepper retracted");
}
