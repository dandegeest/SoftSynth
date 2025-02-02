final int OCTAVE = 12;

class Note extends Sprite {
  Synthesizer synth;
  int channel;
  int ogNote;
  int note;
  int volume;
  long delay;
  long initialDelay;
  int repeat;
  int decay = -OCTAVE;
  color noteColor = 0;
  
  PopupMessage pm;
  
  Note(Synthesizer s, float x, float y, int c, int n, int v, int d) {
    super(x, y, d, d);
    synth = s;
    channel = c;
    ogNote = note = n;
    volume = v;
    initialDelay = delay = d;
    repeat = 0;
  }
  
  boolean mouseIn() {
    if (mouseX >= position.x - width/2 &&
      mouseX <= position.x + width/2 &&
      mouseY >= position.y - height/2 &&
      mouseY <= position.y + height/2)
      return true;

    return false;
  }
  
  void setMessage(String msg) {
    //pm = new PopupMessage(position.x + delay/2 - 100, position.y + delay/2 - 25, msg, delay/2);
    pm = new PopupMessage(position.x, position.y, msg, (int)delay);
  }
  
  void play() {
    if (synth != null) {
      //println("NoteOn:CH:"+channel+" N:"+note+" V:"+volume);
      synth.getChannels()[channel].noteOn(note, volume);
    }
    if (receiver != null) {
      try {
        ShortMessage noteOnMessage = new ShortMessage();
        noteOnMessage.setMessage(ShortMessage.NOTE_ON, channel, note, volume);
        receiver.send(noteOnMessage, -1);
        //println("NOTE ON", note, channel, device);
      } 
      catch (InvalidMidiDataException e) {
        e.printStackTrace();
      }
    }
  }
  
  void stop() {
    if (synth != null) {
      synth.getChannels()[channel].noteOff(note);
    }
    if (receiver != null) {
      try {
        ShortMessage noteOffMessage = new ShortMessage();
        noteOffMessage.setMessage(ShortMessage.NOTE_OFF, channel, note, 0);
        receiver.send(noteOffMessage, -1);
      } 
      catch (InvalidMidiDataException e) {
        e.printStackTrace();
      }
    }
  }
  
  void update() {
    if (delay > 0) {
      if (repeat > 0 && delay % repeat == 0) {
        stop();
        note += decay;
        if (note == ogNote - OCTAVE || note == ogNote + OCTAVE)
          decay = -(decay);         
        
        volume -= 3;
        play();
      }
      delay--;
    }
    
    if (pm != null) pm.update();
  }
  
  void display() {
    pushStyle();
    ellipseMode(CENTER);
    color c = noteColor;
    if (noteColor == 0)
      c = lerpColor(nn1Color, nnColor, map(note, START_NOTE, END_NOTE, 0, 1));
    
    stroke(c, map(delay, 0, initialDelay, 0, 255));
    if (delay > 200) {
      strokeWeight(2);
      noFill();
    }
    else
      fill(c, map(delay, 0, initialDelay, 0, 255));
      
    ellipse(position.x, position.y, delay, delay);
    if (pm != null) pm.display();
    
    if (mouseIn() && volume != -1) {
      fill(white);
      textAlign(CENTER,CENTER);
      text(""+volume, position.x - delay/2, position.y-10, delay, 20);
    }
    popStyle();
  }
}
