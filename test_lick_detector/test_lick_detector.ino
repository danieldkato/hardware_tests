# define LICK_DETECTOR_PIN A1

const int lickThresh = 900;
boolean licking;
int aIn;

void setup() {
  Serial.begin(115200);
  pinMode(LICK_DETECTOR_PIN, INPUT);
}

void loop() {
  licking = checkLicks();
  if (licking){
      Serial.println("Lick detected");
    }
}

boolean checkLicks(){
  aIn = analogRead(LICK_DETECTOR_PIN);
  if( aIn > lickThresh){
    licking = 1;
  } 
  else {
    licking = 0;
    }
  return licking; 
}
