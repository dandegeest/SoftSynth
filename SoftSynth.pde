import javax.sound.midi.*;
import processing.serial.*;
import garciadelcastillo.dashedlines.*;

// MIDI variables
MidiDevice midiDevice;
Note currentNote;

//Synthesizer
Synthesizer synth;
final int NUM_CHANNELS = 16;
final int NUM_INSTRUMENTS = 128;
ArrayList<ChannelInfo> channelInfo = new ArrayList<ChannelInfo>();

//Sequencer
final int NUM_TRACKS = 4;
final int NUM_STEPS = 32;
final int NOTE_VELOCITY = 100;
final long MS_PER_TICK = 3875000 / NUM_STEPS / 1000;
Sequence sequence;
Sequencer sequencer;
int currentTrack = 0;
int currentStep = 0;
boolean recording = false;

// MIDI variables
final int START_NOTE = 36;//24;
final int END_NOTE = 84;//94
final int NUM_NOTES = END_NOTE - START_NOTE;

//Pad
DashedLines dash;
float dashDist = 0;
int padHeight = height - 100;
int currS = 0;
int currY = 0;
int gridX = 0;
int gridY = 0;

//Palette
color[] synthwavePalette = {
  #FF6E67, #FFBB67, #FFEB67, #A6FF67,
  #67FFC1, #67D4FF, #6798FF, #C167FF,
  #FF67A0, #FF67D9, #FFFFFF, #000000,
  #FF4343, #FF9143, #FFD143, #67FF43
};

int seqColor = synthwavePalette[1];
int seqHColor = synthwavePalette[12];
int seqCColor = synthwavePalette[6];

int bgColor = synthwavePalette[14];
int txtColor = synthwavePalette[11];
int chColor = synthwavePalette[12];
int chHColor = synthwavePalette[2];
int nnColor = synthwavePalette[5];
int nn1Color = synthwavePalette[8];
int whiteKey = synthwavePalette[10];
int blackKey = synthwavePalette[11];

//Interaction
int lastPress;
long lastPressTick;
int mousePressX;

//Serial COM
Serial sPort;
float knock = 0;
String message;

ArrayList<Note> notes = new ArrayList<Note>();

void setup() {
  size(128 * 10, 50 * 16 + 110); // (END_NOTE - START_NOTE) * 15, 50 * NUM_CHANNELS
  padHeight = 50 * 16;  
  background(bgColor);
  initMidi();
  initSerial();
  setBPM(120);
  createMidiSequence();

  dash = new DashedLines(this);
  
  for (int c = 0; c < NUM_CHANNELS; c++) {
    ChannelInfo ci = new ChannelInfo();
    ci.number = c;
    ci.instrumentIndex = 0;
    ci.instrumentName = "Piano1";
    channelInfo.add(ci);
  }
  
  //fullScreen();
}

void draw() {
  background(bgColor);
  //drawPalette();
  drawPad();
}

boolean padVisible() {
  return recording || mousePressed || keyPressed;
}

void drawPalette() {
  
  for (int i = 0; i < synthwavePalette.length; i++) {
    noStroke();
    fill(synthwavePalette[i]);
    rect(i * 50, 10, 50, 50);
  }
}

