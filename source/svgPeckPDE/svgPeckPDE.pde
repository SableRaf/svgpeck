// Troubleshooting:  //<>// //<>// //<>//
// If the stroke does not start immediately when the Wacom pen is pressed but the mouse works fine.
// This is a Windows issue, uncheck "Use Windows Ink" in the Wacom Tablet Properties. 
// The checkbox can be found at the bottom left of the "Mapping" tab.

// TO DO
// - clear (undoable how?)
// - optimize drawing to only render new part of the stroke
// - get rid of the draw loop (?)
// - hatch fill
// - variable strokeWeight (with hatch fill)
// - brush styles (e.g.dotted lines, fur, grass)
// - drop svg to use as brush style?
// - undo part of a stroke (press undo and use the pen to define how much to remove, scrubbing up and down)
// - double strokes and reverse strokes as options
// - hold for straight line

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

final float LAZY_RADIUS_MIN = 0.0;
final float LAZY_RADIUS_MAX = 0.0;
final float LAZY_RAMP = 1.0; // at which cursor velocity do we reach LAZY_RADIUS_MAX
final float SMOOTHING_MIN = 2.0;
final float SMOOTHING_MAX = 10.0;
final float SMOOTHING_RAMP = 8.0; // at which cursor velocity do we reach SMOOTHING_MAX
final float STROKE_WEIGHT = 2;
final float SCALE_MULTIPLIER = 1.0;
final boolean LAZY_BRUSH = false;
final boolean WACOM = true;

PGraphics pgr; // raster image 
float magnifierScale = SCALE_MULTIPLIER*0.5; // super sampling multiplier
int superWidth, superHeight;

float startX = 0.0;
float startY = 0.0;

PGraphics magnifier;
float magnifierSize = 0.2;
boolean showMagnifier = false;

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

WacomOsc osc;
String netAddress = "127.0.0.1";
int listeningPort = 12000;
int remotePort = 12000;
WacomTablet tablet;

void setup() {
  size(1200, 1200, P2D);
  frameRate(60);
  noCursor();

  tablet = new WacomTablet(this);
  osc = new WacomOsc(tablet, netAddress, listeningPort, remotePort);

  this.strokes = new StrokeManager();
  this.timestamp = new TimestampFactory();
  this.cursor = new Cursor();
  this.lazy = new LazyBrush();
  this.lazy.enable();

  this.fileSavePath = generateFilePath();

  this.superWidth = floor(width*SCALE_MULTIPLIER);
  this.superHeight = floor(height*SCALE_MULTIPLIER);
  this.pgr = createGraphics( superWidth, superHeight );
  this.magnifier = createGraphics(floor(width*magnifierSize), floor(height*magnifierSize));

  this.lazy.setRadius(LAZY_RADIUS_MIN * this.SCALE_MULTIPLIER);

  this.strokes.setSmooth(SMOOTHING_MIN * this.SCALE_MULTIPLIER);
}

void draw() {

  background(255);

  float superX = mouseX * this.SCALE_MULTIPLIER;
  float superY = mouseY * this.SCALE_MULTIPLIER;

  this.lazy.update(superX, superY);

  LazyPoint brush = this.lazy.getBrush(); // current coordinates
  LazyPoint pointer = lazy.getPointer(); // should hold the same values as mouseX, mouseY
  float lazyRadius = lazy.getRadius();

  float cursorVelocity = this.cursor.getVelocity();

  float scaledRadiusMin = LAZY_RADIUS_MIN * SCALE_MULTIPLIER;
  float scaledRadiusMax = LAZY_RADIUS_MAX * SCALE_MULTIPLIER;
  lazyRadius = constrain(map(cursorVelocity, 0, LAZY_RAMP, scaledRadiusMin, scaledRadiusMax), 0.0, scaledRadiusMax);
  this.lazy.setRadius(lazyRadius);

  this.strokes.setSmooth(map(cursorVelocity, 0.0, SMOOTHING_RAMP, SMOOTHING_MIN*SCALE_MULTIPLIER, SMOOTHING_MAX*SCALE_MULTIPLIER));

  if (WACOM) {
    //this.cursor.setActive(true);
    //PVector penPos = tablet.getPosition();
    //superX = penPos.x;
    //superY = penPos.y;

    if (this.tablet.hasNewPoints()) {
      ArrayList<PVector> newPoints = this.tablet.getPoints(); // get new positions since last frame
      for (int i=0; i<newPoints.size(); i++) {
      }
    }
    tablet.clearPoints();
    drawScreen(pgr, SCALE_MULTIPLIER);
  }

  //if (isDrawing) 
  //{ 
  //  if (LAZY_BRUSH) { 
  //    this.strokes.addPoint(new PVector(brush.x, brush.y));
  //  } else { 
  //    this.strokes.addPoint(new PVector(superX, superY));
  //  }
  //  this.cursor.setActive(true);
  //} else
  //{
  //  this.cursor.setActive(false);
  //}

  image(this.pgr, 0, 0, width, height);

  if (this.isSelectFile) {
    selectOutput("Select a file to write to:", "fileSelected");
    this.isSelectFile = false;
  }

  if (this.isSaveSVG) {
    drawSVG(floor(this.superWidth), floor(this.superHeight), this.fileSavePath);
    println("File was saved to " + this.fileSavePath);
    this.isSaveSVG = false;
  }

  if (showMagnifier)
  {
    // Show magnified view at the pointer position
    int mw = magnifier.width;
    int mh = magnifier.height;
    int focusX = isDrawing ? floor(startX) : floor(lazy.getBrush().x);
    int focusY = isDrawing ? floor(startY) : floor(lazy.getBrush().y);
    int mx = constrain(focusX, 0, this.superWidth);
    int my = constrain(focusY, 0, this.superHeight);
    this.magnifier.beginDraw();
    this.magnifier.image(this.pgr.get(floor(mx-mw/2), floor(my-mh/2), floor(mx+mw/2), floor(my+mh/2)), 0, 0);
    this.magnifier.stroke(0);
    this.magnifier.noFill();
    this.magnifier.rect(0, 0, mw-1, mh-1);
    this.magnifier.circle(mw/2, mh/2, cursor.getSize()/2*SCALE_MULTIPLIER);
    this.magnifier.endDraw();
    image(this.magnifier, 10, 10);
  }

  //LazyPoint brush = lazy.getBrush(); // current coordinates

  pushStyle();
  textSize(16);
  fill(0);
  noStroke();
  text( frameRate+" fps", 10, height-10 );
  popStyle();

  float screenRadius = lazyRadius / SCALE_MULTIPLIER;
  float screenBrushX = brush.x / SCALE_MULTIPLIER;
  float screenBrushY = brush.y / SCALE_MULTIPLIER;
  float screenPointerX = 0.0;
  float screenPointerY = 0.0;
  if (WACOM) {
  } else {
    screenPointerX = pointer.x / SCALE_MULTIPLIER;
    screenPointerY = pointer.y / SCALE_MULTIPLIER;
  }

  if (isDebug)
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
  //this.cursor.setPos(screenBrushX,screenBrushY);
  this.cursor.setPos(screenPointerX, screenPointerY);
  this.cursor.display();
  popStyle();

  lazy.reset();

  //noLoop();
}

