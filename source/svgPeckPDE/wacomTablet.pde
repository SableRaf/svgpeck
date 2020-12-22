String[] btnNames = {"Void", "L1", "L2", "L3", "L4", "R1", "R2", "R3", "R4", "TIP", "SWITCH BOTTOM", "SWITCH TOP", "ERASER_TIP", "STRIP LEFT", "STRIP RIGHT"};

interface Btn {
  int
    L1 = 1, 
    L2 = 2, 
    L3 = 3, 
    L4 = 4, 
    R1 = 5, 
    R2 = 6, 
    R3 = 7, 
    R4 = 8, 
    TIP = 9, 
    SWITCH_BOTTOM = 10, 
    SWITCH_TOP = 11, 
    ERASER_TIP = 12, 
    STRIP_LEFT = 13, 
    STRIP_RIGHT = 14;
}

class WacomTablet {
  
  Object parent;
  
  boolean[] btnStates = {false, false, false, false, false, false, false, false, false, false, false, false, false, false};

  ArrayList<PVector> points;

  WacomPen pen;

  boolean isWriting = false;

  float strip1Value, strip2Value;

  /********************************************/
  /*          WACOMTABLET CONSTRUCTOR         */
  /********************************************/

  WacomTablet(Object theParent) {
    parent = theParent;
    points = new ArrayList<PVector>();
    pen = new WacomPen();
    pen.x = width/2;
    pen.y = height/2;
  }

  private void addPoint(PVector newPoint) {
    points.add(newPoint);
  }

  private void clearPoints() {
    points.clear();
  }

  /********************************************/
  /*                 GETTERS                  */
  /********************************************/

  public ArrayList<PVector> getPoints() {
    ArrayList<PVector> newPoints = points;
    this.clearPoints();
    return newPoints;
  }

  public boolean isWriting() {
    return isWriting;
  }
  
  public PVector getPosition() {
    return new PVector(this.pen.x, this.pen.y);
  }
  

  /********************************************/
  /*          WACOM EVENTS HANDLERS           */
  /********************************************/

  public void buttonPressed(int btnIndex) {
    //println("Button pressed: " + btnNames[btnIndex]);
    btnStates[btnIndex-1] = true;
    wacomButtonPressed(btnIndex);
  }

  public void buttonReleased(int btnIndex) {
    //println("Button released: " + btnNames[btnIndex]);
    btnStates[btnIndex-1] = false;
    wacomButtonReleased(btnIndex);
  }

  public void penDetected(int state) {
    if (this.pen.detected == false) {
      this.pen.detected(state);
      println("Pen detected: " + this.pen.getStateName());
    }
  }
  public void penLost() {
    if (tablet.pen.detected == true) {
      println("Pen lost: " + this.pen.getStateName());
      this.pen.lost();
    }
  }

  public void startWriting() {
    this.isWriting = true;
  }

  public void stopWriting() {
    this.isWriting = false;
  }

  /********************************************/
  /*             PLUG METHODS                 */
  /********************************************/
  // Catch events from OscP5

  /* DISCARD */  // explicitely capture unused osc messages
  public void doNothing() {
    println("doing nothing");
  }

  /* TEST */
  public void test(int theA, int theB) {
    print("plug event method test()");
    println(" | 2 ints received: "+theA+", "+theB);
  }

  /* PEN */
  public void pen(float x, float y, float tiltX, float tiltY, float pressure) {
    if (this.isWriting) {
      addPoint(new PVector(x,y));
    }
    this.pen.x = x;
    this.pen.y = y;
    this.pen.tiltX = tiltX;
    this.pen.tiltY = tiltY;
    this.pen.pressure = pressure;
    //println("plug event method pen()");
    //println("x: "+x+", y: "+y+", tiltX: "+tiltX+", tiltY: "+tiltY+", pressure: "+pressure);
  }

  /* PEN PROXIMITY */
  public void penProximity(float proximity) {
    //println("plug event method penProximity() | " + "proximity: "+ proximity);
    if (proximity == 1.0) penDetected(PenSide.TIP);
    else if (proximity == 0.0) penLost();
  }

  /* TIP */
  public void penButton1(float btn) {
    int k = 9;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }

  /* DUOSWITCH */
  public void penButton2(float btn) {
    int k = 10;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }
  public void penButton3(float btn) {
    int k = 11;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }

  /* ERASER */
  public void eraser(float x, float y, float tiltX, float tiltY, float pressure) {
    this.pen.x = x;
    this.pen.y = y;
    this.pen.tiltX = tiltX;
    this.pen.tiltY = tiltY;
    this.pen.pressure = pressure;
    //println("plug event method eraser()");
    //println("x: "+x+", y: "+y+", tiltX: "+tiltX+", tiltY: "+tiltY+", pressure: "+pressure);
  }

  public void eraserButton1(float btn) {
    int k = 12;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }

  /* ERASER PROXIMITY */
  public void eraserProximity(float proximity) {
    //println("plug event method eraserProximity() | " + "proximity: "+ proximity);
    if (proximity == 1.0) penDetected(PenSide.ERASER);
    else if (proximity == 0.0) penLost();
  }

  /* EXPRESS KEYS */
  public void key1(float btn) {
    int k = 1;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }
  public void key2(float btn) {
    int k = 2;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }
  public void key3(float btn) {
    int k = 3;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }
  public void key4(float btn) {
    int k = 4;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }
  public void key5(float btn) {
    int k = 5;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }
  public void key6(float btn) {
    int k = 6;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }
  public void key7(float btn) {
    int k = 7;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }
  public void key8(float btn) {
    int k = 8;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }

  public void strip1(float value, float btn) {
    this.strip1Value = value;
    int k = 13;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }

  public void strip2(float value, float btn) {
    this.strip2Value = value;
    int k = 14;
    if (btn == 1.0) buttonPressed(k);
    else if (btn == 0.0) buttonReleased(k);
  }
}
