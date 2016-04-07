"""
Minimal script for uploading a sketch to the Arudino using Python's os.system() method to open a shell and issue the command arduino.exe --upload. 

This script uploads test_upload_cmd.ino to an Arduino. This script then confirms that the upload was successful by opening a serial connection with the Arduino and listening for a simple test message defined in the Arduino sketch. 

One of the things that this made clear is that arduino.exe's upload command takes a REALLY LONG TIME (5-10 sec depending on the length of the sketch) to complete, and that if you open a serial connection from Python using serial.Serial() before arduino.exe completes the upload, then the Arduino will run the last sketch that was successfully uploaded to the board, resulting in the wrong sketch being run. 
"""
import os 
import serial
import time

serialPort = 'COM3'
baudRate = 9600

ArduinoPath = 'C:\Program Files (x86)\Arduino' #the directory from which ardunio.exe --upload will be called
sketchbookPath = 'C:\\Users\\Dank\\Documents\\Arduino_sketches' #my sketchbook directory; this is likely to be different on different computers
sketchPath = '\\hardware_tests\\test_upload_cmd\\' #the path to the sketch within the sketchbook directory; this should be the same between computers
sketchName = 'test_upload_cmd.ino' 
uploadPath = sketchbookPath + sketchPath + sketchName

os.chdir(ArduinoPath)
os.system('arduino --board arduino:avr:uno --port %s \
	--pref sketchbook.path=%s\
	--upload %s' %(serialPort, sketchbookPath, uploadPath))
time.sleep(6) #UPLOADING TAKES A REALLY LONG TIME!! And remember it scales with the length of the sketch 

ser = serial.Serial(serialPort, baudRate, timeout=2) #Instantiate serial object
ser.flushInput() #Immediately flush any stale input
time.sleep(1) #Allow some time for the handshake to complete
print(ser.readline()) #Read data sent by Arduino over serial port
ser.close() #Clean up 