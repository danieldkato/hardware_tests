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
