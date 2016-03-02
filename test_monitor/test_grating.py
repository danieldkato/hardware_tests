# -*- coding: utf-8 -*-
"""
Created on Tue Dec 15 11:31:40 2015

@author: Dan

Run this script to display a moving grating on a monitor. Optionally, display a colored rectangle in front of the grating in order to change its color. 

In most cases, the stimulus will be presented on a secondary monitor dedicated to presenting visual stimuli, rather than on the main display. Specify the monitor on which to display a window by setting the window's "screen" attribute to the index assigned to the monitor by the OS. Indexing starts at 0, which will most likely be assigned to the main display, so indices for stimulus displays will probably start at 1.   

Setting the colors of the grating stimulus requires some tricks, because simply setting the "color" attribute of the GratingStim object will NOT result in alternating bands of black and the specified color. Rather, the way Pysychopy's GratingStim works is that you specify one color, which is represented as a vector originating at [0, 0, 0] - the coordinates of grey in Psychopy's color space - then the grating object computes the opposite vector in color space. The grating stimulus then consists of alternating bands of the specified color and its opposite. Thus, in order to achieve alternating bands of a specified color and black, it's better to just create a monochromatic grating then put a colored, semi-transparent mask in front of it.    
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