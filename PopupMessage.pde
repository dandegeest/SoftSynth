static PFont popupMessageFont;
  
class PopupMessage extends Sprite {
  String message;
  int duration;

  
  PopupMessage(float x, float y, String m, int d) {
    super(x, y, 0, 0);
    message = m;
    duration = d;
  }
  
  void update() {
    if (duration > 0) duration--;
  }
  
  void display() {
    if (duration > 0) {
      pushStyle();
      textAlign(LEFT);
      stroke(128);
      fill(128);
      textSize(36);
      while (position.x + 200 > width) position.x--;
      text(message, position.x - duration/2, position.y - duration/2, 200, 50);
      popStyle();
    }
  }

}
