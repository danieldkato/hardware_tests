*Last updated DDK 6/7/16*

##GET_SPEAKER_SPECTROGRAM

###OVERVIEW:
This directory contains code for generating a single white noise stimulus from an Arduino-controlled speaker, recording the output through a prepolarized microphone, then generating a spectrogram of the speaker output in MATLAB. Use this program to assess how much power a potential stimulus speaker generates in the hearing range of mice. 


###REQUIREMENTS:
####Stimulus design considerations:
Mice can hear frequencies ranging from ~2-80 kHz (see Koay, Heffner and Heffner 2002 for audiogram). Thus, all choices of speaker, microphone, preopolarizer, signal conditioner, and DAQ board should ideally be geared towards generating or recording frequencies in this range. 

####Hardware:
* **Speaker**: a simple speaker that can be controlled by a 5V Arduino output pin vis a single input terminal. When selecting a speaker, take note of the nominal frequency response - many typical commercially available speakers only go up to 2 kHz or so.

* **Microphone**: when selecting a mic, take note of the response chart - ideally it should be relatively flat [+/- 1-2 dB?] over the frequency range of interest.

   It is most likely that a prepolarized microphpone will turn out to be most convenient for this application. This means that the microphone will need to be used in combination with a **preamplifier** and **signal conditioner**. Each of these components have their own response charts, which should ideally be suited towards recording frequencies in the hearing range of mice.
   
   One reasonable combination of recording devices that has worked in the past has been:
      * PCB Piezoelectronics 1/4" free-field prepolarized microphone (model #377C01)
      * PCB Piezoelectronics preamplifier (model #426B03)
      * PCB Piezoelectronics ICP sensor signal conditioner (model #480E09)
      
* **Data Acquisition Boad**: the maximum sampling rate should be at least double the maximum frequency of interest (i.e., the Nyquist rate). 
  
  
####Software:
This directory should contain two files:
* `get_speaker_sepctrogram.ino`
* `get_sepaker_spectrogram.m`

In addition, this program requires MATLAB's data acquisition toolbox ver. 2.16 or above.  
The baud rates specified in `get_sepaker_spectrogram.ino` and `get_speaker_spectrogram.m` must agree.

###INSTRUCTIONS:
Ensure that the serial port specified in `get_speaker_spectrogram.m` matches the serial port connected to the Arduino microcontroller. 

Ensure that the DAQ board and channel number specified by `currDAQ` and `chanID`, respectively, match the DAQ board and channel connected to the recording equipment.

Specify the desired stimulus duration, minimum frequency and maximum frequency in `get_sepaker_spectrogram.m`. If the specified hardware is not suitable for generating or recording the signals of interest, the program will return a warning.

If the stimulus parameters and hardware configuration are satisfactory, upload `get_speaker_spector.ino` to the Arduino then run `get_speaker_spectrogram.m` in MATLAB. 
