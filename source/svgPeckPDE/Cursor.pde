class Cursor {
 
  float x, y, s, px, py;
  boolean isActive = false;
  float v = 0.0; // velocity
  color c, activeColor, idleColor;
  ArrayList<Float> mag;
  final int magMaxSize = 10;
  
  Cursor(){
    this.x = 0;
    this.y = 0;
    this.s = 4;
    activeColor = color(#4898F7);
    idleColor = color(0);
    mag = new ArrayList<Float>();
  }
  
  void setPos(float _x, float _y)
  {
    this.px = this.x;
    this.py = this.y;
    this.x = _x;
    this.y = _y;
  }
  
  PVector getPos()
  {
    return new PVector(this.x,this.y);
  }
   
  PVector getPreviousPos() {
    return new PVector(this.px, this.py);
  }
  
  void setActive(boolean _a)
  {
    this.isActive = _a;
    this.update();
  }
  
  void setSize(float _s)
  {
    this.s = _s;
  }
  
  float getSize()
  {
    return this.s;
  }
  
  void update() 
  {
    if(isActive) 
    {
      c = activeColor;
    } else {
      c = idleColor;
    }
    calculateAverageVelocity();
  }
  
  float getVelocity(){
    return this.v;
  }
  
  void calculateAverageVelocity()
  {
    
    PVector direction = PVector.sub(getPos(),getPreviousPos());
    float magnitude = direction.mag();
    
    mag.add(magnitude);
    
    if( mag.size() > magMaxSize) { mag.remove(0); }
    
    float acc = 0.0;
    for(int i=0; i<mag.size(); i++)
    {
      acc += mag.get(i);
    }
    this.v = acc / mag.size();
  }
  
  void display()
  {
    pushStyle();
    strokeWeight(1);
    stroke(c);
    circle(this.x,this.y,this.s);
    popStyle();
  }
  

}
