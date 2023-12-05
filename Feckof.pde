class Feckof extends Synestrument {
  int segments = 12;
  float radius = 150;
  float angleIncrement = TWO_PI / segments;
  int dir = 1;
  int octave = 0;
  int octaveDisplay = 255;
  Note mouseNote;

  String[] noteNames = {"C", "G", "D", "A", "E", "B", "F#", "Db", "Ab", "Eb", "Bb", "F"};
  int[] notes = {48, 67, 62, 69, 64, 71, 66, 61, 68, 63, 70, 65};
  
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
  
  String getNoteName(int n) {
    for (int i = 0; i < segments; i++) {
      if (notes[i] == n) return noteNames[i];
    }
    return "";
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
      text(getNoteName(n.note), n.position.x - 50, n.position.y-50, 100, 100);
      popStyle();
    }
    
    for (int i = 0; i < 6; i++) {
      //Octave bars
      pushStyle();
      stroke(0);
      fill(synthwavePalette[i], 255);
      noStroke();
      rect(0, i * height/6, 200, height/6, 12);
      rect(width - 200, i * height/6, 200, height/6, 12);     
      popStyle();
    }
    
    // Current octave
    // Chord or note mode?
    if (octaveDisplay > 0) {      
      pushStyle();
      noStroke();
      ellipseMode(CENTER);

      for (int i = 0; i < 6; i++) {
        if (i <= map(octave, -20, 30, 0, 5))
          fill(synthwavePalette[1], octaveDisplay);
        else
          fill(white, octaveDisplay);
        ellipse(width/2 + i * 20 - 60, height/2 - 8, 16, 16);
      }
      
      fill(white, octaveDisplay);
      for (int i = 0; i < 3; i++) {
        ellipse(width/2, height/2 + i * 20 - 50, 16, 16);
        if (key == '1') {
          break;
        }
      }

      octaveDisplay -= 5;
      popStyle();
    }
  }
  
  void initCof() {
    for (int i = 0; i < segments; i++) {
      float angle = -HALF_PI + angleIncrement * i; // Start from 12 o'clock position
      float x = cos(angle) * radius + width/2;
      float y = sin(angle) * radius + height/2;
      
      circle.add(new Note(synth, x, y, 0, notes[i], 100, 100));
    }
  }
  
  boolean onKeyPressed() {
    if (key == '1')
      octaveDisplay = 255;
      
    return false;
  }
  
  void onLeftMousePressed() {
    for (int i = 0; i < circle.size(); i++) {
      Note cn = circle.get(i);
      if (cn.mouseIn()) {
        int[] chord = new int[3];
        chord[0] = i % segments;
        chord[1] = (i+1) % segments;
        chord[2] = (i+4) % segments;   
        //println(noteNames[chord[0]],noteNames[chord[1]],noteNames[chord[2]]);
        for (int n = 0; n < (key == '1' ? 1 :chord.length); n++) {
          Note note = circle.get(chord[n]);
          int nd = 100;
          int v = 100;
          Note nn = new Note(synth, mouseX, mouseY, note.channel, note.note + octave, v, nd);
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
    if (mouseX <= 200 || mouseX > width - 200) {
      for (int i = 0; i < 6; i++) {
        if (mouseY > i * height/6 &&
            mouseY < (i == 5 ? height : (i + 1) * height/6)) {
              octave = (int)map(i, 0, 5, -20, 30);
              octaveDisplay = 255;
            }
      }
    }
    
    
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
        for (int n = 0; n < (key == '1' ? 1 :chord.length); n++) {
          Note note = circle.get(chord[n]);
          int nd = constrain((int)dist(mousePressX, mousePressY, mouseX, mouseY), 15, 100);
          int v = constrain((int)dist(mousePressX, mousePressY, mouseX, mouseY), 0, 127);
          Note nn = new Note(synth, mouseX, mouseY, note.channel, note.note + octave, v, nd);
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