void startDrawing() {
  println("startDrawing()");
  startX = this.lazy.getBrush().x;
  startY = this.lazy.getBrush().y;
  strokes.addStroke();
  isDrawing = true;
  lazy.enable();
}

void finishDrawing() {
  println("finishDrawing()");
  isDrawing = false;
  lazy.disable();
}

void renderFrame()
{
  //loop();
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
  if (d) {
    isDebug = false;
  }
  svg.beginDraw();
  svg.noFill();
  svg.stroke(0);
  strokes.display(svg, 1.0);
  svg.endDraw();
  if (d) {
    isDebug = true;
  }
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

//void drawCursor(float _x, float _y, float _diameter)
//{
//  pushStyle();
//  blendMode(DIFFERENCE);
//  strokeWeight(1);
//  stroke(0);
//  circle(_x, _y, _diameter);
//  popStyle();
//}

void keyPressed() {
  //renderFrame();
  if (key == CODED) {
    if (keyCode == CONTROL) {
      this.isCtrlPressed = true;
    }
  } else {
    if (this.isCtrlPressed) {
      if (keyCode == 83) // 's' 
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
  } else {
    if (key == 's') // Quick save (no user dialog)
    {
      this.fileSavePath = generateFilePath();
      this.isSaveSVG = true;
    } else if (key == 'z') {
      undo();
    } else if (key == 'y') {
      redo();
    } else if (key == 's') {
      this.isSaveSVG = true;
    } else if (key == 'd') {
      this.isDebug = !this.isDebug;
    } else if (key == 'm') {
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
  //loop();
}

/********************************************/
/*           WACOM BUTTON LISTENERS         */
/********************************************/

public void wacomButtonPressed(int btnIndex) {
  println("button pressed: "+btnIndex);

  switch (btnIndex) {
  case Btn.L1:
    break;
  case Btn.L2:
    break;
  case Btn.L3:
    break;
  case Btn.L4:
    break;
  case Btn.R1:
    break;
  case Btn.R2:
    break;
  case Btn.R3:
    break;
  case Btn.R4:
    break;
  case Btn.TIP: 
    break;
  case Btn.SWITCH_BOTTOM:
    break;
  case Btn.SWITCH_TOP:
    break;
  case Btn.ERASER_TIP:
    break;
  case Btn.STRIP_LEFT:
    break;
  case Btn.STRIP_RIGHT:
    break;
  default:
    println("invalid button index: " + btnIndex);
  }
}

public void wacomButtonReleased(int btnIndex) {
  println("button released: "+btnIndex);
  switch (btnIndex) {
  case Btn.L1:
    break;
  case Btn.L2:
    break;
  case Btn.L3:
    break;
  case Btn.L4:
    break;
  case Btn.R1:
    break;
  case Btn.R2:
    break;
  case Btn.R3:
    break;
  case Btn.R4:
    break;
  case Btn.TIP: 
    break;
  case Btn.SWITCH_BOTTOM:
    break;
  case Btn.SWITCH_TOP:
    break;
  case Btn.ERASER_TIP:
    break;
  case Btn.STRIP_LEFT:
    break;
  case Btn.STRIP_RIGHT:
    break;
  default:
    println("invalid button index: " + btnIndex);
  }
}
