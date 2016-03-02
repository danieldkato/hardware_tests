# -*- coding: utf-8 -*-
"""
Created on Thu Aug 06 14:10:14 2015

@author: User
"""

import serial
import time

numTrials=10
duration=5
connected=False
ser=serial.Serial('COM19',9600)

#Wait to receive signal that handshake is complete
while not connected:
    serin=ser.readline()
    print(serin)
    connected=True

#Write duration
ser.write(str(duration)+'\n');

for x in xrange(numTrials):
    ser.write('23\n')
    ser.write('34\n')
    ser.write(str(x)+'\n')
    print(ser.readline())
    #print('duration')
    print(ser.readline())
    time.sleep(2)

ser.close()