import javax.sound.midi.*;
import processing.serial.*;
import garciadelcastillo.dashedlines.*;

// MIDI variables
MidiDevice midiDevice;

//Synthesizer
Synthesizer synth;
final int NUM_CHANNELS = 16;
final int NUM_INSTRUMENTS = 128;
ArrayList<ChannelInfo> channelInfo = new ArrayList<ChannelInfo>();

//Sequencer
final int NUM_TRACKS = 4;
final int NUM_STEPS = 32;
int bpm = 120;
int bpmDisplay = 0;

Sequence sequence;
Sequencer sequencer;
float ticksPerStep = 0;
int currentTrack = 0;
int currentStep = 0;
boolean recording = false;

// MIDI variables
final int START_NOTE = 36;
final int END_NOTE = 84;
final int NUM_NOTES = END_NOTE - START_NOTE;

//Utils
DashedLines dash;
float dashDist = 0;

//Palette
color[] synthwavePalette = {
  #FF6E67, #FFBB67, #FFEB67, #A6FF67,
  #67FFC1, #67D4FF, #6798FF, #C167FF,
  #FF67A0, #FF67D9, #FFFFFF, #000000,
  #FF4343, #FF9143, #FFD143, #67FF43
};

int seqColor = synthwavePalette[9];
int seqHColor = synthwavePalette[5];
int seqCColor = synthwavePalette[6];
int bgColor = synthwavePalette[14];
int txtColor = synthwavePalette[11];
int chColor = synthwavePalette[9];
int nnColor = synthwavePalette[6];
int nn1Color = synthwavePalette[8];
int white = synthwavePalette[10];
int black = synthwavePalette[11];

//Interaction
int mousePressMillis;
long mousePressSeqTick;
int mousePressX;
int mousePressY;

//Serial COM
Serial sPort;
float knock = 500;
String message;

// Active notes
ArrayList<Note> notes = new ArrayList<Note>();

//Synestruments
int synestrumentHeight = height - 100;
int synestrumentWidth = width;
final int KEYANO = 0;
ArrayList<Synestrument> syns = new ArrayList<Synestrument>();

int insName = 255;

Synestrument synestrument;
int currSyn = 0;

int currS = 0;
int currY = 0;
int gridX = 0;
int gridY = 0;

int x;
int y;

int ss = 50;

boolean drawPalette = false;
boolean bendEnabled = false;

void setup() {
  size(128 * 10, 50 * 16 + 110); // (END_NOTE - START_NOTE) * 15, 50 * NUM_CHANNELS
  background(bgColor);
  initMidi();
  initSerial();
  setBPM(bpm);
  createMidiSequence();
  
  //Create the synestruments
  synestrumentHeight = 50 * NUM_CHANNELS;  
  synestrumentWidth = width;  
  syns.add(new Keyano(0, 0, synestrumentWidth, synestrumentHeight));
  syns.add(new Beztar(0, 0, synestrumentWidth, synestrumentHeight));
  syns.add(new Feckof(0, 0, synestrumentWidth, synestrumentHeight));
  syns.add(new Bawler(0, 0, synestrumentWidth, synestrumentHeight));
  
  //Set current synestrument
  synestrument = syns.get(currSyn);

  dash = new DashedLines(this);
  
  for (int c = 0; c < NUM_CHANNELS; c++) {
    ChannelInfo ci = new ChannelInfo();
    ci.number = c;
    ci.instrumentIndex = 0;
    ci.instrumentName = c == 9 ? "Percussion" : "Piano1";
    channelInfo.add(ci);
  }
  
  //fullScreen();
  
  gridX = width / ss;
  gridY = synestrumentHeight / ss;
  x = width/2;
  y = synestrumentHeight/2;
}

void draw() {
  background(bgColor);
  drawBpm();
  if (synestrument != null) {
    
    pushStyle();
    stroke(black, 128);
    strokeWeight(1);
    dash.pattern(2, 4);
    dash.line(synestrumentWidth / 2, 0, synestrumentWidth / 2, synestrumentHeight);
    popStyle();
    
    synestrument.display();
    if (insName > 0) {
      pushStyle();
      textSize(24);
      stroke(chColor, insName);
      strokeWeight(4);
      noFill();
      rect(width/2 - 150, synestrumentHeight/2 - 35, 300, 70, 12);
      noStroke();
      fill(white, insName);
      textAlign(CENTER, CENTER);
      textSize(64);
      text(synestrument.name(),0, 0, width, synestrumentHeight);
      popStyle();
      insName-=2.5;
    }
  }
  
  drawSequencer();
  drawNotes();
  drawVis();
  if (drawPalette)
    drawPalette();
    
  //println(frameRate);
}

