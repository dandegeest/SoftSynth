class Sprite {
  PVector position;
  int width;
  int height;
  PVector velocity;
  
  Sprite(float x, float y, int w, int h) {
    position = new PVector(x, y);
    width = w;
    height = h;
  }
  
  void update() {}
  void display() {}
  
  //Mouse
  boolean mouseIn() { return false;}
  
  void onLeftMousePressed() {}
  void onLeftMouseReleased() {}
  void onLeftMouseDragged() {}
  
  void onRightMousePressed() {}
  void onRightMouseReleased() {}
  void onRightMouseDragged() {}
}
