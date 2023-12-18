class Keyano extends Synestrument {
  Note currentNote;
  int activeChannelY = 0;
  int division;
  boolean activeChannel = false;
  boolean naturalOnly = false;
    
  Keyano(float x, float y, int w, int h) {
    super(x, y, w, h);
  }

  String name() { return "Keyano"; }

  void setNaturalOnly(boolean no) {
    naturalOnly = no;
  }
  
  boolean padVisible() {
    return true;
  }
  
  int getChannel() {
    return constrain((int)map(mouseY, 0, height, 0, NUM_CHANNELS), 0, 15);
  }
  
  int getNote(int pos) {
    int note = (int)map(pos, 0, width/NUM_NOTES * NUM_NOTES, START_NOTE, END_NOTE);
    return note;
  }
  
  void display() {
    division = mouseButton == RIGHT && !naturalOnly ? NUM_INSTRUMENTS : NUM_NOTES;    
    drawGrid();   
    //Current Cell
    if (mouseY < height) {
      int nn;
      if (mouseButton == RIGHT && !naturalOnly) {
        textSize(14);
        nn = (int)map(mouseX, 0, width/NUM_INSTRUMENTS * NUM_INSTRUMENTS, 0, NUM_INSTRUMENTS);
      }
      else
        nn = getNote(mouseX);
      
      if (!naturalOnly || isNaturalNote(nn)) {
        pushStyle();
        noStroke();
        fill(lerpColor(nn1Color, nnColor, map(mouseX, 0, width, 0, 1)));
        rect(mouseX - (mouseX % (width/division)), mouseY - (mouseY % (height/NUM_CHANNELS)), width/division, height/NUM_CHANNELS);
        fill(txtColor);
        textSize(14);
        text(""+nn, mouseX - (mouseX % (width/division)), mouseY - (mouseY % (height/NUM_CHANNELS)), width/division, height/NUM_CHANNELS);
        popStyle();
      }
    }
  }
  
  void drawGrid() {
    int channel = 0;
    for (int y = 0; y < height; y += height/NUM_CHANNELS) {
      if (channel == NUM_CHANNELS)
        break;
      pushStyle();
      activeChannel = mouseY >= y && mouseY <= y + height/NUM_CHANNELS;
      if (!padVisible() && activeChannel)
        activeChannelY = y;
        if (activeChannel && (mouseButton != RIGHT || naturalOnly)) {
          //Fill in the active channel
          pushStyle();
          for (int x = 0; x < width; x += width/NUM_NOTES) {
            noStroke();
            int n = getNote(x);
            if (isNaturalNote(n))
              fill(white, 210);
            else
              fill(black,naturalOnly ? 0 : 210);
            rect(x, y, width/NUM_NOTES, height/NUM_CHANNELS);
          }
        popStyle();    
      }
      
      strokeWeight(1);
      stroke(chColor);

      if (padVisible() || activeChannel) {
        line(0, y, width, y);
        noStroke();
        fill(synthwavePalette[2]);
        rect(2, y + 2, 150, 20, 6);
        //Instrument Name
        fill(txtColor);
        textAlign(LEFT);
        textSize(20);
        text(channelInfo.get(channel).instrumentName, 5, y + 5, 150, 20);
      }
      popStyle();
      channel++;
    }
    
    if (padVisible() || activeChannelY > 0) {
      pushStyle();
      dash.pattern(1, 5);
      strokeWeight(1);
      stroke(chColor);
      for (int x = 0; x < width; x += width/division) {
        dash.line(x, activeChannelY, x, padVisible() ? height : activeChannelY + height/NUM_CHANNELS);
        //dash.offset(dashDist);
        dashDist += 1;
      }
      popStyle();
    }
  }

  void onLeftMousePressed() {
    //Select Note
    int ch = getChannel();
    int nn = getNote(mouseX);
    int nd = 100;
    int v = 90;
    currentNote = new Note(synth, mouseX, mouseY, ch, nn, v, nd);
    addNote(currentNote);
  }
  
  void onLeftMouseReleased() {
    if (currentNote != null) {
      currentNote.stop();
      //synth.getChannels()[currentNote.channel].setPitchBend(8191);
      recordNote(currentNote, getCurrentDuration());
    }    
  }
  
  void onLeftMouseDragged() {
    int ch = getChannel();  
    int nn = getNote(mouseX);
    int v = constrain((int)dist(pmouseX, pmouseY, mouseX, mouseY) * 2, 50, 100);
    Note note = new Note(synth, mouseX, mouseY, ch, nn, v, abs(mouseX - pmouseX) * 2);
    addNote(note);
  }
  
  void onRightMouseReleased() {
    int program = (int)map(mouseX, 0, width/NUM_INSTRUMENTS * NUM_INSTRUMENTS, 0, NUM_INSTRUMENTS);
    int ch = getChannel();
    int nn = 60;
    int nd = 15;
    int v = 90;
    Note note = new Note(synth, mouseX, mouseY, ch, nn, v, nd);
    setProgram(ch, program);
    addNote(note);
  }
}
