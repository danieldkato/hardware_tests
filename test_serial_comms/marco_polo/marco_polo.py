"""
Minimal script for sending test string to Arduino and reading back echo.
"""
# -*- coding: utf-8 -*-
import serial
import time
import sys

def marco(inputStr):
	print('marco.py start')
	#testStr = 'marco' #Define test string here

	#Initialize serial port connection
	connected = False
	ser = serial.Serial('COM3',9600,timeout=2)

	#Wait to receive signal that handshake is complete
	while not connected:
		serin = ser.readline()
		connected = True
		print('Serial port open')
		
	#Write a test string; Python 3.4 and greater requires strings to be converted to bytes
	if sys.version_info >= (3, 4):
	    ser.write(bytes(inputStr+'\n','UTF-8'))
	else:
	    ser.write( testStr + '\n' )

	#Read echo back from Arduino
	print(ser.readline())

	#Clean up
	ser.close()
	print('Done')

if __name__ == "__main__":
	import sys
	marco(sys.argv[1])