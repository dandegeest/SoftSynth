class Bawler extends Synestrument {

  String[] noteNames = {"C", "G", "D", "A", "E", "B", "F#", "Db", "Ab", "Eb", "Bb", "F"};
  int[] notes = {48, 67, 62, 69, 64, 71, 66, 61, 68, 63, 70, 65};
  
  ArrayList<Bawl> bawls = new ArrayList<Bawl>();
  
  Bawler(float x, float y, int w, int h) {
    super(x, y, w, h);
  }
  
  String name() { return "BaWler"; }
  int getChannel() {
    return constrain((int)map(mouseY, 0, height, 0, NUM_CHANNELS), 0, NUM_CHANNELS-1);
  }  
  
  int getNote(int pos) {
    int note = (int)map(pos, 0, width/NUM_NOTES * NUM_NOTES, START_NOTE, END_NOTE);
    return note;
  }
  
  void display() {
    drawBawls();
  }
  
  void drawBawls() {
    ArrayList<Bawl> bawlsDone = new ArrayList<Bawl>();
    for (int i = 0; i < bawls.size(); i++) {
      Bawl b = bawls.get(i);
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
    int nn = getNote(mouseX);
    int nd = (int)random(30, 150);
    int v = 100;
    Bawl bawl = new Bawl(synth, mouseX, mouseY, getChannel(), nn, v, nd);
    bawls.add(bawl);
    addNote(bawl);
    //recordNote(note, 1);
  }
  
  void onLeftMouseDragged() {

  } 
}
