void initMidi() {
  MidiDevice.Info[] infos = MidiSystem.getMidiDeviceInfo();
  
  printArray(infos);

  for (MidiDevice.Info info : infos) {
    try {
      midiDevice = MidiSystem.getMidiDevice(info);
      midiDevice.open();
      
      if (midiDevice instanceof Synthesizer) {
        synth = (Synthesizer) midiDevice;
        println("Using Synthesizer", info);
        //printArray(synth.getLoadedInstruments());
        break;
      }
      else midiDevice.close();
    } catch (MidiUnavailableException e) {
      e.printStackTrace();
    }
  }

  try {
    sequencer = MidiSystem.getSequencer();
    sequencer.open();
  } catch (MidiUnavailableException e) {
    e.printStackTrace();
  }  
}

void initSerial() {
  printArray(Serial.list());
  int comPort = -1;
  String[] ports = Serial.list();
  for (int i = 0; i < ports.length; i++) {
    if (ports[i].equals("COM6")) {
      comPort = i;
      break; // If found, exit the loop
    }
  }
  
  if (comPort > 0) {
    println("OpenCOMPort:", Serial.list()[comPort]);
    sPort = new Serial(this, Serial.list()[comPort], 9600);
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

MidiEvent createProgramChangeEvent(int channel, int instrument, long tick) {
  try {
    ShortMessage message = new ShortMessage();
    message.setMessage(ShortMessage.PROGRAM_CHANGE, channel, instrument, 0);
    return new MidiEvent(message, tick);
  } catch (InvalidMidiDataException e) {
    e.printStackTrace();
    return null;
  }
}

// Method to iterate over a sequence and get notes at each step
int getNoteAtStep(Sequence seq, int trackNumber, int step) {
  if (seq != null) {
    Track track = seq.getTracks()[trackNumber]; // Get the specified track

    for (int i = 0; i < track.size(); i++) {
      MidiEvent event = track.get(i);
      if (event.getTick() == step) {
        MidiMessage message = event.getMessage();
        if (message instanceof ShortMessage) {
          ShortMessage sm = (ShortMessage) message;
            int command = sm.getCommand();
            int note = sm.getData1();
            int velocity = sm.getData2();
            // Check if it's a note-on event
            if (command == ShortMessage.NOTE_ON && velocity != 0) {
              return note;
          }
        }
      }
    }
  }
  
  return 0;
}

void finalizeSequence(Sequence seq, int trackNumber) {
  // Add rest notes to end of sequence to make it 32 steps
  if (seq != null) {
    Track track = seq.getTracks()[trackNumber]; // Get the specified track
    int totalTicks = (int) seq.getTickLength(); // Total ticks in the sequence
    if (totalTicks < 32) {
      for (int t = totalTicks; t < 32; t++) {
        track.add(createNoteOffEvent(0, 0, 0, t));
      }
    }
  }  
}

double calculateMillisecondsPerTick() {
  if (sequencer != null) {
    long microseconds = sequencer.getMicrosecondLength();
    long ticks = sequencer.getTickLength();
  
    if (ticks != 0) {
        return (microseconds / 1000.0) / ticks; // Calculate milliseconds per tick
    }
  }
  
  return -1; // Return -1 if the sequencer or tick length is not available
}

boolean isNaturalNote(int midiNoteNumber) {
    int note = midiNoteNumber % 12; // Get the note number within an octave

    // Check if the MIDI note number corresponds to a natural note (C, D, E, F, G, A, or B)
    return note == 0 || note == 2 || note == 4 || note == 5 || note == 7 || note == 9 || note == 11;
}

int lerpColor(int colorStart, int colorEnd, float amount) {
  float lerpedR = lerp(red(colorStart), red(colorEnd), amount);
  float lerpedG = lerp(green(colorStart), green(colorEnd), amount);
  float lerpedB = lerp(blue(colorStart), blue(colorEnd), amount);  
  return color(lerpedR, lerpedG, lerpedB);
}
