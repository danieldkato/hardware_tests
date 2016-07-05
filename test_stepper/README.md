*Last updated DDK 6/7/17*

##TEST_STEPPER
###OVERVIEW:
This directory contains code for testing Arduino-controlled stepper motors, hall effect sensors, associated input and output pins, and connections in between. This directory includes two Arduino sketches:

* `test_stepper`: sketch for testing the basic function of a stepper, without any feedback from a hall effect sensor.

* `test_HES`: sketch for testing the basic function of a hall effect sensor, without using the feedback to constrain the movement of a stepper.

* `test_stepper_HES`: sketch for testing a stepper with feedback from a hall effect sensor. 

For detailed instructions and specific requirements, see comments in header of each sketch. 

###COMMON REQUIREMENTS:
Most of these sketches require that the Arduino library `Stepper` be included in the `library` folder of the Arduino *core* directory (i.e., the one located somewhere like `Program Files` - not to be confused with the `library` folder in the Arduino *sketchbook* directory, which is likely to be somewhere like `My Documents`). `Stepper` is included with most distributions of the Arduino software, so in most cases it is probably already installed.

All sketches in this directory require that the Arduino be powered by ~5V. If the Arduino is not powered, the stepper motor will draw too much current and the board will not be detected over the serial port. 


