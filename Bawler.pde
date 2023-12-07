class Bawler extends Synestrument {
  int mouseMove = 0;
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
    int m = (int)dist(pmouseX, pmouseY, mouseX, mouseY);
    if (m > 0)
      mouseMove = max(30, mouseMove);
    if (mouseButton == LEFT || mouseButton == RIGHT || mouseMove > 0) {
      mouseMove--;
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
    int v = 75;
    Bawl bawl = new Bawl(synth, mouseX, mouseY, getChannel(), nn, v, nd);
    addNote(bawl);
    //recordNote(note, 1);
  }
  
  void onRightMouseReleased() {
    int nn = getNote(mouseX);
    if (!isNaturalNote(nn))
      return;
    int nd = ceil((millis() - mousePressMillis) * frameRate/100);
    int v = 75;
    int cof = findCoF(nn);
    int[] chord = new int[3];
    chord[0] = nn;
    chord[1] = nn;
    chord[2] = nn;   

    if (cof != -1) {
      //Make a chord
      chord[0] = nn;
      chord[1] = circleOF[(cof+1) % 12];
      chord[2] = circleOF[(cof+4) % 12];   
      //println("COF:", cof, chord);
     }
    for (int i = 0; i < chord.length; i++) {
      Bawl bawl = new Bawl(synth, mouseX, mouseY, getChannel(), chord[i], v, nd);
      v-=5;
      addNote(bawl);
    }
    //recordNote(note, 1);
  }

  void onLeftMouseDragged() {
  } 
}
