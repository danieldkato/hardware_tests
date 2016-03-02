# -*- coding: utf-8 -*-
"""
Created on Thu Dec 10 17:25:28 2015

@author: Acer
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