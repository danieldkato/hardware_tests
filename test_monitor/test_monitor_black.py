# -*- coding: utf-8 -*-
"""
Created on Thu Dec 10 17:25:28 2015

@author: Acer

Last updated DDK 6/7/16

OVERVIEW:
This script displays a black screen. Use to test monitor luminance, calibrate brightness-luminance curve, etc. 

REQUIREMENTS:
`python` >=2.7
`psychopy`

Make sure that the `monitor` object referred to in the definition of `mywin` has been defined in the local instance of psychopy.


INSTRUCTIONS:
Ensure that the `screen` attribute specified in the assignment of `mywin` is set to the appropriate monitor. Note that this is different from the `monitor` option; whereas `monitor` is an object that simply stores a number of data fields related to the monitor (like its model number, max resolution, dimensions, distance, etc.), `screen` is the actual hardware index used by the OS to identify the monitor. 

In most cases, the stimulus will be presented on a secondary monitor dedicated to presenting visual stimuli, rather than on the main display. Indexing starts at 0, which will most likely be assigned to the main display, so indices for stimulus displays will probably start at 1.   

Navigate to the directory containing this script in a command line window and enter:

`python test_monitor_black.py`

or hit the `run` button in an IDE like Spyder. 
"""

from psychopy import visual, core, event #import some libraries from PsychoPy

#create a window
mywin = visual.Window([1024,768],monitor="DP2VGA V152", units="pix", screen = 1, rgb=[0,0,0])

#create some stimuli
#grating = visual.GratingStim(win=mywin, mask='circle', size=3, pos=[-4,0], sf=3)
#fixation = visual.GratingStim(win=mywin, size=0.2, pos=[0,0], sf=0, rgb=-1)
rect = visual.Rect(win=mywin,width=1024,height=768,fillColor=[-1,-1,-1],lineColor=[-1,-1,-1])

#draw the stimuli and update the window

rect.draw()
mywin.flip()

while True: #this creates a never-ending loop
    #grating.setPhase(0.05, '+')#advance phase by 0.05 of a cycle
    #grating.draw()
    #fixation.draw()

    if len(event.getKeys())>0: break
    event.clearEvents()

#cleanup
mywin.close()
core.quit()