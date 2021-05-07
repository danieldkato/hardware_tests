import serial
import time

port = 'COM7'
baud_rate = 115200
run = True

# Initialize serial port connection:
connected = False
ser = serial.Serial(port, baud_rate, timeout=5)

while not connected:
    serin = ser.readline()
    connected = True

print("\nEnter f to rotate stepper full turn forward, enter b to rotate stepper full turn backwards, or press q to quit.\n")

while run:
    txt = raw_input("Enter input: ")

    # Validate input:

    ser.write(txt+'\n')

    #print(ser.readline())
    #ser.reset_input_buffer()

    if txt is 'q':
        run = False

print("Qutting program.")
ser.close()


def get_valid_input():
	txt = raw_input("Emter input: ")
	txt_decoded = txt.decode('utf-8', 'ignore')
	
	if txt is not '\f\n' and txt is not 'b\n' and txt is not 'q\n':
		print("\nInvalid input. Please enter f to rotate forward, b to rotate backward, or press q to quit.\n")
		get_valid_input()
		
	return txt