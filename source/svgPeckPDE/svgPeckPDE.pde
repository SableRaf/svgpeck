
// Troubleshooting: 
// The stroke does not start immediately when the Wacom pen is pressed but the mouse works fine.
// This is a Windows issue, uncheck "Use Windows Ink" in the Wacom Tablet Properties. 
// The checkbox can be found at the bottom left of the "Mapping" tab.

// TO DO
// - save file dialog
// - optimize drawing to only render new part of the stroke
// - get rid of the draw loop (?)
// - hatch fill
// - variable strokeWeight (with hatch fill)
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
// 11.12.20
//   - Added save dialog on Ctrl+S (Typing 's' by itself quick saves into the _SVG folder)

import processing.svg.*;

final float LAZY_RADIUS_MIN = 2.0;
final float LAZY_RADIUS_MAX = 20.0;
final float SMOOTHING_MIN = 1.0;
final float SMOOTHING_MAX = 20.0;
final float STROKE_WEIGHT = 2;
final float SCALE_MULTIPLIER = 3.0;
final boolean LAZY_BRUSH = true;

PGraphics pgr; // raster image 
float scale = SCALE_MULTIPLIER; // super sampling multiplier
int superWidth, superHeight;

PGraphics magnifier;
float magnifierSize = 0.2;
boolean showMagnifier = true;

Boolean isDebug = false;
Boolean isDrawing = false;
Boolean isSaveSVG = false;
Boolean isRender = true;
Boolean isSelectFile = false;
Boolean isCtrlPressed = false;

String fileSavePath;

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
  
  this.fileSavePath = generateFilePath();
  
  this.superWidth = floor(width*SCALE_MULTIPLIER);
  this.superHeight = floor(height*SCALE_MULTIPLIER);
  this.pgr = createGraphics( superWidth, superHeight );
  this.magnifier = createGraphics(floor(width*magnifierSize),floor(height*magnifierSize));
  
  this.lazy.setRadius(LAZY_RADIUS_MIN * this.SCALE_MULTIPLIER); //<>//
  
  this.strokes.setSmooth(SMOOTHING_MIN * this.SCALE_MULTIPLIER);
}

void draw(){
  
  background(255); //<>//
   //<>//
  float superX = mouseX * this.SCALE_MULTIPLIER;
  float superY = mouseY * this.SCALE_MULTIPLIER;
  
  this.lazy.update(superX,superY);
  
  LazyPoint brush = this.lazy.getBrush(); // current coordinates
  LazyPoint pointer = lazy.getPointer(); // should hold the same values as mouseX, mouseY
  float lazyRadius = lazy.getRadius();
  
  float cursorVelocity = this.cursor.getVelocity();
  
  if(isDrawing) 
  { 
    float scaledRadiusMin = LAZY_RADIUS_MIN * SCALE_MULTIPLIER;
    float scaledRadiusMax = LAZY_RADIUS_MAX * SCALE_MULTIPLIER;
    lazyRadius = constrain(map(cursorVelocity, 0, 50, scaledRadiusMin, scaledRadiusMax),0.0,scaledRadiusMax);
    this.lazy.setRadius(lazyRadius);
    
    this.strokes.setSmooth(map(cursorVelocity, 0.0, 100, SMOOTHING_MIN*SCALE_MULTIPLIER, SMOOTHING_MAX*SCALE_MULTIPLIER));
    
    if(LAZY_BRUSH) { this.strokes.addPoint(new PVector(brush.x,brush.y)); }
    else { this.strokes.addPoint(new PVector(mouseX,mouseY)); }
    
    this.cursor.setActive(true);
  }
  else
  {
    this.cursor.setActive(false);
  }
  
  if(isRender) 
  {
    drawScreen(pgr, SCALE_MULTIPLIER);
    this.isRender = false;
  }
  
  image(this.pgr,0,0,width,height);
  
  if(this.isSelectFile){
    selectOutput("Select a file to write to:", "fileSelected");
    this.isSelectFile = false;
  }
  
  if(this.isSaveSVG){
    drawSVG(floor(this.superWidth), floor(this.superHeight), this.fileSavePath);
    println("File was saved to " + this.fileSavePath);
    this.isSaveSVG = false;
  }
  
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
    this.magnifier.circle(mw/2,mh/2,cursor.getSize()/2*SCALE_MULTIPLIER);
    this.magnifier.endDraw();
    image(this.magnifier, 10, 10);
  }
  
  //LazyPoint brush = lazy.getBrush(); // current coordinates

  
  float screenRadius = lazyRadius / SCALE_MULTIPLIER;
  float screenBrushX = brush.x / SCALE_MULTIPLIER;
  float screenBrushY = brush.y / SCALE_MULTIPLIER;
  float screenPointerX = pointer.x / SCALE_MULTIPLIER;
  float screenPointerY = pointer.y / SCALE_MULTIPLIER;
    
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

void drawSVG(int _width, int _height, String _filename)
{
  PGraphics svg = createGraphics( _width, _height, SVG, _filename);
  println("save svg: BEGIN");
  boolean d = isDebug; // save the debug state to restore it after rendering the vectors
  if(d){isDebug = false;}
  svg.beginDraw();
  svg.noFill();
  svg.stroke(0);
  strokes.display(svg, 1.0);
  svg.endDraw();
  if(d){isDebug = true;}
  println("save svg: END");
}

String generateFilePath() 
{
  return this.fileSavePath = "_SVG/" + timestamp.getString() + ".svg";
}

void fileSelected(File selection) 
{
  if (selection == null) {
    println("Save window was closed or the user hit cancel.");
  } else {
    this.fileSavePath = selection.getAbsolutePath();
    this.isSaveSVG = true;
  }
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
  if (key == CODED) {
    if (keyCode == CONTROL) {
      this.isCtrlPressed = true;
    }
  }
  else {
    if(this.isCtrlPressed){
      if(keyCode == 83) // 's' 
      {
        this.isSelectFile = true;
      }
    }
  }
}

void keyReleased()
{
  if (key == CODED) {
    if (keyCode == CONTROL) {
      this.isCtrlPressed = false;
    }
  }
  else {
    if(key == 's') // Quick save (no user dialog)
    {
      this.fileSavePath = generateFilePath();
      this.isSaveSVG = true;
    }
    else if (key == 'z') {
      undo();
    } 
    else if (key == 'y') {
      redo();
    }
    else if(key == 's') {
      this.isSaveSVG = true;
    }
    else if(key == 'd') {
      this.isDebug = !this.isDebug;
    }
    else if(key == 'm') {
      this.showMagnifier = !this.showMagnifier;
    }
  }
  renderFrame();
  this.isDrawing=false;
}

void saveSVG()
{
  this.isSaveSVG = true;
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
