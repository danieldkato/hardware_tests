"""
Minimal script for sending test string to Arduino and reading back echo.
"""
# -*- coding: utf-8 -*-
import serial
import time

print('marco.py start')
testStr = 'marco' #Define test string here

#Initialize serial port connection
connected = False
ser = serial.Serial('COM13',9600,timeout=2)

#Wait to receive signal that handshake is complete
while not connected:
	serin = ser.readline()
	connected = True
	print('Serial port open')
	
#Write a test string; Python 3.4 requires strings to be converted to bytes
#ser.write(bytes(data,'UTF-8'))
ser.write( testStr + '\n' )

#Read echo back from Arduino
print(ser.readline())

#Clean up
ser.close()
print('Done')