class Feckof extends Synestrument {
  int segments = 12;
  float radius = 150;
  float angleIncrement = TWO_PI / segments;
  int dir = 1;
  Note mouseNote;

  String[] noteNames = {"C", "G", "D", "A", "E", "B", "F#", "Db", "Ab", "Eb", "Bb", "F"};
  int[] notes = {60, 67, 62, 69, 64, 71, 66, 61, 68, 63, 70, 65};
  
  ArrayList<Note> circle = new ArrayList<Note>();
  
  Feckof(float x, float y, int w, int h) {
    super(x, y, w, h);
    radius = (h - 200)/2;
    initCof();
  }
  
  String name() { return "FekCOF"; }
  int getChannel() {
     return 0;
  }
  
  int getNote(int pos) {
    int note = (int)map(pos, 0, height/NUM_NOTES * NUM_NOTES, START_NOTE, END_NOTE);
    return note;
  }
  
  void display() {
    for (int i = 0; i < circle.size(); i++) {
      Note n = circle.get(i);
      //n.update();
      if (n.delay > 110)
        dir = -1;
      else if (n.delay < 90)
        dir = 1;
      n.delay += dir;
      
      n.display();
      pushStyle();
      fill(white, 128);
      textSize(36);
      textAlign(CENTER, CENTER);
      text(noteNames[i], n.position.x - 50, n.position.y-50, 100, 100);
      popStyle();
    }
  }
  
  void initCof() {
    for (int i = 0; i < segments; i++) {
      float angle = -HALF_PI + angleIncrement * i; // Start from 12 o'clock position
      float x = cos(angle) * radius + width/2;
      float y = sin(angle) * radius + height/2;
      
      circle.add(new Note(synth, x, y, i, notes[i], 100, 100));
    }
  }
  
  void onLeftMousePressed() {
    for (int i = 0; i < circle.size(); i++) {
      Note cn = circle.get(i);
      if (cn.mouseIn()) {
        if (cn == mouseNote)
          return;
          
        int[] chord = new int[3];
        chord[0] = i % segments;
        chord[1] = (i+1) % segments;
        chord[2] = (i+4) % segments;   
        //println(noteNames[chord[0]],noteNames[chord[1]],noteNames[chord[2]]);
        for (int n = 0; n < chord.length; n++) {
          Note note = circle.get(chord[n]);
          int nd = (int)cn.delay;
          int v = 100;
          Note nn = new Note(synth, mouseX, mouseY, note.channel, note.note, v, nd);
          addNote(nn);
          recordNote(nn, 1);
        }
        
        mouseNote = cn;
        return;
      }
    }
    mouseNote = null;
  }
  
  void onLeftMouseDragged() {
    for (int i = 0; i < circle.size(); i++) {
      Note cn = circle.get(i);
      if (cn.mouseIn()) {
        if (cn == mouseNote)
          return;
          
        int tm = millis() - mousePressMillis;
        int[] chord = new int[3];
        chord[0] = i % segments;
        chord[1] = (i+1) % segments;
        chord[2] = (i+4) % segments;   
        //println(noteNames[chord[0]],noteNames[chord[1]],noteNames[chord[2]]);
        for (int n = 0; n < chord.length; n++) {
          Note note = circle.get(chord[n]);
          int nd = 30;
          int v = constrain((int)dist(mousePressX, mousePressY, mouseX, mouseY), 0, 127);
          Note nn = new Note(synth, mouseX, mouseY, note.channel, note.note, v, nd);
          addNote(nn);
          recordNote(nn, (long)constrain(tm/(long)calculateMillisecondsPerTick(), 1, 32 - currentStep));
        }
        
        mouseNote = cn;
        return;
      }
    }
    mouseNote = null;
  } 
}
