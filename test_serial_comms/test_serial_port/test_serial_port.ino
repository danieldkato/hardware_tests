const int STPR1_ENBL = 7;
const int SOL_ENBL = 3;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(STPR1_ENBL, OUTPUT);
  pinMode(SOL_ENBL,OUTPUT);
  digitalWrite(STPR1_ENBL, LOW);
  digitalWrite(SOL_ENBL, LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
  
}
