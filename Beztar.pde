class Beztar extends Synestrument {
  ArrayList<BeztarString> bezStrings = new ArrayList<BeztarString>();
  
  int numStrings = NUM_CHANNELS;
  int holdCount = 0;
  int lastString = -1;
  BeztarString mouseBezString;
  
  Beztar(float x, float y, int w, int h) {
    super(x, y, w, h);
    initStrings();
  }
  
  String name() { return "BeZtar"; }

  int getChannel() {
    if (mouseBezString != null) {
      return bezStrings.indexOf(mouseBezString);
    }
  
    for (int i = 0; i < bezStrings.size(); i++) {
      BeztarString bezs = bezStrings.get(i);
      if (bezs.mouseIn()) {
        return i;
      }
    }
    
    return 0;
  }
  
  int getNote(int pos) {
    int note = (int)map(pos, 0, height/NUM_NOTES * NUM_NOTES, START_NOTE, END_NOTE);
    return note;
  }
  
  void display() {
    if (mouseBezString != null) {}
  
    for (int i = 0; i < bezStrings.size(); i++) {
      BeztarString dot = bezStrings.get(i);
      dot.update();
    }
  
    for (int i = 0; i < bezStrings.size(); i++) {
      bezStrings.get(i).display();
    }
  }
  
  void initStrings() {
    for (int i = 0; i < numStrings; i++) {
      int x = (int)map(i, 0, numStrings, 0, width + 40);
      BeztarString dot = new BeztarString(x + 20, 20, 40);
      BeztarString anchor = new BeztarString(x + 20, height - 20, 40);
      dot.setAnchor(anchor);
      bezStrings.add(dot);
      //bezStrings.add(anchor);
    }
  }
  
  void onLeftMousePressed() {
    if (mouseBezString != null) {
      mouseBezString = null;
    }   
  }
  
  void onLeftMouseDragged() {
    for (int i = 0; i < bezStrings.size(); i++) {
      BeztarString bezs = bezStrings.get(i);
      
      if (bezs.mouseIn()) {
        mouseBezString = bezs;
        if (i == lastString)
          return;
        
        int ch = getChannel();
        int nn = getNote(mouseY);//(int)bezs.position.x);
        if (isNaturalNote(nn)) {
          int tm = millis() - mousePressMillis;
          int nd = 100;
          int v = tm % 127;
          Note note = new Note(synth, mouseX, mouseY, ch, nn, v, nd);
          addNote(note);
          recordNote(note, (long)constrain(tm/(long)calculateMillisecondsPerTick(), 1, 32 - currentStep));
        }
        lastString = i;
        return;
      }      
    }
    
    mouseBezString = null;
    lastString = -1;
  }  
}
