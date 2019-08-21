#define STPR_PIN 6
#define ENBL_PIN 7
#define DIR_PIN 8
#define HALL_PIN A0

#define NUM_STEPS 200
#define STEP_HALFDELAY_US 1500
#define MICROSTEP 8
#define REVERSE_ROTATION_DEGREES 50
#define HALL_THRESH 50

char input;
int numSteps = floor((REVERSE_ROTATION_DEGREES/360.0) * NUM_STEPS) * MICROSTEP;
int stpr_powerup_time = 150;
int stpr_powerdown_time = 200;
String stepper_state = "RETRACTED";

void setup() {
  // put your setup code here, to run once:

  // Enable serial connection:
  Serial.begin(115200);
  
  // Enable output pins:
  pinMode(STPR_PIN, OUTPUT);
  pinMode(ENBL_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(HALL_PIN, INPUT);

  // Initialize stepper in disabled state:
  digitalWrite(ENBL_PIN, LOW);
  delay(200);
  digitalWrite(ENBL_PIN, HIGH);
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available()){
    input = Serial.read(); // just to clear the buffer

    if(input=='\n'){

      if(stepper_state == "RETRACTED"){
        rotate_to_sensor();
        }
      else if(stepper_state == "EXTENDED"){
        rotate_back();
        }
      
      }
    }
}



void rotate_to_sensor(){
  digitalWrite(ENBL_PIN, LOW);
  delay(stpr_powerup_time);
    
  digitalWrite(DIR_PIN, LOW);
  //int hall_val = analogRead(HALL_PIN);
  while(analogRead(HALL_PIN)>HALL_THRESH){
      rotate_one_step(); //how to deal with direction??
      //delay(1);
      //hall_val = analogRead(HALL_PIN);
  }
  Serial.println("stepper extended");
  stepper_state  = "EXTENDED";
  
  delay(stpr_powerdown_time);
  digitalWrite(ENBL_PIN, HIGH);
}

void rotate_one_step()
{
  digitalWrite(STPR_PIN, HIGH);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
  digitalWrite(STPR_PIN, LOW);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
}

void rotate_back(){
  digitalWrite(ENBL_PIN, LOW);
  delay(stpr_powerup_time);
  
  digitalWrite(DIR_PIN, HIGH);
  //delay(1);
  for(int i = 0; i < numSteps; i++){rotate_one_step();}
  Serial.println("stepper retracted");
  stepper_state = "RETRACTED";

  delay(stpr_powerup_time);
  digitalWrite(ENBL_PIN, HIGH);
}
