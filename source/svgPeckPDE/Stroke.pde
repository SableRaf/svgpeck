class Stroke
{
  int strokeAmount;
  int pointAmount;                     // length of the Point Array (max number of points)
  int pointsAssigned = 0;              // amount of points currently in the Point array (acts as a cursor)                            
  float radiusDivide = 10;             // distance between current and next point / this = radius for first half of the stroke
  ArrayList<PVector> points;
  float stepDistance = 0.1;           // higher value means smoother curve (TO DO correct edge effects for higher values)
  

  Stroke()
  {
    init();
  }

  void init()
  {
    points = new ArrayList<PVector>(); // Create the array that will hold the points composing the stroke
  }

  void addPoint(PVector _p)
  {
      points.add(_p);
      //points.get(points.size() - 1).px = currentX;
      //points.get(points.size() - 1).py = currentY;
  }
  
  void setStepDistance(float _s)
  {
    this.stepDistance = _s;
  }
  
  PVector getPoint(int i){
    PVector p = new PVector(0.0,0.0);
    int size = points.size();
    if(size < 1)
    {
      println("Error: Trying to getPoint() while the points ArrayList is empty. [millis:" + millis() +"]" );
      //exit();
    }
    else if (i < size)
    {
       p = points.get(i);
    }
    else 
    {
      println("Index out of bounds at getPoint(). points.size() : " + size + " index : " + i);
      exit();
    }
    return p;
  }
  
  int getSize()
  {
    if(points != null) { return points.size(); }
    else 
    {
      println("Trying to getSize() of points array while points array has not been instanciated");
      return 0;
    }
  }

  //void erase() {
  //  points.clear();
  //}

  void display(PGraphics _pg, float _s)
  {
    PGraphics targetBuffer = _pg;
    float scale = _s;
    
    targetBuffer.beginShape();
    PVector p = this.getPoint(0);
    PVector lastPointDrawn = p;
    targetBuffer.curveVertex(p.x,p.y);
    targetBuffer.curveVertex(p.x,p.y);
    for (int i = 0; i < this.getSize()-1; i++)
    {
      p = this.getPoint(i);
      float dist = dist(p.x, p.y, lastPointDrawn.x, lastPointDrawn.y);
      println("drawing point at x:"+ p.x+" y:"+p.y);
      if(dist > stepDistance)
      {
        targetBuffer.curveVertex(p.x, p.y);
        //println("Drawing curveVertex at x:"+p.x+" y:"+p.y);
        lastPointDrawn = p;
      }
    }
    p = this.getPoint(this.getSize()-1);
    targetBuffer.curveVertex(p.x,p.y);
    targetBuffer.curveVertex(p.x,p.y);
    targetBuffer.endShape();
    
    if(isDebug)
    {
      for (int i = 0; i < this.getSize() - 1; i++)
      {
      p = this.getPoint(i);
      float dist = dist(p.x, p.y, lastPointDrawn.x, lastPointDrawn.y);
      if(dist > stepDistance || i == 0)
        {
          targetBuffer.pushStyle();
          targetBuffer.noStroke();
          targetBuffer.fill(#FCF10F);
          targetBuffer.circle(p.x,p.y, 3 * scale);
          targetBuffer.popStyle();
          lastPointDrawn = p;
        }
      }
    }
  }
}
