import serial

port = 'COM3'
baud_rate = 115200
run = True

# Initialize serial port connection:
connected = False
ser = serial.Serial(port, baud_rate, timeout=2)
while not connected:
    serin = ser.readline()
    connected = True


while run:
    cmd = raw_input("Press enter to move stepper or q to quit.")

    if not cmd:
        ser.write([cmd+'\n'])
    elif cmd == 'q':
        run = False
    else:
        print('Invalid input.')

ser.close()