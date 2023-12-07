PVector GRAVITY = new PVector(0, 0.2);

class Bawl extends Note {
  int groundCnt = 0;
  float radius;
  
  Bawl(Synthesizer s, float x, float y, int c, int n, int v, int d) {
    super(s, x, y, c, n, v, d);
    if (x > synestrumentWidth / 2 )
      velocity = new PVector(-1*random(5,20), 0);
    else
      velocity = new PVector(random(5, 20), 0);
      
    radius = d;
  }
  
  boolean doneBouncing() { return groundCnt > 200; }
  boolean onGround()
  {
    return position.y + radius >= synestrumentHeight;
  }
  
  void update() {
    // Apply gravity to the velocity
    velocity.add(GRAVITY);
    
    // Update position with velocity
    position.add(velocity);
    
    // Check for collisions with walls
    if (position.x > synestrumentWidth - radius || position.x < radius) {
      velocity.x *= -1; // Reverse horizontal velocity on wall collision
    }
    if (position.y > synestrumentHeight - radius) {
      position.y = synestrumentHeight - radius;
      velocity.y *= -0.8; // Reverse and dampen vertical velocity on ground collision
    }
    
    if (onGround()) {
      groundCnt++;
      int nn = synestrument.getNote(floor(position.x));
      if (abs(note - nn) % 12 == 0) {  //((isNaturalNote(newNote))
        radius = max(10, radius - 10);
        stop();
        note = nn;
        play();
      }
    }
    
    if (doneBouncing()) { 
      stop();
      delay = 0;
    }
  }
  
  void display() {
    ellipseMode(CORNER);
    noStroke();
    fill(lerpColor(nn1Color, nnColor, map(note, START_NOTE, END_NOTE, 0, 1)), map(delay, 0, initialDelay, 0, 255));
    ellipse(position.x, position.y, radius, radius);;
  }
}
