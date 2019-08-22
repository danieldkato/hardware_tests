import serial
import time

port = 'COM13'
baud_rate = 115200
run = True

# Initialize serial port connection:
connected = False
ser = serial.Serial(port, baud_rate, timeout=5)

while not connected:
    serin = ser.readline()
    connected = True

print("\nEnter an integer number of steps to move, press enter to move stepper to hall effect sensor, or q to quit.\n")

while run:
    txt = raw_input("Enter input: ")

    # Validate input:

    ser.write(txt+'\n')

    print(ser.readline())
    ser.reset_input_buffer()

    if txt is 'q':
        run = False

print("Qutting program.")
ser.close()