void drawPad() {
  int channel = 0;
  boolean activeChannel = false;
  int activeChannelY = 0;    
  for (int y = 0; y < padHeight; y += padHeight/NUM_CHANNELS) { //<>//
    if (channel == NUM_CHANNELS)
      break;
    pushStyle();
    strokeWeight(1);
    stroke(chColor);
    fill(chHColor);
    activeChannel = mouseY >= y && mouseY <= y + padHeight/NUM_CHANNELS;
    if (!padVisible() && activeChannel)
      activeChannelY = y;
      if (activeChannel && mouseButton != RIGHT) {
        //Fill in the active channel
        pushStyle();
        for (int x = 0; x < width; x += width/NUM_NOTES) {
          noStroke();
          int n = getNote(x);
          if (isNaturalNote(n))
            fill(whiteKey, 200);
          else
            fill(blackKey,200);
          rect(x, y, width/NUM_NOTES, padHeight/NUM_CHANNELS);
        }
      popStyle();    
      //rect(0, y, width, padHeight/NUM_CHANNELS);
    }
    
    if (padVisible() || activeChannel) {
      line(0, y, width, y);
      //Instrument Name
      fill(txtColor);
      textAlign(LEFT);
      textSize(20);
      text(channelInfo.get(channel).instrumentName, 5, y + 5, width-5, padHeight/NUM_CHANNELS);
    }
    channel++;
    popStyle();
  }
  
  int division = mouseButton == RIGHT ? NUM_INSTRUMENTS : NUM_NOTES;
  
  if (padVisible() || activeChannelY > 0) {
    pushStyle();
    dash.pattern(1, 5);
    strokeWeight(1);
    stroke(chColor);
    for (int x = 0; x < width; x += width/division) {
      dash.line(x, activeChannelY, x, padVisible() ? padHeight : activeChannelY + padHeight/NUM_CHANNELS);
      dash.offset(dashDist);
      dashDist += 1;
    }
    popStyle();
  }

  //Current Cell
  if (mouseY < padHeight) {
    pushStyle();
    noStroke();
    fill(lerpColor(nn1Color, nnColor, map(mouseX, 0, width, 0, 1)));
    rect(mouseX - (mouseX % (width/division)), mouseY - (mouseY % (padHeight/NUM_CHANNELS)), width/division, padHeight/NUM_CHANNELS);
    fill(txtColor);
    int nn;
    if (mouseButton == RIGHT) {
      textSize(14);
      nn = (int)map(mouseX, 0, width/NUM_INSTRUMENTS * NUM_INSTRUMENTS, 0, NUM_INSTRUMENTS);
    }
    else
      nn = getNote(mouseX);
    text(""+nn, mouseX - (mouseX % (width/division)), mouseY - (mouseY % (padHeight/NUM_CHANNELS)), width/division, padHeight/NUM_CHANNELS);
    popStyle();
  }

  //Sequencer
  pushStyle();
  int trackHeight = (height - (padHeight + 5)) / NUM_TRACKS;
  noStroke();
  fill(chHColor);
  rect(0, padHeight + currentTrack * trackHeight, width, trackHeight);
  strokeWeight(1);
  for (int s = 0; s < 32; s++) {
    for (int t = 0; t < NUM_TRACKS; t++) {
      int n = getNoteAtStep(sequence, t, s);
      if (n > 0) {
        noStroke();
        fill(lerpColor(nn1Color, nnColor, map((n - START_NOTE) * width/NUM_NOTES, 0, width/NUM_NOTES * NUM_NOTES, 0, 1)));
        rect(s * width/32, padHeight + t  * trackHeight, width/32-2, trackHeight, 2);
      }
    }
    
    if (recording) {
      pushStyle();
      ellipseMode(CENTER);
      fill(255, 0 , 0);
      ellipse(5, padHeight + (currentTrack * trackHeight) + trackHeight/2, 12, 12);
      popStyle();
    }
    
    pushStyle();
    dash.pattern(1, 5);
    strokeWeight(1);
    stroke(chColor);
    dash.line(0, padHeight + currentTrack * trackHeight, width, padHeight + currentTrack * trackHeight);
    dash.line(0, padHeight + (currentTrack + 1) * trackHeight, width, padHeight + (currentTrack + 1) * trackHeight);
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
    rect(s * width/32, padHeight, width/32-2, height - padHeight - 10, 2);
    fill(txtColor);
    text(""+s, s * width/32, padHeight, width/32-2, height - padHeight - 10);
  }
  popStyle();
  
  ArrayList<Note> notesDone = new ArrayList<Note>();
  for (int i = 0; i < notes.size(); i++) {
    Note note = notes.get(i);
    note.update();
    note.display();
    if (note.delay == 0) {
      notesDone.add(note);
      stopNote(note);
    }
  }
  
  notes.removeAll(notesDone);
}

int getNote(int xPos) {
  int note = (int)map(xPos, 0, width/NUM_NOTES * NUM_NOTES, START_NOTE, END_NOTE);
  return note;
}

void mouseDragged() {
  if (mouseY < padHeight) {
    //if (currentNote != null) {
    //  int pitchBendValue = floor(map(mouseX, mousePressX, width, 0, 16383 ));
    //  ShortMessage pitchBendMessage = new ShortMessage();
    //  int channel = currentNote.channel;
    //  synth.getChannels()[channel].setPitchBend((int)map(mouseX, mousePressX, width, 8192, 16383));
    //  try {
    //    println(pitchBendValue & 0x7F, (pitchBendValue >> 7) & 0x7F);
    //    pitchBendMessage.setMessage(ShortMessage.PITCH_BEND, channel, pitchBendValue & 0x7F, (pitchBendValue >> 7) & 0x7F);
    //    MidiEvent pitchBendEvent = new MidiEvent(pitchBendMessage, getCurrentDuration());
    //    sequence.getTracks()[currentTrack].add(pitchBendEvent);
    //   }
    //     catch (InvalidMidiDataException e) {
    //     e.printStackTrace();
    //   }    
    //   return;
    //}
    
    if (mouseButton == LEFT) {
      int ch = constrain((int)map(mouseY, 0, padHeight, 0, NUM_CHANNELS), 0, 15);  
      int nn = getNote(mouseX);
      int v = constrain(abs(mouseX - pmouseX) * 2, 50, 127);
      Note note = new Note(synth, mouseX, mouseY, ch, nn, v, abs(mouseX - pmouseX) * 2);
      addNote(note);
    }
  }
}

