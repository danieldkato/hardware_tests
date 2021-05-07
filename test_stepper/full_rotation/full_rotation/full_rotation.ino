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

int total_steps = NUM_STEPS * MICROSTEP;
bool complete = 0;
bool dir = 0; // 0: backwards, 1: forwards

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

  // Set direction:
  if (dir==1){
    digitalWrite(DIR_PIN, HIGH);
    }
  else if(dir==0){
    digitalWrite(DIR_PIN, LOW);
    }
}

void loop() {
  // put your main code here, to run repeatedly:
  if(complete==0){
    for(int i = 0; i < total_steps + 1; i++){
      rotate_one_step();
      }
    complete = 1;
    } 
}

void rotate_one_step(){
  digitalWrite(STPR_PIN, HIGH);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
  digitalWrite(STPR_PIN, LOW);
  delayMicroseconds( STEP_HALFDELAY_US / MICROSTEP );
}
