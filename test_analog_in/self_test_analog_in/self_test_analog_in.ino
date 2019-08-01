const int signal_out_pin = 3;
const int period = 2000; // milliseconds
bool state = 0;
int val;
int last_time;
int curr_time;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(signal_out_pin, OUTPUT);
  last_time = millis();
}

void loop() {
  // Get the current time:
  curr_time = millis();

  // Update the state of the output pin if necessary:
  if (curr_time - last_time >= period){
      last_time = curr_time;
      if (state == 0){
          digitalWrite(signal_out_pin, HIGH);
          state = 1;
        }
       else if (state == 1){
          digitalWrite(signal_out_pin, LOW);
          state = 0;          
        }
    }

  // Read the signal on the analog in port:
  val = analogRead(A1);

  // Print the value read on the analog in port:
  Serial.println(val);
}