void drawBpm() {
  if (bpmDisplay > 0) {
    pushStyle();
    fill(txtColor);
    textAlign(CENTER);
    textSize(200);
    text(""+bpm, 0, 0, width, synestrumentHeight);
    popStyle();
    bpmDisplay--;
  }
}

void drawPalette() {
  pushStyle();
  textSize(12);
  int w = width/synthwavePalette.length;
  for (int i = 0; i < synthwavePalette.length; i++) {
    noStroke();
    fill(synthwavePalette[i]);
    rect(i * w, 10, w, 50);
    if (synthwavePalette[i] == color(0))
      fill(255);
    else
      fill(0);
    text(hex(synthwavePalette[i]).substring(2), i * w, 10, w, 50);
  }
  popStyle();
} //<>//

void drawNotes() {
  pushStyle();
  ArrayList<Note> notesDone = new ArrayList<Note>();
  for (int i = 0; i < notes.size(); i++) {
    Note note = notes.get(i);
    note.update();
    note.display();
    if (note.delay <= 0) {
      notesDone.add(note);
      stopNote(note);
    }
  }
  popStyle();
  
  notes.removeAll(notesDone);
}

void drawVis() {
    drawVis1();
    currS++;
    if (currS > gridX)  {
      currS = 0;
      currY += ss;
    }
    
    if (currY > height) {
      currY = 0;
      background(0);
    }    
}

void drawVis1() {
  if (bendEnabled) {
    pushStyle();
    ellipseMode(CENTER);
    float f = map(knock, 250, 2000, 0, 200);
    noFill();
    stroke(synthwavePalette[(int)random(16)], 100);
    strokeWeight(2);
    rect(currS * ss, currY, f, f, 20);
    popStyle();
  }
}

void drawSequencer() {
  //Sequencer
  pushStyle();

  int trackHeight = (height - (synestrumentHeight + 5)) / NUM_TRACKS;

  noStroke();
  fill(synthwavePalette[2]);
  rect(0, synestrumentHeight + currentTrack * trackHeight, width, trackHeight);
  strokeWeight(1);
  for (int s = 0; s < 32; s++) {
    for (int t = 0; t < NUM_TRACKS; t++) {
      int n = getNoteAtStep(sequence, t, s);
      if (n > 0) {
        noStroke();
        fill(lerpColor(nn1Color, nnColor, map((n - START_NOTE) * width/NUM_NOTES, 0, width/NUM_NOTES * NUM_NOTES, 0, 1)));
        rect(s * width/32, synestrumentHeight + t  * trackHeight, width/32-2, trackHeight, 2);
      }
    }
    
    
    pushStyle();
    dash.pattern(1, 5);
    strokeWeight(1);
    stroke(chColor);
    dash.line(0, synestrumentHeight + currentTrack * trackHeight, width, synestrumentHeight + currentTrack * trackHeight);
    dash.line(0, synestrumentHeight + (currentTrack + 1) * trackHeight, width, synestrumentHeight + (currentTrack + 1) * trackHeight);
    popStyle();  

    if (sequencer.isRunning()) {
      if (sequencer.getTickPosition() == s)
        stroke(seqHColor);
      else
        stroke(seqColor);
    }
    else
      stroke(currentStep == s ? seqHColor : seqColor);
      
    noFill();
    strokeWeight(2);
    rect(s * width/32, synestrumentHeight, width/32-2, trackHeight * NUM_TRACKS, 2);
    fill(txtColor);
    text(""+s, s * width/32, synestrumentHeight, width/32-2, trackHeight * NUM_TRACKS);
  }
  
  if (recording) {
    pushStyle();
    ellipseMode(CENTER);
    noStroke();
    fill(255, 0 , 0);
    ellipse(18, synestrumentHeight + (currentTrack * trackHeight) + trackHeight/2, 12, 12);
    popStyle();
  }
  
  popStyle();
}

void mouseDragged() {
  if (mouseY < synestrumentHeight) {    
    if (mouseButton == LEFT) {
      if (synestrument != null)
        synestrument.onLeftMouseDragged();
    }
  }
}

