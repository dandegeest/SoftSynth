# SoftSynth

A software synthesizer framework for synesthetic instrument exploration and visualization.

- Provides MIDI note playback and 32 step sequencing using the Java Sound API and Gervil 16 channel software synthesizer
- Synestrument base class provides note, mouse, and keyboard handling to allow quick prototypes of new Synestruments
- Provides serial port reading for hooking up your Arduino or Pico ideas - see my [BounceHouse](https://github.com/dandegeest/BounceHouse) MicroPython project as an example

![image](frames/overview.png)

# Included Synestruments
- Keyano - 16 channel keyboard, per channel patch, click to play note or drag for fun effects
- Beztar - 16 channel strummable synestrument, plays natural notes, per channel patch
- FeckCOF - Circle of Fifths synestrument, play chords or single notes on the COF wheel, per channel patch
- Bawler - Generative bouncy bawl drones, notes, and beats based on Keyano

# User Guide
- After dowloading or cloning open the [SoftSynth sketch](SoftSynth.pde) then click "Play"
- Interface is shown with the **Keyano** activated.  Click around and make some sounds, right click to change the patch, click and drag perhaps!
- Pressing **'q'** will move through the installed synestruments listed above.  Click (hold the button down maybe?) around and find out, click and drag slow/fast - have fun.
- Pressing **'r'** turns on sequence recording press again to turn off
- Pressing **'p'** plays the sequence (and records if record is on) press again to turn off
- Pressing **'c'** clears the sequence
- Pressing **'0'** stops and removes all notes from the playback

# Artist Statement
For my final project in HCI570X Data Visualization I selected to explore generative music and synesthetic instruments following this project brief:
---
Synesthetic Instrument

Create an 'audiovisual instrument' that allows a user or performer to produce tightly responsive and coupled sound and visuals (video, Processing window, etc.). Your software should make possible the creation of both dynamic imagery and noise/sound/music, simultaneously, in real-time.

The challenge is to create an open-ended system where the audio and visual modalities are equally expressive. Its results should be inexhaustible, deeply variable, and dependent on the performer's /user's choices. The basic principles of the instrument's operation should be easy to learn, while at the same time should encourage or provoke sophisticated expression. 

Use the tools learned this semester to create an instrument that receives input from the performer or user. Imagine how this will be input into the system or application: will the performer use the keyboard, the mouse, a multi-touch trackpad, a webcam, push buttons, or some other sensor? Select and construct your instrument's physical interface with care and consider the expressive affordances. Categorize the data that is input and output: are they continuous values, changes in electrical circuitry, MIDI, OSC, or changes to logical states.

Assume your instrument generates output for a graphic display and audio system. Think of different visual possibilities such as variables like hue, saturation, shape, texture, pixel data, PVector motion. And think about different auditory elements such as pitch, filters, samples, dynamics, rhythm. Link the sonic and visual elements together by using the 'map()' function to map the system's audio-visual input and output.

Get a 'user' (friend, family member, classmate) to perform the instrument / user testing. Begin by giving a demonstration of the instrument. Then allow your audience/performers to, one-by-one, learn how to play the instrument. Record these sessions with photographs and videos.

Variations:

Use Processing and the 'minim' library to build an interface and create visuals for your instrument. If your interface is visual and relies on buttons or mouse events, be sure to visualize these elements on the Processing display.
---



