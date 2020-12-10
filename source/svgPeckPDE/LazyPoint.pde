// https://github.com/dulnan/lazy-brush
// Ported from: https://github.com/dulnan/lazy-brush/blob/master/src/LazyPoint.js
// https://www.reddit.com/r/javascript/comments/9paoyp/lazybrush_smooth_canvas_drawing_with_a_mouse_or/

/* 
"Define a "lazy radius" around the brush, 
let's say 100px. Now every time the mouse moves, 
check the distance between mouse and brush. 
If this distance is 105px, move the brush by 5px 
in the direction of the mouse. To achieve this, 
you have to calculate the angle between mouse 
and brush. With the angle and the difference, using 
a bit of sine and cosine, you can determine 
the new coordinates for the brush."
*/

class LazyPoint extends PVector
{
  
  //float x, y;
  
  LazyPoint(float x, float y)
  {
    this.update(x,y);
  }
  
  /**
   * Update the x and y values
   *
   * @param {PVector} point
   */
  void update (float x, float y) {
    this.x = x;
    this.y = y;
  }

  /**
   * Move the point to another position using an angle and distance
   *
   * @param {float} angle The angle in radians
   * @param {float} distance How much the point should be moved
   */
  void moveByAngle (float angle, float distance) {
    // Rotate the angle based on the coordinate system ([0,0] in the top left)
    final float angleRotated = angle + (PI / 2);

    this.x = this.x + (sin(angleRotated) * distance);
    this.y = this.y - (cos(angleRotated) * distance);
  }

  /**
   * Check if this point is the same as another point
   *
   * @param {PVector} point
   * @returns {boolean}
   */
  boolean equalsTo (PVector point) {
    return (this.x == point.x && this.y == point.y);
  }

  /**
   * Get the difference for x and y axis to another point
   *
   * @param {PVector} point
   * @returns {PVector}
   */
  PVector getDifferenceTo (PVector point) {
    return new PVector(this.x - point.x, this.y - point.y);
  }

  /**
   * Calculate distance to another point
   *
   * @param {PVector} point
   * @returns {PVector}
   */
  float getDistanceTo (PVector point) {
    final PVector diff = this.getDifferenceTo(point);

    return sqrt(pow(diff.x, 2) + pow(diff.y, 2));
  }

  /**
   * Calculate the angle to another point
   *
   * @param {PVector} point
   * @returns {float}
   */
  float getAngleTo (PVector point) {
    final PVector diff = this.getDifferenceTo(point);

    return atan2(diff.y, diff.x);
  }

}
