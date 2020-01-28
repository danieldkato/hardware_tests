/* Use this sketch to interactively position a stepper motor 
 * via a serial port connection with a host PC. Use the host PC 
 * to issue commands to the Arduino. All commands sent over the 
 * serial connection must end in '\n' (a newline character). This 
 * sketch accepts 3 types of commands:
 * 
 * 1) An integer: moves the stepper the specified number of steps 
 * to move the stepper. Positive moves the stepper towards the 
 * mouse's face, negative moves it in the opposite direction. 
 * 
 * 2) An empty string (terminated with '\n'): this will advance
 * the stepper to the hall effect sensor.
 * 
 * 3) q: powers down the stepper motor coils; use to prevent 
 * overheating and/or when quitting the host PC program. 
 * 
 * Note that it is up to the host PC program to do all input
 * validation.
 * 
 * last upadted DDK 2020-01-27
 */
 
#define STPR_PIN 6
#define SLP_PIN 9
#define DIR_PIN 8
#define HALL_PIN A0
#define LED_PIN 5
#define ENBL_PIN 7 // not actually used with current board as of 2020-01-13

#define NUM_STEPS 200
#define STEP_HALFDELAY_US 1100
#define MICROSTEP 16
#define REVERSE_ROTATION_DEGREES 50
#define HALL_THRESH 1000

String input;
String dbg_msg;
bool is_num;
int num_steps;
//int numSteps = floor((REVERSE_ROTATION_DEGREES/360.0) * NUM_STEPS) * MICROSTEP;
int last_extension_num_steps;
int stpr_powerup_time = 150;
int stpr_powerdown_time = 150;
String stepper_state = "RETRACTED";
bool steps_to_sensor_counted = 0;
int steps_to_sensor;
bool step_complete;

void setup() {
  // put your setup code here, to run once:

  // Enable serial connection:
  Serial.begin(115200);
  
  // Enable output pins:
  pinMode(STPR_PIN, OUTPUT);
  pinMode(SLP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(HALL_PIN, INPUT);

  // Initialize stepper in disabled state:
  digitalWrite(SLP_PIN, HIGH);
  delay(200);

  // Turn on IR LED:
  digitalWrite(LED_PIN, HIGH);
}


// Main loop:
void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available()){

    // Get input from host PC:
    input = Serial.readString(); 

    // If user has just pressed 'Enter', rotate to sensor:
    if(input=="\n"){
       digitalWrite(DIR_PIN, HIGH);
       s_setup();
       dbg_msg = "rotating stepper motor to hall effect sensor.\n";
       }

    // If user has just pressed 'b', retract stepper by same number of steps it advanced:
    else if(input=="b\n"){
      digitalWrite(DIR_PIN, LOW); // changed
      s_finish();
      dbg_msg = "rotating stepper motor back same number of steps as it moved forward, " + String(last_extension_num_steps) + " steps.\n";
      }
          
    // If user quits host PC program, power down stepper coils to avoid overheating:
    else if(input=="q\n"){
      digitalWrite(SLP_PIN, LOW);
      dbg_msg = "powering down coils.\n";
      }
    
    // Else, asssume the user has entered a number and rotate the requested 
    // number of steps (will have to validate input on host PC side)
    else {
      
      // Convert number of steps to int:
      num_steps = input.toInt();

      // Set the direction of the stepper:
      if(num_steps>0){
        digitalWrite(DIR_PIN, HIGH); // positive -> towards the mouse // changed
        }
      else{
        digitalWrite(DIR_PIN, LOW); // negative -> away from the mouse // changed     
      }

      //Rectify: 
      num_steps = abs(num_steps);
      
      // Rotate the requested number of steps: 
      if(num_steps>0){        
        for (int n = 0; n < num_steps; n++){
          rotate_one_step();
          delay(1); // increases accuracy
          }
        };
      dbg_msg = input;      
      last_extension_num_steps = num_steps;
      }
      
    Serial.print("ACK " + dbg_msg);
  }
}


// Analagous to StimPeriod::s_setup() in MultiSens/States.cpp
void s_setup(){
  trigger_stepper();
  }


// Analagous to trigger_stepper() in MultiSens/States.cpp
void trigger_stepper(){
    rotate_to_sensor();
  }


// Rotate stepper forward one step:
void rotate_one_step(){
  digitalWrite(STPR_PIN, HIGH);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
  digitalWrite(STPR_PIN, LOW);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
}


// Rotate stepper forward to Hall effect sensor:
void rotate_to_sensor(){
    // if steps haven't been counted yet, count the number of steps to HES
    if(steps_to_sensor_counted == 0){
        steps_to_sensor = 0;
        Serial.print("steps being counted");
        while(analogRead(HALL_PIN)<HALL_THRESH){
          rotate_one_step(); //how to deal with direction??
          steps_to_sensor = steps_to_sensor + 1;
        }
        steps_to_sensor_counted = 1;
    // if steps to HES have already been counted, don't count again; this will make stepper go faster
    } else{
          while(analogRead(HALL_PIN)<HALL_THRESH){
            rotate_one_step(); 
        }
    }
    last_extension_num_steps = steps_to_sensor;
}


// Analogous to Stim_period::s_finish() in States.cpp
void s_finish(){
  rotate_back();
}


// Rotate stepper back as many steps as it previously rotated forward:
void rotate_back(){
  for(int i = 0; i < last_extension_num_steps + 1; i++){
    int x = analogRead(A1); 
    // Above line is only included to ensure 
    // that the stepper rotates backwards with 
    // approx. the same speed with which it rotates 
    // forward; without the above line, the stepper 
    // rotates forwards slower because it has to read
    // from the Hall effect sensor between each step 
    // check whether it's reached the HES yet. 

    rotate_one_step();
    }
}

/*
void rotate_back(){
  digitalWrite(SLP_PIN, HIGH);
  delay(stpr_powerup_time);
  
  digitalWrite(DIR_PIN, HIGH);
  //delay(1);
  for(int i = 0; i < numSteps; i++){rotate_one_step();}
  Serial.println("stepper retracted");
  stepper_state = "RETRACTED";

  delay(stpr_powerup_time);
  digitalWrite(SLP_PIN, LOW);
}
*/
