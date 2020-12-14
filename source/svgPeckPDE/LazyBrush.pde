// Ported from: https://github.com/dulnan/lazy-brush
// https://www.reddit.com/r/javascript/comments/9paoyp/lazybrush_smooth_canvas_drawing_with_a_mouse_or/

final float RADIUS_DEFAULT = 30.0;

class LazyBrush 
{
   
  float radius;
  boolean isEnabled;
  LazyPoint pointer;
  LazyPoint brush, previousBrush;
  float angle;
  float distance;
  boolean hasMoved;
  
 /**
 * constructor
 *
 * @param {float} radius 
 * @param {boolean} enabled
 */
  LazyBrush () 
  {
    this.radius = RADIUS_DEFAULT; // The radius for the lazy area
    this.isEnabled = true;

    this.pointer = new LazyPoint(0.0, 0.0);
    this.brush = new LazyPoint(0.0, 0.0);
    this.previousBrush = new LazyPoint(0.0, 0.0);

    this.angle = 0;
    this.distance = 0;
    this.hasMoved = false;
  }

  /**
   * Enable lazy brush calculations.
   *
   */
  void enable () {
    this.isEnabled = true;
  }

  /**
   * Disable lazy brush calculations.
   *
   */
  void disable () {
    this.isEnabled = false;
  }

  /**
   * @returns {boolean}
   */
  boolean isEnabled () {
    return this.isEnabled;
  }

  /**
   * Update the radius
   *
   * @param {number} radius
   */
  void setRadius (float radius) {
    this.radius = radius;
  }

  /**
   * Return the current radius
   *
   * @returns {float}
   */
  float getRadius () {
    return this.radius;
  }

  ///**
  // * Return the brush coordinates as a simple object
  // *
  // * @returns {object}
  // */
  //LazyPoint getBrushCoordinates () {
  //  return this.brush.toObject()
  //}

  ///**
  // * Return the pointer coordinates as a simple object
  // *
  // * @returns {object}
  // */
  //LazyPoint getPointerCoordinates () {
  //  return this.pointer.toObject()
  //}

  /**
   * Return the brush as a LazyPoint
   *
   * @returns {LazyPoint}
   */
  LazyPoint getBrush () {
    return this.brush;
  }
  
   /**
   * Return the previous brush as a LazyPoint
   *
   * @returns {LazyPoint}
   */
  LazyPoint getPreviousBrush() {
    return this.previousBrush;
  }

  /**
   * Return the pointer as a LazyPoint
   *
   * @returns {LazyPoint}
   */
  LazyPoint getPointer () {
    return this.pointer;
  }

  /**
   * Return the angle between pointer and brush
   *
   * @returns {float} Angle in radians
   */
  float getAngle () {
    return this.angle;
  }

  /**
   * Return the distance between pointer and brush
   *
   * @returns {float} Distance in pixels
   */
  float getDistance () {
    return this.distance;
  }

  /**
   * Return if the previous update has moved the brush.
   *
   * @returns {boolean} Whether the brush moved previously.
   */
  boolean brushHasMoved () {
    return this.hasMoved;
  }

  boolean reset(){
     if( !this.previousBrush.equals(this.brush) )
     {
       //print("previousBrush: x " + previousBrush.x + " y " + previousBrush.y);
       //println("       |      Frame "+ frameCount);
       //print("        brush: x " + brush.x + " y " + brush.y);
       //println("       |      Mouse pressed: " + mousePressed);
       
       this.previousBrush.x = this.brush.x;
       this.previousBrush.y = this.brush.y;
       return true;
     }
     return false;
  }

  /**
   * Updates the pointer point and calculates the new brush point.
   *
   * @param {Point} newPointerPoint
   * @returns {Boolean} Whether any of the two points changed
   */
  boolean update (int newX, int newY) { return this.update(float(newX),float(newY)); }
  
  boolean update (float newX, float newY) {
    this.hasMoved = false;
    
    LazyPoint newPointerPoint = new LazyPoint(newX,newY);
    
    // Did the pointer move?
    if (this.pointer.equalsTo(newPointerPoint)) { 
      return false;
    } else {
      this.pointer = newPointerPoint;
    }

    if (this.isEnabled) {
      this.distance = this.pointer.getDistanceTo(this.brush);
      this.angle = this.pointer.getAngleTo(this.brush);
      
      //println("      pointer: x " + this.pointer.x + " y " + this.pointer.y);
      //println("        brush: x " + this.brush.x + " y " + this.brush.y);
      //println("     distance: " + this.distance);

      if (this.distance > this.radius) {
        this.brush.moveByAngle(this.angle, this.distance - this.radius);
        this.hasMoved = true;
        
        //println("this.distance > this.radius == true" + " | [" + millis() + "]");
      }
    } else {
      this.distance = 0;
      this.angle = 0;
      this.brush.update(newX,newY);
      this.hasMoved = true;
      //println("this.isEnabled == false" + " | [" + millis() + "]");
    }
    // println("");
    
    return true;
  }
}
