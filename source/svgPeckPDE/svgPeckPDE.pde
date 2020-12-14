<<<<<<< Updated upstream

// Troubleshooting: 
// The stroke does not start immediately when the Wacom pen is pressed but the mouse works fine.
=======
// Troubleshooting: //<>//
// If the stroke does not start immediately when the Wacom pen is pressed but the mouse works fine.
>>>>>>> Stashed changes
// This is a Windows issue, uncheck "Use Windows Ink" in the Wacom Tablet Properties. 
// The checkbox can be found at the bottom left of the "Mapping" tab.

// TO DO
<<<<<<< Updated upstream
=======
// - clear (undoable how?)
>>>>>>> Stashed changes
// - optimize drawing to only render new part of the stroke
// - get rid of the draw loop (?)
// - hatch fill
// - variable strokeWeight (with hatch fill)
// - brush styles (dotted lines, 
// - undo part of a stroke (press undo and use the pen to define how much to remove, scrubbing up and down)
// - double strokes and reverse strokes as options


// CHANGELOG: 
// 07.12.2020: 
//   - Implemented lazy brush https://lazybrush.dulnan.net
//   - Made the lazy radius dynamic
//   - Use an off screen buffer for sub-pixel precision
// 08.12.2020
//   - Added magnifier
//   - adjustable smoothness and lazyradius based on pointer velocity (improves accuracy)
// 09.12.2020
//   - Switched to P2D (Duh)

final float LAZY_RADIUS_MIN = 2.0;
final float LAZY_RADIUS_MAX = 20.0;
final float SMOOTHING_MIN = 3.0;
final float SMOOTHING_MAX = 10.0;
final float STROKE_WEIGHT = 2;
final float SCALE_MULTIPLIER = 3.0;
final boolean LAZY_BRUSH = true;

PGraphics pgr; // raster image 
PGraphics svg; // vector image
float scale = SCALE_MULTIPLIER; // super sampling multiplier
int superWidth, superHeight;

PGraphics magnifier;
float magnifierSize = 0.2;
boolean showMagnifier = true;

Boolean isDebug = false;

import processing.svg.*;

Boolean isDrawing = false;
Boolean isSaveSVG = false;
Boolean isRender = true;


StrokeManager strokes;

TimestampFactory timestamp;

Cursor cursor;

LazyBrush lazy;


void setup(){
  size(1200,1200,P2D);
  frameRate(60);
  noCursor(); //<>// //<>//
  
  this.strokes = new StrokeManager(); //<>//
  this.timestamp = new TimestampFactory();
  this.cursor = new Cursor();
  this.lazy = new LazyBrush();
  this.lazy.enable();
  
  this.superWidth = floor(width*scale);
  this.superHeight = floor(height*scale);
  String filename = "_SVG/" + timestamp.getString() + ".svg";
  this.pgr = createGraphics( superWidth, superHeight );
  this.svg = createGraphics( superWidth, superHeight, SVG, filename);
  this.magnifier = createGraphics(floor(width*magnifierSize),floor(height*magnifierSize));
  
  this.lazy.setRadius(LAZY_RADIUS_MIN * this.scale); //<>//
  
  this.strokes.setSmooth(SMOOTHING_MIN * this.scale);
}

