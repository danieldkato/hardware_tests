"""
Minimal script for sending test string to Arduino and reading back an echo. Use in conjunction with marco_polo.ino running on an Arduino. Execute this script as function from the command line using:

python marco_polo.py '<string>'

where  <string> is a test string to send to the Arduino. The string should be echoed back with an acknowledgement message appended to it. 
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