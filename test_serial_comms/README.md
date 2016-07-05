*Last updated DDK 6/7/16*

##TEST_SERIAL_COMMS

###OVERVIEW:
This directory contains scripts for testing the serial connection between a desktop computer and an Arduino microcontroller. Use to aid in testing system performance, diagnosing bugs, and developing other programs.

This directory includes the following programs:

* `test_serial_port` : A minimal sketch that does nothing. This is simply meant to be uploaded to an Arduino to confirm that the TX and RX LEDs on the boad are working appropriately.  

* `marco_polo`: A simple Python program that transmits a string to an Arduino, then has the Arduino append an acknowledgement message to the orignial then echo it back to the desktop. The test message is specified in a command line terminal window. 

For details, see each program's `README.md` files and header comments for each file. 
