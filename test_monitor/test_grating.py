# -*- coding: utf-8 -*-
"""
Created on Tue Dec 15 11:31:40 2015

@author: Dan

Last updated DDK 6/7/16

OVERVIEW:
This script displays a sinusoidal mean-gray horizontal moving grating on a specified monitor. Use to test monitor luminance, calibrate brightness-luminance curve, etc. 


REQUIREMENTS:
`python` >=2.7
`psychopy`

Make sure that the `monitor` object referred to in the definition of `mywin` has been defined in the local instance of psychopy.

For best results, use a graphics card that supports syncing calls to win.flip() with the vertical blank interval (VBI) of the screen. Failing to sync calls to win.flip() with the VBI will result in "tearing", i.e., one contiguous block of pixel rows will display one frame while the remaining rows will display the subsequent frame. Note that the graphics cards included with many laptops by default do not support syncing win.flip() with the VBI!


INSTRUCTIONS:
Ensure that the `screen` attribute specified in the assignment of `mywin` is set to the appropriate monitor. Note that this is different from the `monitor` option; whereas `monitor` is an object that simply stores a number of data fields related to the monitor (like its model number, max resolution, dimensions, distance, etc.), `screen` is the actual hardware index used by the OS to identify the monitor. 

In most cases, the stimulus will be presented on a secondary monitor dedicated to presenting visual stimuli, rather than on the main display. Indexing starts at 0, which will most likely be assigned to the main display, so indices for stimulus displays will probably start at 1.   
 
Ensure that the resolution specified in the assignment of `mywin` matches the desired resolution. Specify the stimulus parameters, like stimulus duration, spatial frequency, and speed, in the `#Grating properties` section. Optionally, display a colored rectangle in front of the grating in order to change its color. 

Navigate to the directory containing this script in a command line window and enter:

`python test_grating.py`

or hit the `run` button in an IDE like Spyder. 


DESCRIPTION:
Run this script to display a sinusoidal mean-gray horizontal moving grating on a monitor.

Setting the colors of the grating stimulus requires some tricks, because simply setting the "color" attribute of the GratingStim object will NOT result in alternating bands of black and the specified color. Rather, the way Pysychopy's GratingStim works is that you specify one color, which is represented as a vector originating at [0, 0, 0] - the coordinates of grey in Psychopy's color space - then the grating object computes the opposite vector in color space. The grating stimulus then consists of alternating bands of the specified color and its opposite. Thus, in order to achieve alternating bands of a specified color and black, it's better to just create a monochromatic grating then put a colored, semi-transparent mask in front of it.    

Thus far, this has almost always been used with a secondary KD50G21-40NT-A1 display (distributed through AdaFruit as 'HDMI 4 Pi 5" Display not Touchscreen 800x480-HDMI/VGA/NTSC/PAL').
"""

import time
from psychopy import visual, core, event #import some libraries from PsychoPy

"""
 User-entered parameters here:
"""
#Timing info:
preStim = 0 #seconds
stimDur = 5 #seconds
fps = 60
numFrames = stimDur * fps
currFrame = 0

#Grating properties:
spFreq = .01 #spatial frequency of grating in cycles/pixel
speed = 0.1 #cycles advanced/frame
gratColor  = [1, 1, 1] # "color" of grating stimulus; usually best to leave this [1, 1, 1]; see general notes for more  

#Color mask properties:
maskColor = [1, 0, 0] # normalized RGB triple defining color of rectangular mask in front of moving grating stimulus
alpha = 0.4

"""
Create and display stimuli:
"""
#Create a window in which to display visual stimulus objects:
mywin = visual.Window([1024,768],monitor="HDMI 4 Pi 5in Display KD50G21-40NT-A1", units="pix", screen = 1, rgb=[-1,-1,-1])

#Define visual stimulus objects:
grating = visual.GratingStim(mywin, mask='None', size=[1024,768], pos=[-4,0], sf=spFreq, color = gratColor)
rect = visual.Rect(mywin, width=1024, height=768, fillColor=maskColor, opacity=alpha);

#Display stimuli:
time.sleep(preStim)
print('running')
while currFrame < numFrames:
    grating.setPhase(speed, '+')#advance phase by 0.1 of a cycle
    grating.draw()
    rect.draw()
    mywin.flip()
    currFrame+=1

#Clean up:    
mywin.close()