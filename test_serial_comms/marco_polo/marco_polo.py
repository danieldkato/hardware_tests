"""
Last updated DDK 6/7/16

OVERVIEW: 
This is the desktop-side Python script for a simple program that transmits an arbitrary, user-defined test string from Python to an Arduino microcontroller, then has the Arduino append an acknowledgement message to the received string and echo it back to the desktop. The test message is specified in a command line terminal window.

REQUIREMENTS:
This file must be executed in conjunction with marco_polo.ino running on a connected Arduino microcontroller. 

INSTRUCTIONS:
Ensure that the serial port specified in this script matches the serial port connected to the Arduino. In a command line terminal, navigate to this directory and enter the command:

python marco_polo.py "string\n"

where string stands in for an arbitrary, user-defined test string. Note that the string must terminate in a newline ("\n") character. The echoed test message, along with an appended acknowledgement message, should then be displayed in the terminal window. The acknowledgement message can be specified in marco_polo.ino.
"""
# -*- coding: utf-8 -*-
import serial
import time
import sys
import os

#Parameters that might need to changed between computers:
port = 'COM9'
ArduinoPath = 'C:\\Program Files (x86)\\Arduino' #the directory from which arduino.exe will be called in the shell in order to upload the sketch
sketchbookPath = 'C:\\Users\\Dank\\Documents\\Arduino' #the path to my Arduino sketchbook; this will vary substantially between computers
filePath = '\\hardware_tests\\test_serial_comms\\marco_polo\\marco_polo.ino' #the path to the Arduino sketch within my notebook; this should be the same on all computers
uploadPath =  sketchbookPath + filePath

def marco(inputStr):
	
	#Upload sketch to Arduino
	os.chdir(ArduinoPath)
	os.system('arduino.exe --board arduino:avr:uno --port %s \
	--pref sketchbook.path=%s\
	--upload %s'
	%(port , sketchbookPath, uploadPath))
	print('Compiling and uploading sketch...')
	time.sleep(7) #Compiling and uploading takes a long time!
	print('Upload complete.')

	#Initialize serial port connection
	connected = False
	ser = serial.Serial(port, 9600, timeout=2)

	#Wait to receive signal that handshake is complete
	while not connected:
		serin = ser.readline()
		connected = True
		print('Serial port open')
		
	#Write a test string; Python 3.4 and greater requires strings to be converted to bytes
	if sys.version_info >= (3, 4):
	    ser.write(bytes(inputStr+'\n','UTF-8'))
	else:
	    ser.write( inputStr + '\n' )

	#Read echo back from Arduino
	print(ser.readline())

	#Clean up
	ser.close()
	print('Serial port closed')

if __name__ == "__main__":
	import sys
	marco(sys.argv[1])