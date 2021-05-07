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
#define STEP_HALFDELAY_US 1200
#define MICROSTEP 16
#define REVERSE_ROTATION_DEGREES 50
#define HALL_THRESH 1000

String input;
String dbg_msg;
//int numSteps = floor((REVERSE_ROTATION_DEGREES/360.0) * NUM_STEPS) * MICROSTEP;
int stpr_powerup_time = 150;
int stpr_powerdown_time = 150;
int total_steps = NUM_STEPS * MICROSTEP;


void setup(){
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
void loop(){
  // put your main code here, to run repeatedly:
  if(Serial.available()){

    // Get input from host PC:
    input = Serial.readString(); 

    // If user has just pressed 'f', do a full turn forwards:
    if(input=="f\n"){
       digitalWrite(DIR_PIN, HIGH);
       full_turn();
       dbg_msg = "rotating stepper motor forward.\n";
       }

    // If user has just pressed 'b', do a full turn backwards:
    else if(input=="b\n"){
      digitalWrite(DIR_PIN, LOW); // changed
      full_turn();
      dbg_msg = "rotating stepper motor backward.\n";
      }
          
    // If user quits host PC program, power down stepper coils to avoid overheating:
    else if(input=="q\n"){
      digitalWrite(SLP_PIN, LOW);
      dbg_msg = "powering down coils.\n";
      }
  }
}

// Rotate stepper forward one step:
void rotate_one_step(){
  digitalWrite(STPR_PIN, HIGH);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
  digitalWrite(STPR_PIN, LOW);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
}

void full_turn(){
  for(int i = 0; i < total_steps + 1; i++){
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
