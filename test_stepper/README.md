*Last updated DDK 6/7/17*

##TEST_STEPPER
###OVERVIEW:
This directory contains code for testing Arduino-controlled stepper motors, hall effect sensors, associated input and output pins, and connections in between. 


###REQUIREMENTS:
All sketches in this directory require that the Arduino be powered by ~5V. If the Arduino is not powered, the stepper motor will draw too much current and the board will not be detected over the serial port. 


###DESCRIPTION:
This directory includes two programs:
* **test_stepper**: program for testing the basic function of a stepper, without any feedback from a hall effect sensor.

* **test_stepper_HES**: program for testing a stepper with feedback from a hall effect sensor. 
