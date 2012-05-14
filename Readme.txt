
                              G A D G E T S
-----------------------------------------------------------------------------

Recent Changes
--------------
0.3.5
Bug fixes for icon display on frames, and fixed the display for stack counts 



0.0 Alpha Status
----------------

Please be aware, this is an alpha release. The code has not been properly 
optimised, and there are bound to be lots of bugs. I've uploaded this in
case anyone is interested - use at your own risk!


1.0 Quick Start
---------------

You will see a small blue button on your screen, just by your mini map. Right 
click on this button and choose 'Add Gadget' to add a gadget to your screen.

Left click and drag the button to move it, or just left click on the button
to unlock (and relock) all of your gadgets. When unlocked, Gadgets can be 
moved by dragging their move handles (the orange circles at the top corner of
each gadget). 

To alter an existing gadget, right click on it's move handle while gadgets
are unlocked, and choose 'Modify Gadget'.

When moving gadgets around on the screen, you can align them to another gadget
by dragging the move handle over the top of another move handle. The gadget 
you are dragging will align itself either horizontally or vertically with it. 
If you move the gadget too far from the horizontal or vertical axes, alignment 
mode will turn off (it should hopefully become clear when you try it!).


2.0 What is the "Gadgets" addon?
--------------------------------

This addon is a compilation of the WT libraries (collectively known as LibWT), 
and a small set of common gadgets that are implemented on top of these 
libraries.

The Gadgets framework provides a common mechanism for creating instances of 
an addon, and handling configuration and screen placement in a common way.


The following addons are included in this basic bundle:

2.1 Charge Meter
This is a simple bar that shows the current charge for a mage player. This 
gadget exists for unit frames that do not include a charge bar.

2.2 Combo Points
This displays a row of swords for warriors and rogues. This gadget is available
for templates that do not include these.

2.3 CPU Monitor
Shows the percentage CPU used by all addons.

2.4 FPS Monitor
Shows the current Frames Per Second, updated every second.

2.5 Raid Frames
This will create a set of 20 raid frames, using the layout and template specified
by the user (see Unit Frame Templates below).

2.6 Range Finder
This gadget displays the distance between the player and the target.

2.7 Reload UI
Provides a simple 'Reload UI' button, to save a bit of typing while developing 
addons. This probably won't be useful if you're not a developer.  

2.8 Unit Frame
This gadget allows a Unit Frame for any unit specifier to be added to the screen.
The user can specify the template, which determines how the frame looks and the
functionality it has available


3.0 In Development
------------------

The following gadgets are not yet complete, and will be included in a future version:

3.1 Buff Panel
This is a Unit Frame that only displays buffs and debuffs, and allows the user 
to configure how buffs are displayed. It uses the same Buff Panels as those included
in Unit and Raid frames, but provides the user with many more configuration options. 


4.0 Unit Frame Templates
------------------------

Unit and Raid frames are set up through the use of templates. LibWT provides some 
fairly comprehensive mechanisms for binding unit data to elements within a
template, which allows for fast creation of many different types of Unit Frame.

The Gadgets addon provides the following built in Unit Frame templates:

4.1 Standard Frame
The default unit frame, provides a fairly complete unit frame.

4.2 Simple Frame
A more compact unit frame that presents less information than the standard frame. 
Useful for things like 'Target of Target'.

4.3 Raid Frame
The default raid frame template, this is a very compact box, colour coded to the 
unit's class. It provides a usable replacement for the built in raid frames.

4.4 Health Orb
This is more of a test of the flexibility of unit frame templates than a really 
useful template. It will display a large green glossy orb on the screen which fills up 
and empties with the unit's health.

4.5 Mana Orb
Similar to the health orb, not a serious unit frame. While it's called a Mana Orb, 
it will actually display energy or power for rogues or warriors.


5.0 Known Issues / Future Functionality
---------------------------------------

5.1 Aggro Display (Raid Frame Template)
The aggro border on the default frames is a little too subtle. May alter the template
to make it 2 pixels wide instead of 1. 

5.2 Localization
Most of the strings in the addons don't currently use wtStrings, which means they
won't be easily localizable. I need to pass through the code and switch all hard coded
text to wtStrings.

6.0 API Documentation
---------------------

LibWT and the various template were created for my own amusement and use, and I'm not 
convinced anyone else will like them, use them, want them, etc.

Therefore, I haven't written any comprehensive API documentation for the Gadgets 
framework at this time. The API is changing fairy frequently as it develops, and I also
didn't want to invest a lot of effort if this framework isn't useful to anyone else. If
it turns out that this stuff is useful to anyone except me, I'll document the API fully
and ensure that backwards compatibility is maintained where possible.


7.0 Development Roadmap
-----------------------

This is a hobby project for my own amusement, so I'm not going to tie myself down to a
specific roadmap. However, my intentions at this time are to:

Carry out a full review of the code. It has grown fairly organically over the last couple
of months, and needs to be optimised, documented and generally tidied up.

Create new artwork. The images currently included in the addon were culled from Google 
searches, or taken from WoW's LibSharedMedia and amended to work with the unit frame 
templates. I need to create new artwork for gadget icons to ensure they are consistent
and are not infringing copyright. I believe the bars from LibSharedMedia, and artwork
from the Rift Fan Site Kit, are OK to use and am not planning on replacing these.

Enhance the configuration dialogs. Particularly for the built in unit frames and raid 
frames, there are very few options. This is largely due to the templating approach, as
a Unit Frame can do completely different things (e.g. compare the Range Finder to a Health
Orb, they are both templated unit frames). The intention is to add configuration dialogs
to templates, so that a user can specify options directly for a template.


8.0 Spelling
------------

Within the addons, I have generally tried to stick to American spelling for words like 'color' 
and 'initialize', as I believe this is what most developers expect. However, I am English, so
there is a good chance some correct spellings may have crept in ;p
