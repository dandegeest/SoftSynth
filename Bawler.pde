class Bawler extends Synestrument {

  String[] noteNames = {"C", "G", "D", "A", "E", "B", "F#", "Db", "Ab", "Eb", "Bb", "F"};
  int[] notes = {48, 67, 62, 69, 64, 71, 66, 61, 68, 63, 70, 65};
  
  ArrayList<Bounce> bawls = new ArrayList<Bounce>();
  
  Bawler(float x, float y, int w, int h) {
    super(x, y, w, h);
  }
  
  String name() { return "BaWler"; }
  int getChannel() {
    return constrain((int)map(mouseY, 0, height, 0, NUM_CHANNELS), 0, NUM_CHANNELS-1);
  }  
  
  int getNote(int pos) {
    int note = (int)map(pos, 0, height/NUM_NOTES * NUM_NOTES, START_NOTE, END_NOTE);
    return note;
  }
  
  void display() {
    drawBawls();
  }
  
  void drawBawls() {
    ArrayList<Bounce> bawlsDone = new ArrayList<Bounce>();
    for (int i = 0; i < bawls.size(); i++) {
      Bounce b = bawls.get(i);
      b.update();
      b.display();
      if (b.delay == 0) {
        bawlsDone.add(b);
        stopNote(b);
      }
    }
    
    bawls.removeAll(bawlsDone);
  }
  
  boolean onKeyPressed() {
    return false;
  }
  
  void onLeftMousePressed() {
    int nn = getNote(mouseY);
    int nd = (int)random(30, 150);
    int v = 100;
    Bounce bawl = new Bounce(synth, mouseX, mouseY, getChannel(), nn, v, nd);
    bawls.add(bawl);
    addNote(bawl);
    //recordNote(note, 1);
  }
  
  void onLeftMouseDragged() {

  } 
}