void mousePressed() {
  mousePressX = mouseX;
  mousePressY = mouseY;
  mousePressMillis = millis();
  mousePressSeqTick = sequencer.getTickPosition();
  
  if (mouseY < synestrumentHeight && synestrument != null) {
    if (mouseButton == LEFT) {
      synestrument.onLeftMousePressed();
    }
    if (mouseButton == RIGHT) {
      synestrument.onRightMousePressed();
    }
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    if (mousePressY > synestrumentHeight && mousePressY < height &&
        mouseY > synestrumentHeight && mouseY < height ) {
      //Select Sequencer Step
      currentStep = mouseX / (width/32);
    }
    else if (synestrument != null)
      synestrument.onLeftMouseReleased();
  }

  if (mouseButton == RIGHT) {
    if (synestrument != null)
      synestrument.onRightMouseReleased();
  }
  
  mousePressX = -1;
  mousePressY = -1;
}

void mouseWheel(MouseEvent event) {
  float delta = event.getCount();
  if (synestrument != null) {
      if (synestrument.onMouseWheel(delta))
        return;
  }
        
  bpm += delta;
  setBPM(bpm); 
  bpmDisplay = 30;
}

long getCurrentDuration() {
  long duration = 0;
  if (sequencer.isRunning()) {
    long r = sequencer.getTickPosition();
    if (r < mousePressSeqTick)
      duration = NUM_STEPS - mousePressSeqTick + r;
    else
      duration = sequencer.getTickPosition() - mousePressSeqTick;
    }
  else {
    int tm = millis() - mousePressMillis;
    duration = (long)constrain(tm/(long)calculateMillisecondsPerTick(), 1, 32 - currentStep);
  }

  return duration;
}

void recordNote(Note note, long noteDuration) {
  if (recording) {
    //println("PRESS", noteDuration);
    long tick = (long)(currentStep * ticksPerStep);
    if (sequencer.isRunning())
      tick = mousePressSeqTick;
    //println("Record:",  tick, note.note, note.channel);
    ChannelInfo ci = channelInfo.get(note.channel);
    sequence.getTracks()[currentTrack].add(createProgramChangeEvent(note.channel, ci.instrumentIndex, tick));
    MidiEvent e = createNoteOnEvent(note.channel, note.note, note.volume, tick);
    sequence.getTracks()[currentTrack].add(e);
    long noteOffTick = Math.round(tick + noteDuration);
    sequence.getTracks()[currentTrack].add(createNoteOffEvent(note.channel, note.note, 0, noteOffTick));
    return;
  }
}

void showInstrument(Synestrument si) {
  synestrument = si;
  insName = 255;
}
void keyPressed() {
  
  if (synestrument != null)
      if (synestrument.onKeyPressed() == true)
        return;
      
  if (key == 'q') {
    currSyn++;
    if (currSyn == syns.size())
      currSyn = 0;
      
    syns.get(KEYANO).setNaturalOnly(false);
    showInstrument(syns.get(currSyn));
  }
  
  if (key == 'k') {
    currSyn = 0;
    syns.get(KEYANO).setNaturalOnly(false);
    showInstrument(syns.get(currSyn));
  }


  int ch = 0;
  if (synestrument != null) {
    ch = synestrument.getChannel();
  }
    
  ChannelInfo ci = channelInfo.get(ch);
  if (keyCode == LEFT) {
    if (recording) {
      currentStep -= 1;
      if (currentStep < 0)
        currentStep = 31;
      return;
    }
    
    int i = ci.instrumentIndex - 1;
    if (i < 0) i = 127;
    setProgram(ch, i);
    Note note = new Note(synth, width/2, ch * synestrumentHeight/NUM_CHANNELS + synestrumentHeight/NUM_CHANNELS/2, ch, 60, 100, 30); 
    addNote(note);
  }
  
  if (keyCode == UP) {
    currentTrack--;
    if (currentTrack < 0)
      currentTrack = NUM_TRACKS - 1;
  }
  
  if (keyCode == DOWN) {
    currentTrack++;
    if (currentTrack == NUM_TRACKS)
      currentTrack = 0;
  }
  
  if (keyCode == RIGHT) {
    if (recording) {
      currentStep += 1;
      if (currentStep > 31)
        currentStep = 0;
      return;
    }
    
    int i = ci.instrumentIndex + 1;
    if (i > 127) i = 0;
    setProgram(ch, i);
    Note note = new Note(synth, width/2, ch * synestrumentHeight/NUM_CHANNELS + synestrumentHeight/NUM_CHANNELS/2, ch, 60, 100, 30);
    //note.setMessage(ci.instrumentName);  
    addNote(note);
  }
  
  if (key == 'r') {
      recording = !recording;
  }

  if (key == 'c') {
    recording = false;
    sequencer.stop();
    Track[] tracks = sequence.getTracks(); // Get all tracks from the sequence
    for (int i = tracks.length - 1; i >= 0; i--) {
      sequence.deleteTrack(tracks[i]); // Delete each track from the sequence
    }
 
    createMidiSequence(); 
  }
 
   if (key == 'p') {
    if (sequencer.isRunning()) sequencer.stop();
    else
      playMidiSequence();
  }

  if (keyCode == ENTER) {
    saveFrame("frames\\softSynth#####.png");
  }
  
  if (key == 'd') drawPalette = !drawPalette;
  if (key == 'b') bendEnabled = !bendEnabled;
}

