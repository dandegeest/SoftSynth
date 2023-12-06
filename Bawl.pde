PVector GRAVITY = new PVector(0, 0.2);

class Bawl extends Note {
  int groundCnt = 0;
  float volDecay;
  
  Bawl(Synthesizer s, float x, float y, int c, int n, int v, int d) {
    super(s, x, y, c, n, v, d);
    if (x > synestrumentWidth / 2 )
      velocity = new PVector(-1*random(5,20), 0);
    else
      velocity = new PVector(random(5, 20), 0);
      
    volDecay = 1;
  }
  
  boolean doneBouncing() { return groundCnt > 5; }
  boolean onGround()
  {
    return ceil(position.y + delay/2) >= synestrumentHeight;
  }
  
  void update() {
    // Apply gravity to the velocity
    velocity.add(GRAVITY);
    
    // Update position with velocity
    position.add(velocity);
    
    // Check for collisions with walls
    if (position.x > synestrumentWidth || position.x < 0) {
      velocity.x *= -1;
      volume -= volDecay;
    }
    if (position.y > synestrumentHeight) {
      position.y = synestrumentHeight - delay;
      velocity.y *= -0.8;
      volume -= volDecay;
    }
    
    if (onGround()) { 
      stop();
      groundCnt++;
      note = synestrument.getNote(floor(position.x));
      play();
      delay -= 4;
    }
  }
  
  void display() {
    super.display();
    ellipse(position.x, position.y, 10, 10);
  }
}
