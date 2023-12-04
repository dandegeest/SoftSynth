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
  
  int getChannel() {
    if (mouseBezString != null) {
      return bezStrings.indexOf(mouseBezString);
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
  
  void onLeftMouseMoved() {
    if (mouseBezString != null) {
    }
  }
  
  void onLeftMouseDragged() {
    for (int i = 0; i < bezStrings.size(); i++) {
      BeztarString bezs = bezStrings.get(i);
      
      if (bezs.mouseIn() && i != lastString) {
        mouseBezString = bezs;
        mouseBezString.clicked(mouseX, mouseY);
        
        int ch = getChannel();
        int nn = getNote(mouseY);//(int)bezs.position.x);
        println("BZ:Note", nn, ch);
        int nd = 100;
        int v = 100;
        Note note = new Note(synth, mouseX, mouseY, ch, nn, v, nd);
        addNote(note);
        lastString = i;
        break;
      }
    }  
  }  
}
