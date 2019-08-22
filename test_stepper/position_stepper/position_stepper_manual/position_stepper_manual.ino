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
int num_steps;
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
    input = Serial.readString(); // just to clear the buffer
    Serial.print("ACK " + input);
    
    // If user has just pressed 'Enter', rotate to sensor:
    if(input=="\n"){rotate_to_sensor();}
    
    // If user quits host PC program, power down stepper coils to avoid overheating:
    else if(input=="q\n"){digitalWrite(SLP_PIN, LOW);}
    

      
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
      for (int n = 0; n < num_steps; n++){rotate_one_step();}
      };
    }

}


char readline(){
  bool done = false;
  char msg;
  char curr;
  
  while(~done){
    if(Serial.available()){curr = Serial.read();}

    // Stop when a newline character has been reached; 
    if(curr=='\n'){
      return msg;
      }
    }

    // Update msg:
    msg = msg + curr;
}


void rotate_one_step(){
  digitalWrite(STPR_PIN, HIGH);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
  digitalWrite(STPR_PIN, LOW);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
}


void rotate_to_sensor(){
  digitalWrite(SLP_PIN, HIGH);
  delay(stpr_powerup_time);
    
  digitalWrite(DIR_PIN, LOW);
  //int hall_val = analogRead(HALL_PIN);
  while(analogRead(HALL_PIN)<HALL_THRESH){
      rotate_one_step(); //how to deal with direction??
      //delay(1);
      //hall_val = analogRead(HALL_PIN);
  }
  Serial.println("stepper extended");
  stepper_state  = "EXTENDED";
  
  delay(stpr_powerdown_time);
  digitalWrite(SLP_PIN, LOW);
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