void mousePressed() {
  mousePressX = mouseX;
  if (mouseButton == LEFT && mouseY < padHeight) {
    lastPress = millis();
    lastPressTick = sequencer.getTickPosition();
    
    //Select Note
    int ch = constrain((int)map(mouseY, 0, padHeight, 0, NUM_CHANNELS), 0, 15);
    int nn = getNote(mouseX);
    int nd = 100;
    int v = 100;
    currentNote = new Note(synth, mouseX, mouseY, ch, nn, v, nd);
    addNote(currentNote);
  }
}

long getCurrentDuration() {
  long duration = 0;
  if (sequencer.isRunning()) {
    long r = sequencer.getTickPosition();
    if (r < lastPressTick)
      duration = NUM_STEPS - lastPressTick + r;
    else
      duration = sequencer.getTickPosition() - lastPressTick;
    }
  else {
    int tm = millis() - lastPress;
    duration = constrain(floor(tm/MS_PER_TICK), 0, NUM_STEPS);
  }

  return duration;
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    if (currentNote != null) {
      currentNote.stop();
      //synth.getChannels()[currentNote.channel].setPitchBend(8191);
      recordNote(currentNote, getCurrentDuration());
    }
    
    if (mouseY > padHeight && mouseY < height) {
      //Select Seq Step
      currentStep = mouseX / (width/32);
    }
  }

  if (mouseButton == RIGHT) {
    int program = (int)map(mouseX, 0, width/NUM_INSTRUMENTS * NUM_INSTRUMENTS, 0, NUM_INSTRUMENTS);
    int ch = constrain((int)map(mouseY, 0, padHeight, 0, NUM_CHANNELS), 0, 15);
    int nn = 60;
    int nd = 15;
    int v = 90;
    Note note = new Note(synth, mouseX, mouseY, ch, nn, v, nd);
    setProgram(ch, program);
    note.setMessage(synth.getLoadedInstruments()[program].getName());
    addNote(note);
  }
  
  mousePressX = -1;
}

void recordNote(Note note, long noteDuration) {
  if (recording) {
    //println("PRESS", noteDuration);
    float ticksPerQuarterNote = sequence.getResolution(); // Get ticks per quarter note
    //float divisionType = sequence.getDivisionType();
    int stepsPerQuarterNote = 4; // For example, if your sequence is divided into 4 steps per quarter note
    float ticksPerStep = ticksPerQuarterNote / stepsPerQuarterNote; 
    long tick = (long)(currentStep * ticksPerStep);
    if (sequencer.isRunning())
      tick = lastPressTick;
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

void keyPressed() {
  int ch = constrain((int)map(mouseY, 0, padHeight, 0, NUM_CHANNELS), 0, 15);
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
    Note note = new Note(synth, width/2, ch * padHeight/NUM_CHANNELS + padHeight/NUM_CHANNELS/2, ch, 60, 100, 30);
    note.setMessage(ci.instrumentName);  
    addNote(note);
  }
  
  if (keyCode == UP) {
    currentTrack--;
    if (currentTrack < 0)
      currentTrack = NUM_TRACKS;
  }
  
  if (keyCode == DOWN) {
    currentTrack++;
    if (currentTrack > NUM_TRACKS)
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
    Note note = new Note(synth, width/2, ch * padHeight/NUM_CHANNELS + padHeight/NUM_CHANNELS/2, ch, 60, 100, 30);
    note.setMessage(ci.instrumentName);  
    addNote(note);
  }
  
  if (key == 'b') {
    int nn = getNote(mouseX);
    int nd = (int)random(30, 150);
    int v = 100;
    Note note = new Bounce(synth, mouseX, mouseY, ch, nn, v, nd);
    addNote(note);
  }
  
  if (key == 'r') {
      recording = true;
  }
  
  if (key == 's') {
      recording = false;
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
  if (synth != null) {
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
      println("SetProgram:", channel, programNumber);
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
  } catch (InvalidMidiDataException e) {
    e.printStackTrace();
  }
}

void playMidiSequence() {
  if (sequencer != null && sequence != null) {
    try {
      sequencer.setSequence(sequence);
      sequencer.setLoopCount(Sequencer.LOOP_CONTINUOUSLY); // Loop the sequence continuously
      sequencer.start();
    } catch (InvalidMidiDataException e) {
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
