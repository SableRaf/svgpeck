interface PenSide {
  int
  NONE = 0,
  TIP = 1,
  ERASER = 2;
}

public class WacomPen {
  
  float x = 0.0;
  float y = 0.0;
  float tiltX = 0.0;
  float tiltY = 0.0;
  float pressure = 0.0;
  
  boolean[] btn = {false, false, false};
  
  boolean detected = false;
  
  int state = PenSide.NONE;
  
  WacomPen() {
  }
  
  void detected(int _s) {
    this.detected = true;
    state = _s;
  }
  
  void lost() {
    this.detected = false;
    state = PenSide.NONE;
  }
  
  String getStateName() {
    switch (this.state) {
      case 0:
        return "NONE";
      case 1:
        return "TIP";
      case 2:
        return "ERASER";
      default:
        return "(invalid state: "+state+")";
    }
  }
  
}
