class StrokeManager
{
  int cursor = 0; // strokes should be drawn until this index (used for undo and redo)
  Stroke activeStroke;
  ArrayList<Stroke> strokeList;
  
  final float DIST_THRESHOLD = 0.0; // defines how much the pointer need to move before we add a new point

  float smoothFactor = 0.0;

  StrokeManager()
  {
    init();
  }

  void init()
  {
    this.strokeList = new ArrayList<Stroke>();
  }

  void addStroke()
  {
    clearRedoStack();
    this.activeStroke = new Stroke();
    this.activeStroke.setStepDistance(smoothFactor);
    strokeList.add(this.activeStroke);
    cursor++;
  }
  
  void display()
  {
    PGraphics defaultPGraphics = g;
    this.display(defaultPGraphics);
  }
  
  void display(PGraphics _pg)
  {
     float defaultScale = 1.0;
     this.display(_pg, defaultScale);
  }
  
  void display(PGraphics _pg, float _s)
  {
    PGraphics targetBuffer = _pg;
    float scale = _s;
    //stroke.display();
    for(int i=0; i<cursor; i++)
    {
      strokeList.get(i).display(targetBuffer, scale);
    }
  }

  //void clear() {
  //    stroke.erase();
  //    strokeList.clear();
  //}
  
  void setSmooth(float _s){
    this.smoothFactor = _s;
  }
  
  int getSize(){
    return this.activeStroke.getSize();
  }
  
  void undo()
  {
    if(cursor>0) cursor--;
    else println("Nothing left to UNdo");
  }
  
  void redo()
  {
    if(cursor<strokeList.size()) cursor++;
    else println("Nothing left to REdo");
  }
  
  void clearRedoStack()
  {
    if(cursor < strokeList.size())
    {
      while(strokeList.size() > cursor)
      {
        int i = strokeList.size()-1;
        strokeList.remove(i);
      }
    } 
    else 
    {
      if(isDebug) println("Nothing to clear from the redo stack");
    }
  }

  void addPoint(PVector _p) { // Pass the current coordinates to the strokes
      
      PVector p = _p;
      
      //int i = strokeList.size()-1;
      //Stroke lastStroke = strokeList.get(i);
      
      int slidingAverageSize = 6;
      Boolean isBegin = this.getSize() < slidingAverageSize; // exclude the first few points
      
      PVector acc = new PVector(0.0,0.0); // accumulator
      
      if(isBegin)
      {
        this.activeStroke.addPoint(p); // For the first few points, we just add one
      }
      else 
      {
        int minIndex = this.activeStroke.points.size() - slidingAverageSize;
        for(int index = this.activeStroke.points.size()-1; index > minIndex; index--)
        {
          PVector pt = this.activeStroke.getPoint(index);
          acc = acc.add(pt);
        }
        PVector ap = acc.div(slidingAverageSize-1); // average position of the previous points
        
        // Check if the new coordinates are sufficiently different from the past average
        Boolean isMouseMoved = dist(p.x, p.y, ap.x, ap.y) > DIST_THRESHOLD;
        
        if(isMouseMoved) 
        {
          this.activeStroke.addPoint(p);
          if(isDebug) println("adding a point at x:" + p.x + " y:" + p.y);
        }
        else println("mouse stopped moving");
        
      }
  }
}
