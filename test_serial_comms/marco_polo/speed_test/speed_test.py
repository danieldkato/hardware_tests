"""
Minimal script for sending test string to Arduino and reading back echo.
"""
# -*- coding: utf-8 -*-
import serial
import time
print('marco.py start')

#Initialize parameters
testStr = 'hi' 
duration = 2; 
lineCtr = 0;

#Initialize serial port connection
connected = False
ser = serial.Serial('COM3',19200,timeout=2)

#Wait to receive signal that handshake is complete
while not connected:
	serin = ser.readline()
	connected = True
	print('Serial port open')

#Repeatedly write the test string to the Arduino for the specified duration
start = time.time()
while time.time() - start < duration :	
	
	#Write a test string; Python 3.4 requires strings to be converted to bytes
	ser.write(bytes(testStr+'\n','UTF-8'))

	#Read echo back from Arduino
	print(ser.readline())
	lineCtr += 1
	
#Clean up
print( lineCtr )
ser.close()
print('Done')