void draw(){
  
  background(255); //<>//
   //<>//
  float superX = mouseX * this.scale;
  float superY = mouseY * this.scale;
  
  this.lazy.update(superX,superY);
  
  LazyPoint brush = this.lazy.getBrush(); // current coordinates
  LazyPoint pointer = lazy.getPointer(); // should hold the same values as mouseX, mouseY
  float lazyRadius = lazy.getRadius();
  
  float cursorVelocity = this.cursor.getVelocity();
  
  if(isDrawing) 
  { 
    float scaledRadiusMin = LAZY_RADIUS_MIN * this.scale;
    float scaledRadiusMax = LAZY_RADIUS_MAX * this.scale;
    lazyRadius = constrain(map(cursorVelocity, 0, 50, scaledRadiusMin, scaledRadiusMax),0.0,scaledRadiusMax);
    this.lazy.setRadius(lazyRadius);
    
    this.strokes.setSmooth(map(cursorVelocity, 0.0, 100, SMOOTHING_MIN*this.scale, SMOOTHING_MAX*this.scale));
    
    if(LAZY_BRUSH) { this.strokes.addPoint(new PVector(brush.x,brush.y)); }
    else { this.strokes.addPoint(new PVector(mouseX,mouseY)); }
    
    this.cursor.setActive(true);
  }
  else
  {
    this.cursor.setActive(false);
  }
  
  if(isSaveSVG)
  { 
    //beginRecord(SVG, "_SVG/" + timestamp.getString() + ".svg");
    //println("Saving :" + timestamp.getString() + ".svg");
    drawSVG(this.svg, this.scale);
    //endRecord();
    this.isSaveSVG = false;
  }
  
  if(isRender) 
  {
    drawScreen(pgr, scale);
    this.isRender = false;
  }
  
  image(this.pgr,0,0,width,height);
  
  if(showMagnifier)
  {
    // Show magnified view at the pointer position
    int mw = magnifier.width;
    int mh = magnifier.height;
    int mx = constrain(floor(lazy.getBrush().x),0,this.superWidth);
    int my = constrain(floor(lazy.getBrush().y),0,this.superHeight);
    this.magnifier.beginDraw();
    this.magnifier.image(this.pgr.get(floor(mx-mw/2),floor(my-mh/2),floor(mx+mw/2),floor(my+mh/2)),0,0);
    this.magnifier.stroke(0);
    this.magnifier.noFill();
    this.magnifier.rect(0,0,mw-1,mh-1);
    this.magnifier.circle(mw/2,mh/2,cursor.getSize()/2*this.scale);
    this.magnifier.endDraw();
    image(this.magnifier, 10, 10);
  }
  
  //LazyPoint brush = lazy.getBrush(); // current coordinates

  
  float screenRadius = lazyRadius / scale;
  float screenBrushX = brush.x / scale;
  float screenBrushY = brush.y / scale;
  float screenPointerX = pointer.x / scale;
  float screenPointerY = pointer.y / scale;
    
  if(isDebug)
  { 
    // Show the position of the brush
    pushStyle();
    noStroke();
    fill(#28CAF5);
    circle( screenBrushX, screenBrushY, 6 );
    popStyle();
    
    // Show the radius
    pushStyle();
    noFill();
    strokeWeight(4);
    stroke(150);
    circle( screenBrushX, screenBrushY, screenRadius*2 );
    popStyle();
    
    // Show the position of the pointer
    pushStyle();
    noStroke();
    fill(#CE6BEA);
    circle( screenPointerX, screenPointerY, 6);
    popStyle();
  }
  
  pushStyle();
  strokeWeight(1);
  stroke(0);
  this.cursor.setPos(screenBrushX,screenBrushY);
  // cursor.setPos(screenPointerX,screenPointerY);
  this.cursor.display();
  popStyle();
  
  lazy.reset();
  
  noLoop();
}

void renderFrame()
{
  loop();
  isRender = true;
}

void drawScreen(PGraphics _pg, float _scale)
{
  _pg.beginDraw();
  _pg.background(255);
  _pg.noFill();
  _pg.strokeWeight(STROKE_WEIGHT * _scale);
  _pg.stroke(0);
  strokes.display(_pg, _scale);
  _pg.endDraw();
}

void drawSVG(PGraphics _pg, float _scale)
{
  println("save svg: BEGIN");
  boolean d = isDebug; // save the debug state to restore it after rendering the vectors
  if(d){isDebug = false;}
  _pg.beginDraw();
  //_pg.background(255);
  _pg.noFill();
  //_pg.strokeWeight(STROKE_WEIGHT * _scale);
  _pg.stroke(0);
  strokes.display(_pg, _scale);
  _pg.endDraw();
  if(d){isDebug = true;}
  println("save svg: END");
}

void drawCursor(float _x, float _y, float _diameter)
{
  pushStyle();
  blendMode(DIFFERENCE);
  strokeWeight(1);
  stroke(0);
  circle(_x,_y,_diameter);
  popStyle();
}

void keyPressed() {
  //renderFrame();
}

void keyReleased()
{
  if (key == 'z') {
    undo();
  } 
  else if (key == 'y') {
    redo();
  }
  else if(key == 's') {
    saveSVG();
  }
  else if(key == 'd') {
    isDebug = !isDebug;
  }
  else if(key == 'm') {
    showMagnifier = !showMagnifier;
  }
  renderFrame();
  isDrawing=false;
}

void saveSVG()
{
  isSaveSVG = true;
}

void undo()
{
  strokes.undo();
}

void redo()
{
  strokes.redo();
}

void mousePressed() {
  renderFrame();
  startDrawing();
}

void mouseDragged() {
  renderFrame();
}

void mouseReleased() {
  finishDrawing();
}

void mouseMoved() {
  //renderFrame();
  loop();
}

void startDrawing(){
  strokes.addStroke();
  isDrawing = true;
  lazy.enable();
}

void finishDrawing(){
  isDrawing = false;
  lazy.disable();
}
