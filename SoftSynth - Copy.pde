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
//String[] instrumentNames = new String[NUM_CHANNELS];

//Sequencer
final int NUM_STEPS = 32;
final int NOTE_VELOCITY = 100;

// MIDI variables
Sequence sequence;
Sequencer sequencer;
Track track1;
final int START_NOTE = 24;
final int END_NOTE = 95;

//Pad
DashedLines dash;
float dashDist = 0;
int padHeight = height - 100;
int currS = 0;
int currY = 0;
int gridX = 0;
int gridY = 0;

//Palette
int bgColor = color(174,243,224); //#AEF3E0;
int txtColor = color(174 * .2,243 * .2,224 * .2);
int txt2Color = color(136,203,162); //#88CBA2;
int chColor = color(223,181,227); //#DFB5E3;
int nnColor = color(255,32,156); //#FF209C
int nn1Color = #7DF9FF;

//Interaction
int lastPress;

//Serial COM
Serial sPort;
float knock = 0;
String message;

//Sequence
int currentStep = 0;
boolean recording = false;

ArrayList<Note> notes = new ArrayList<Note>();

void setup() {
  size(128 * 10, 50 * 16); // (END_NOTE - START_NOTE) * 15, 50 * NUM_CHANNELS
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
  
  int channel = 0;
  boolean activeChannel = false;
  for (int y = 0; y < height; y += height/NUM_CHANNELS) {
    if (channel == NUM_CHANNELS)
      break;
    pushStyle();
    strokeWeight(1);
    stroke(chColor);
    fill(chColor, 200);
    activeChannel = mouseY >= y && mouseY <= y + height/NUM_CHANNELS;
    if (activeChannel) {
      //Fill in the active channel
      rect(0, y, width, height/NUM_CHANNELS);
    }
    if (mousePressed || keyPressed || activeChannel) {
      line(0, y, width, y);
      //Instrument Name
      fill(txtColor);
      textAlign(LEFT);
      textSize(20);
      text(channelInfo.get(channel).instrumentName, 5, y + 5, width-5, height/NUM_CHANNELS);
    }
    channel++;
    //dash.line(x, 0, x, height);
    popStyle();
  }
  
  int division = key == 'a' ? NUM_INSTRUMENTS : 70;

  //Current Cell
  pushStyle();
  noStroke();
  fill(lerpColor(nn1Color, nnColor, map(mouseX, 0, width, 0, 1)), 200);
  rect(mouseX - (mouseX % (width/division)), mouseY - (mouseY % (height/NUM_CHANNELS)), width/division, height/NUM_CHANNELS);
  popStyle();
  
  if (mousePressed || keyPressed || activeChannel) {
    pushStyle();
    dash.pattern(1, 5);
    strokeWeight(1.5);
    for (int x = 0; x < width; x += width/division) {
      strokeWeight(1);
      stroke(#FF209c);
      //line(x, 0, x, height);
      dash.line(x, 0, x, height);
      dash.offset(dashDist);
      dashDist += 1;
    }
    popStyle();
  }

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

void mouseDragged() 
{
  int ch = constrain((int)map(mouseY, 0, height, 0, NUM_CHANNELS), 0, 15);

  if (mouseButton == RIGHT) {
    int pitchBendValue = floor(map(mouseX, 0, width, -8192, 8191)); // Change this to the desired pitch bend value (-8192 to 8191)
    synth.getChannels()[ch].setPitchBend(pitchBendValue);
    return;
  }
    
  int nn = (int)map(mouseX, 0, width, START_NOTE, END_NOTE);
  int v = constrain(abs(mouseX - pmouseX) * 2, 50, 127);
  Note note = new Note(synth, mouseX, mouseY, ch, nn, v, abs(mouseX - pmouseX) * 4);//(int)random(15,30));
  addNote(note);
}

void mousePressed() {
  lastPress = millis();
}

void mouseReleased() {
}

void mouseClicked() {
  int press = millis() - lastPress;
  int program = (int)map(mouseX, 0, width/NUM_INSTRUMENTS * NUM_INSTRUMENTS, 0, NUM_INSTRUMENTS);
  int ch = constrain((int)map(mouseY, 0, height, 0, NUM_CHANNELS), 0, 15);
  int nn = mouseButton == RIGHT ? 60 : (int)map(mouseX, 0, width, START_NOTE, END_NOTE);
  int nd = mouseButton == RIGHT ? 15 : floor(press * .5);
  int v = constrain(80 + floor(press / 10), 80, 127);
  Note note = new Note(synth, mouseX, mouseY, ch, nn, v, nd);

  if (mouseButton == RIGHT) {
    setProgram(ch, program);
    note.setMessage(synth.getLoadedInstruments()[program].getName());
  }
    
  addNote(note);
}

void keyPressed() {
  int ch = constrain((int)map(mouseY, 0, height, 0, NUM_CHANNELS), 0, 15);
  ChannelInfo ci = channelInfo.get(ch);
  if (keyCode == LEFT) {
    int i = ci.instrumentIndex - 1;
    if (i < 0) i = 127;
    setProgram(ch, i);
    Note note = new Note(synth, width/2, ch * height/NUM_CHANNELS + height/NUM_CHANNELS/2, ch, 60, 100, 30);
    note.setMessage(ci.instrumentName);  
    addNote(note);
  }
  
  if (keyCode == RIGHT) {
    int i = ci.instrumentIndex + 1;
    if (i > 127) i = 0;
    setProgram(ch, i);
    Note note = new Note(synth, width/2, ch * height/NUM_CHANNELS + height/NUM_CHANNELS/2, ch, 60, 100, 30);
    note.setMessage(ci.instrumentName);  
    addNote(note);
  }
  
  if (key == 'b') {
    int nn = (int)map(mouseX, 0, width, START_NOTE, END_NOTE);
    int nd = (int)random(30, 150);
    int v = 100;
    Note note = new Bounce(synth, mouseX, mouseY, ch, nn, v, nd);
    addNote(note);
  }
  
  if (key == 'r') {
    recording = true;
    sequencer.stop();
  }
  
  if (key == 'p') {
    playMidiSequence();
  }

  if (keyCode == ENTER) {
    saveFrame("frames\\softSynth#####.png");
  }
}

void addNote(Note note) {
    notes.add(note);
    note.play();
    
    if (recording) {
      float ticksPerQuarterNote = sequence.getResolution(); // Get ticks per quarter note
      float divisionType = sequence.getDivisionType();
      println("DV", divisionType);
      int stepsPerQuarterNote = 4; // For example, if your sequence is divided into 4 steps per quarter note
      float ticksPerStep = ticksPerQuarterNote / stepsPerQuarterNote;
      
      long tick = (long)(currentStep * ticksPerStep);
      println("AddSEQ:",  currentStep, tick, note.note);
      MidiEvent e = createNoteOnEvent(note.channel, note.note, note.volume, tick);
      track1.add(e);
      track1.add(createNoteOffEvent(note.channel, note.note, 0, Math.round(tick + ticksPerStep)));
      currentStep++;
    }
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
    track1 = sequence.createTrack();
  } catch (InvalidMidiDataException e) {
    e.printStackTrace();
  }
}

MidiEvent createNoteOnEvent(int channel, int note, int velocity, long tick) {
  try {
    ShortMessage message = new ShortMessage();
    message.setMessage(ShortMessage.NOTE_ON, channel, note, velocity);
    return new MidiEvent(message, tick);
  } catch (InvalidMidiDataException e) {
    e.printStackTrace();
    return null;
  }
}

MidiEvent createNoteOffEvent(int channel, int note, int velocity, long tick) {
  try {
    ShortMessage message = new ShortMessage();
    message.setMessage(ShortMessage.NOTE_OFF, channel, note, velocity);
    return new MidiEvent(message, tick);
  } catch (InvalidMidiDataException e) {
    e.printStackTrace();
    return null;
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