void addNote(Note note) {
    notes.add(note);
    note.play();
}

void stopNote(Note note) {
  if (synth != null) {
    note.stop();
  }
}

void setProgram(int channel, int programNumber) {
  if (synth != null && channel != 9) {
    try {
      // Change the program number (instrument) using CC message
      int ccNumber = 0x00; // Control Change number for Bank Select MSB
      int ccValue = 0x80; // Value for GM Bank (0x00 for GM1, 0x78 for GM2)
  
      synth.getChannels()[channel].controlChange(ccNumber, ccValue);
      
      // Change the program number (instrument) using Program Change message
      synth.getChannels()[channel].programChange(programNumber);
      ChannelInfo ci = channelInfo.get(channel);
      ci.instrumentIndex = programNumber;
      ci.instrumentName = synth.getLoadedInstruments()[programNumber].getName();
      //println("SetProgram:", channel, programNumber);
    }
    catch (Exception e) {
      println("EEEEEK", e);
    }
  }
}

void stop() {
  if (midiDevice != null && midiDevice.isOpen()) {
    midiDevice.close();
  }
  if (sequencer != null && sequencer.isOpen()) {
    sequencer.stop();
    sequencer.close();
  }
  super.stop();
}

void createMidiSequence() {
  try {
    sequence = new Sequence(Sequence.PPQ, 4);
    for (int t = 0; t < NUM_TRACKS; t++) {
      sequence.createTrack();   
      finalizeSequence(sequence, t);
    }
    sequencer.setSequence(sequence);
    ticksPerStep = sequence.getResolution() / 4; 
  } catch (InvalidMidiDataException e) {
    e.printStackTrace();
  }
}

void playMidiSequence() {
  if (sequencer != null && sequence != null) {
    try {
      sequencer.setLoopCount(Sequencer.LOOP_CONTINUOUSLY); // Loop the sequence continuously
      sequencer.start();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}

void setBPM(int bpm) {
  if (sequencer != null) {
    float tempoFactor = (float) (bpm) / 120.0f; // Calculate tempo factor
    sequencer.setTempoFactor(tempoFactor);
  }
}

void setInstrument(Track track, int channel, int instrument, long atTick) {
  ShortMessage programChange = new ShortMessage();
  try {
    programChange.setMessage(ShortMessage.PROGRAM_CHANGE, channel, instrument, 0);
    track.add(new MidiEvent(programChange, atTick)); // Set instrument at the start of the track
  } catch (InvalidMidiDataException e) {
    e.printStackTrace();
  }
}

long calculateNextTick() {
  long sequenceLengthInMicros = sequencer.getMicrosecondLength();
  float ticksPerMicro = sequencer.getTickLength() / (float) sequenceLengthInMicros;
  return sequencer.getTickPosition() + (long)(1000000 * ticksPerMicro); // Convert microseconds to ticks
}

void serialEvent(Serial port) {
  //Read from port
  String inString = port.readStringUntil('\n');
  if (inString != null) {
    //Trim
    inString = inString.trim();
    //Record it
    String[] values = new String[2];
    values[0] = Long.toString(System.currentTimeMillis());
    values[1] = inString;
    // Process the command
    String[] command = inString.split(":");
    switch(command[0]) {
      case "KNOCK":
        //println(inString);
        onKnockCommand(float(command[1]));
        break;
      case "EXTCMD":
        println(inString);
        break;
      case "CC":
        println(inString);
        onControlChange(int(command[1]), int(command[2]), float(command[3]));
    }
  }
}

void onKnockCommand(float k) {
  knock = k;
  if (synth != null && synestrument != null) {
    if (bendEnabled) knock = 8192 + random(-1, 1)*k;
    else
      knock = 8192;
    //println("BEND:", synestrument.getChannel(), k);
    synth.getChannels()[synestrument.getChannel()].setPitchBend(floor(knock));
  }
}

void onControlChange(int cc, int channel, float value) {}
