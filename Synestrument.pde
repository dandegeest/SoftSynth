class Synestrument extends Sprite {
  
  Synestrument(float x, float y, int w, int h) {
    super(x, y, w, h);
    
  }
  
  String name() { return "Undefined"; }
  int getNote(int pos) { return 0; }
  int getChannel() { return 0; }
}
