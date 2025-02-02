class Button extends Sprite {
  color btnColor = 0;
  PImage btnImg;
  Button(float x, float y, int w, int h) {
      super(x, y, w, h);
  }
  
  void display() {
    pushStyle();
    fill(btnColor);
    if (btnImg != null) image(btnImg, position.x+2, position.y+2, width-4, height-4);
    if (mouseIn()) {
      strokeWeight(2);
      stroke(activePalette[15]);
    }
    else
      noStroke();
    rect(position.x, position.y, width-2, height-2, 8);
    
    popStyle();
  }
}
