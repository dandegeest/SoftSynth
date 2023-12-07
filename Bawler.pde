class Bawler extends Synestrument {
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
    if (mouseButton == LEFT) {
      syns.get(KEYANO).setNaturalOnly(true);
      syns.get(KEYANO).display();
    }
    else {
    int nn = getNote(mouseX);
      if (isNaturalNote(nn)) {
        pushStyle();
        noStroke();
        fill(lerpColor(nn1Color, nnColor, map(nn, START_NOTE, END_NOTE, 0, 1)));
        ellipseMode(CENTER);
        ellipse(mouseX, mouseY, 16, 16);
        popStyle();
      }
    }
  }
  
  boolean onKeyPressed() {
    return false;
  }
  
  void onLeftMouseReleased() {
    int nn = getNote(mouseX);
    if (!isNaturalNote(nn))
      return;
    int nd = ceil((millis() - mousePressMillis) * frameRate/100);
    int v = 80;
    Bawl bawl = new Bawl(synth, mouseX, mouseY, getChannel(), nn, v, nd);
    addNote(bawl);
    //recordNote(note, 1);
  }
  
  void onLeftMouseDragged() {
  } 
}
