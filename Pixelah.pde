import processing.video.*;
import ddf.minim.analysis.*;

enum PixelMode {
  RED,
  GREEN,
  BLUE,
  BRIGHT
}

enum PlayMode {
  FORWARD,
  BACKWARD
}

class Pixelah extends Synestrument {
  PImage sourceImg;
  int bandSkip = 0;
  int imgIndex = 0;
  PixelMode pixMode = PixelMode.GREEN;
  PlayMode playMode = PlayMode.FORWARD;
  Button red;
  Button green;
  Button blue;
  Button bright;
  Button hue;
  Button sat;
  Button playModeBtn;
  Button imgButton;
  
  FFT fft;
  float[] signal;
  int band = -1;
  
  Pixelah(float x, float y, int w, int h) {
    super(x, y, w, h);
    
    red = new Button(1024, 0, width - 1024, 100);
    red.btnColor = color(255, 0, 0, 200);
    green = new Button(1024, 100, width - 1024, 100);
    green.btnColor = color(0, 255, 0);
    blue = new Button(1024, 200, width - 1024, 100);
    blue.btnColor = color(0, 0, 255);
    bright = new Button(1024, 300, width - 1024, 100);
    bright.btnColor = color(230);
    playModeBtn = new Button(1024, synestrumentHeight-200, width - 1024, 100);
    playModeBtn.btnColor = activePalette[10];
    imgButton = new Button(1024, synestrumentHeight-100, width - 1024, 100);

    cycleImg();
    
    signal = new float[sourceImg.width];
    fft = new FFT(sourceImg.width, 44100);
    fft.window(FFT.GAUSS);   
  }
  
  String name() { return "Pixelah"; }

  int getChannel() {
    int ch = int(map(mouseY, 0, sourceImg.height, 0, NUM_CHANNELS-1));
    return ch;
  }
  
  int getNote(int pos) {
    int note = int(map(green(sourceImg.get(mouseX, mouseY)), 0, 255, START_NOTE, END_NOTE));
    return note;
  }
  
  void cycleImg() {
    sourceImg = loadImage("pixelah\\" + imgIndex + ".png");
    sourceImg.resize(1024, 0);
    sourceImg = sourceImg.get(0, 0, 1024, height);
    sourceImg.loadPixels();
    imgButton.btnImg = sourceImg.copy();
    imgIndex++;
    if (imgIndex > 4) imgIndex = 0;
  }
  
  void display() {    
    if (pmouseY != mouseY)
      runFFT();

    pushStyle();
    image(sourceImg, 0, 0);

    if (fft != null && mouseX < 1024 && mouseY < this.height) {
      int chH = height / NUM_CHANNELS;
      int chIndex = (int)map(mouseY, 0, height, 0, NUM_CHANNELS - 1);
      blend(sourceImg, 0, mouseY - chH/2, this.width, chH, 0, mouseY - chH/2, sourceImg.width, chH, DODGE );
      fill(txtColor);
      textSize(32);
      textAlign(RIGHT, CENTER);
      text(channelInfo.get(chIndex).instrumentName, 0, mouseY - chH/2, 1024, chH);
      
      switch (pixMode) {
      case RED:
        fill(255, 0, 0);
        break;
      case GREEN:
        fill(0, 255, 0);
        break;
      case BLUE:
        fill(0, 0, 255);
        break;
      case BRIGHT:
        fill(230);
        break;
      }
      noStroke();
      for (int i = 0; i < fft.specSize(); i++) {
        float amp = fft.getBand(i) * 1;
        rect(i * 2, (height - amp), 6, 6, 1);
      }
    }    
    popStyle();
    
    red.display();
    green.display();
    blue.display();
    bright.display();
    playModeBtn.display();
    imgButton.display();

    playFFT();
    
    if (mousePressed)
      onBendCommand(mouseX);
  }
  
  void runFFT() {
    int row = mouseY;  // Pick a row in the middle
    
    // Convert row of pixels to brightness values
    for (int i = 0; i < sourceImg.width; i++) {
      color c = sourceImg.get(i, row);
      switch (pixMode) {
        case RED:
          signal[i] = red(c); 
          break;
        case GREEN:
          signal[i] = green(c); 
          break;
        case BLUE:
          signal[i] = blue(c); 
          break;
        case BRIGHT:
          signal[i] = brightness(c); 
          break;
      }
    }
    
    // FFT setup
    for (int i = 0; i < width; i++) {
      fft.forward(signal);  // Process the signal
    }
  }

  void playFFT() {
    if (band < 0 || band > fft.specSize())
      return;
      
    int amp = int(fft.getBand(band) * 1);
    int namp = constrain(amp, START_NOTE, END_NOTE);
    int channel = getChannel();//constrain(int(map(height - amp, 0, sourceImg.height, 0, NUM_CHANNELS)), 0, NUM_CHANNELS-1);
    Note note = new Note(synth, band * 2, (height - amp), channel, namp, int(random(50,100)), int(random(10,100)));
    int c = (int)map(namp, START_NOTE, END_NOTE, 0, 255);
    switch (pixMode) {
      case RED:
        note.noteColor = color(c, 0, 0);
        break;
      case GREEN:
        note.noteColor = color(0, c, 0);
        break;
      case BLUE:
        note.noteColor = color(0, 0, c);
        break;
      case BRIGHT:
        note.noteColor = color(200);
        break;
    }
    addNote(note);
    //recordNote(note, 1);
    switch (playMode) {
      case FORWARD:  
        band += bandSkip;
        break;
      case BACKWARD:
        band -= bandSkip;
        break;
    }
  }
  
  void onMouseMoved() {   
    onBendCommand(mouseX);
  }
  
  void onLeftMousePressed() {
    bandSkip = millis();
  }
    
  void onLeftMouseReleased() {
    if (red.mouseIn()) {
      pixMode = PixelMode.RED;
      println("Mode", pixMode);
      return;
    }
    
    if (green.mouseIn()) {
      pixMode = PixelMode.GREEN;
      println("Mode", pixMode);
      return;
    }

    if (blue.mouseIn()) {
      pixMode = PixelMode.BLUE;
      println("Mode", pixMode);
      return;
    }

    if (bright.mouseIn()) {
      pixMode = PixelMode.BRIGHT;
      println("Mode", pixMode);
      return;
    }

    if (playModeBtn.mouseIn()) {
      if (playMode == PlayMode.FORWARD) playMode = PlayMode.BACKWARD; else playMode = PlayMode.FORWARD;
      println("Mode", playMode);
      return;
    }

    if (imgButton.mouseIn()) {
      cycleImg();
      return;
    }

    if (mouseX < 1024) {
      bandSkip = (int)map(millis() - bandSkip, 0, 5000, 1, fft.specSize() - 1);
      switch (playMode) {
        case FORWARD:  
          band = bandSkip;
          break;
        case BACKWARD:
          band = fft.specSize() - bandSkip;
          break;
      }
    }
  }

  void onLeftMouseDragged() {
    band = (int)map(mouseX, 0, width, 0, fft.specSize()-1);
  }  
}
