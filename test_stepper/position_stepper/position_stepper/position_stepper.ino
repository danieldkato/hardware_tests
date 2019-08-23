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
 * last upadted DDK 2019-08-22
 */
 
#define STPR_PIN 6
#define SLP_PIN 9
#define DIR_PIN 8
#define HALL_PIN A0
#define LED_PIN 5

#define NUM_STEPS 200
#define STEP_HALFDELAY_US 1500
#define MICROSTEP 8
#define REVERSE_ROTATION_DEGREES 50
#define HALL_THRESH 1000

String input;
String dbg_msg;
int num_steps;
bool is_num;
//int numSteps = floor((REVERSE_ROTATION_DEGREES/360.0) * NUM_STEPS) * MICROSTEP;
int stpr_powerup_time = 1000;
int stpr_powerdown_time = 1000;
String stepper_state = "RETRACTED";

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

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available()){

    // Get input from host PC:
    input = Serial.readString(); 

    // If user has just pressed 'Enter', rotate to sensor:
    if(input=="\n"){
       rotate_to_sensor();
       dbg_msg = "rotating stepper motor to hall effect sensor.\n";
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
        digitalWrite(DIR_PIN, LOW); // positive -> towards the mouse
        }
      else{
        digitalWrite(DIR_PIN, HIGH); // negative -> away from the mouse      
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
      }
      
    Serial.print("ACK " + dbg_msg);
  }
}


void rotate_one_step(){
  digitalWrite(STPR_PIN, HIGH);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
  digitalWrite(STPR_PIN, LOW);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
}


void rotate_to_sensor(){
  digitalWrite(DIR_PIN, LOW);
  //int hall_val = analogRead(HALL_PIN);
  while(analogRead(HALL_PIN)<HALL_THRESH){
      rotate_one_step(); //how to deal with direction??
      //delay(1);
      //hall_val = analogRead(HALL_PIN);
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
