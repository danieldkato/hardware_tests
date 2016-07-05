*Last updated DDK 6/7/16*

##TEST_SPEAKERS
###OVERVIEW:
This directory contains code for testing and recording the output of Arduino-controlled speaker systems. Use for testing the function of speaker systems, associated output pins, and connections in between. It includes the following programs:

* `test_speakers.ino`: A simple sketch for generating a single white noise stimulus from an Arduino-controlled speaker.

* `get_speaker_spectrogram`: A program for generating a white noise stimulus from an Arduino-controlled speaker, recording the output through a prepolarized microphone and generating a spectrogram of the output in MATLAB. 

For specific instructions and requirements for each program, see each program's `README.md` files and header comments for each file.

###COMMON REQUIREMENTS:
All of the programs in this directory require that the `Arduino` core library include the functions `tone()` and `noTone()`. These have been included in the core library since v. 0018.  


