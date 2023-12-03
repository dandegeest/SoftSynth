PVector GRAVITY = new PVector(0, 0.2);

class Bounce extends Note {
  int groundCnt = 0;
  int volDecay;
  
  Bounce(Synthesizer s, float x, float y, int c, int n, int v, int d) {
    super(s, x, y, c, n, v, d);
    if (x > width / 2 )
      velocity = new PVector(-1*max(5, random(15)), 0);
    else
      velocity = new PVector(max(5, random(15)), 0);
      
    volDecay = v/max(1, d);
  }
  
  boolean doneBouncing() { return groundCnt > 5; }
  boolean onGround()
  {
    return position.y + delay * 2 > height;
  }
  
  void update() {
    // Apply gravity to the velocity
    velocity.add(GRAVITY);
    
    // Update position with velocity
    position.add(velocity);
    
    // Check for collisions with walls
    if (position.x > width - delay / 2 || position.x < delay / 2) {
      velocity.x *= -1;
      volume -= volDecay;
      play();
    }
    if (position.y + delay / 2 > height) {
      position.y = height - delay;
      velocity.y *= -0.8;
      volume -= volDecay;
      play();
    }
    
    if (onGround()) { 
      volume -= volDecay;
      //stop();
      //note = (int)map(position.x, 0, width, 24, 95);
      //play();
      delay--;
    }
  }
  
  void display() {
    super.display();
    stroke(0);
    fill(0);
    ellipse(position.x, position.y + delay / 2, 5, 5);
  }
}
