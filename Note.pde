class Note extends Sprite {
  Synthesizer synth;
  int channel;
  int note;
  int volume;
  long delay;
  long initialDelay;
  
  PopupMessage pm;
  
  Note(Synthesizer s, float x, float y, int c, int n, int v, int d) {
    super(x, y, d, d);
    synth = s;
    channel = c;
    note = n;
    volume = v;
    initialDelay = delay = d;
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
    //println("NoteOn:CH:"+channel+" N:"+note+" V:"+volume);
    synth.getChannels()[channel].noteOn(note, volume);
  }
  
  void stop() {
    synth.getChannels()[channel].noteOff(note);
  }
  
  void update() {
    if (delay > 0) {
      delay--;
    }
    
    if (pm != null) pm.update();
  }
  
  void display() {
    ellipseMode(CENTER);
    stroke(lerpColor(nn1Color, nnColor, map(note, START_NOTE, END_NOTE, 0, 1)), map(delay, 0, initialDelay, 0, 255));
    if (delay > 200) {
      strokeWeight(2);
      noFill();
    }
    else
      fill(lerpColor(nn1Color, nnColor, map(note, START_NOTE, END_NOTE, 0, 1)), map(delay, 0, initialDelay, 0, 255));
    ellipse(position.x, position.y, delay, delay);
    if (pm != null) pm.display();
  }
}
