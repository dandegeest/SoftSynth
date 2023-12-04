class BeztarString extends Sprite
{
  boolean isDone = false;
  // Anchor
  BeztarString anchor;
  PVector clickLoc;
  color dotColor;
  
  BeztarString(int x, int y, int r) {
    super(x, y, r, r);
    isDone = false;
    dotColor = lerpColor(nn1Color, nnColor, map(position.y, 0, height, 0, 1));
  }
  
  void setAnchor(BeztarString a) {
    anchor = a;
  }
  
  void clicked(int x, int y) {
    clickLoc = new PVector(x,y);    
  }
  
  boolean mouseIn() {
    return abs(position.x - mouseX) < 20 ? true : false;
  }
  boolean mouseIn2() {
    if (mouseX >= position.x - width/2 &&
      mouseX <= position.x + width/2 &&
      mouseY >= position.y - height/2 &&
      mouseY <= position.y + height/2)
      return true;

    return false;
  }
  
  void update() {
    super.update();
    if (anchor != null)
      anchor.update();  
  }
  
  void display() {
    drawAnchor();
    
    noStroke();
    
    if (mouseIn()) {
      strokeWeight(4);
      stroke(txtColor);
    }
    
    fill(dotColor);
    ellipse(position.x, position.y, width, height);
  }
  
  void drawAnchor() {
    if (anchor == null)
      return;
    
    pushStyle();
    stroke(chColor);
    strokeWeight(2);
    noFill();

    int cp1x = abs(position.x - mouseX) < 20 ? mouseX : (int)position.x;
    //int cp1y = abs(position.y - mouseY) < 10 ? mouseX : (int)position.x;
    
    bezier(position.x, position.y,
      cp1x, position.y,
      position.x, mouseY,
      anchor.position.x, anchor.position.y);
    //line(position.x, position.y, anchor.position.x, anchor.position.y);
    
    noStroke();
    int steps = NUM_NOTES;
    for (int i = 0; i <= steps; i++) {
      float t = i / float(steps);
      float x = bezierPoint(position.x, cp1x, position.x, anchor.position.x, t);
      float y = bezierPoint(position.y, mouseY, position.y, anchor.position.y, t);
      fill(lerpColor(nn1Color, nnColor, map(y, 0, height, 0, 1)));
      ellipse(x, y, 10, 10);
    }

    anchor.display();
    popStyle();

  }
  
  void done() {
    isDone = true;
  }
}
