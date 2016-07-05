*Last updated DDK 6/7/17*

##TEST_STEPPER
###OVERVIEW:
This directory contains code for testing Arduino-controlled stepper motors, hall effect sensors, associated input and output pins, and connections in between. This directory includes two Arduino sketches:

* `test_stepper`: sketch for testing the basic function of a stepper, without any feedback from a hall effect sensor.

* `test_stepper_HES`: sketch for testing a stepper with feedback from a hall effect sensor. 


###REQUIREMENTS:
All sketches in this directory require that the Arduino be powered by ~5V. If the Arduino is not powered, the stepper motor will draw too much current and the board will not be detected over the serial port. 


For details, see comments in header of each sketch. 