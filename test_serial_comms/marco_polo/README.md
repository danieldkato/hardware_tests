*Last updated DDK 6/7/16*

##MARCO_POLO

###OVERVIEW
This directory contains files for a simple program that transmits an arbitrary, user-defined test string from Python to an Arduino microcontroller, then has the Arduino append an acknowledgement message to the received string and echo it back to the desktop. The test message is specified in a command line terminal window.

###REQUIREMENTS:
* `python` >=2.7
* `pyserial` python serial port extension, available at https://pypi.python.org/pypi/pyserial

This directory should include the following files:
* `marco_polo.py`
* `marco_polo.ino`

The baud rates specified by `marco_polo.py` and `marco_polo.ino` must be in agreement.

###INSTRUCTIONS
Ensure that the serial port specified in `marco_polo.py` matches the serial port connected to the Arduino. In a command line terminal, navigate to this directory and enter the command:

    python marco_polo.py "string\n"

where `string` stands in for an arbitrary, user-defined test string. Note that the string must terminate in a newline (`"\n"`) character. The echoed test message, along with an appended acknowledgement message, should then be displayed in the terminal window. The acknowledgement message can be specified in `marco_polo.ino`.

Note that `marco_polo.ino` does not need to be uploaded from the Arduino IDE before running `marco_polo.py`; the latter will issue a system call to `arduino.exe` to upload the sketch. 
