import oscP5.*;
import netP5.*;

class WacomOsc {

  OscP5 oscP5;
  NetAddress myRemoteLocation;

  String oscPlugMethodName = "test";
  String oscAddress = "/test";

  final int TABLET_INDEX = 1;

  int penCount = 3; // there is only one pen but osculator switches the index from 0 to 2 sometimes
  int keyCount = 8;

  Object parent;

  WacomOsc(Object theParent, String theAddress, int theInPort, int theOutPort) {
    parent = theParent;
    initOsc(parent, theAddress, theInPort, theOutPort);
    plugIntuos3();
  }

  void initOsc(Object theParent, String theAddress, int theInPort, int theOutPort) {
    /* start oscP5, listening for incoming messages at port 12000 */
    this.oscP5 = new OscP5(theParent, theInPort);

    /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
     * an ip address and a port number. myRemoteLocation is used as parameter in
     * oscP5.send() when sending osc packets to another computer, device, 
     * application. usage see below. for testing purposes the listening port
     * and the port of the remote location address are the same, hence you will
     * send messages back to this sketch.
     */
    myRemoteLocation = new NetAddress(theAddress, theOutPort);
  }
  
  /********************************************/
  /*             PLUG INTUOS 3                */
  /********************************************/

  void plugIntuos3() {
    println("Entered plugIntuos3()");

    /* TEST */
    this.oscPlugMethodName = "test";
    this.oscAddress = "/test";
    this.oscP5.plug(parent, oscPlugMethodName, oscAddress);

    println("");

    String oscTabletAddr = "wacom";
    String oscPenAddr = "pen";
    String oscEraserAddr = "eraser";
    String oscButtonAddr = "button";
    String oscProximityAddr = "proximity";
    String oscStripAddr = "strip";

    for (int i=0; i<penCount; i++) { // there is only one pen but osculator switches the index from 0 to 2 sometimes

      /* PEN */
      this.oscPlugMethodName = "pen";
      this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscPenAddr + "/" + i; // for example: "/wacom/1/pen/0"
      this.oscP5.plug(parent, oscPlugMethodName, oscAddress);

      /* PEN PROXIMITY */
      this.oscPlugMethodName = "penProximity";
      this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscPenAddr + "/" + i + "/" + oscProximityAddr; // "/wacom/1/pen/0/proximity"
      this.oscP5.plug(parent, oscPlugMethodName, oscAddress);

      /*  TIP */
      this.oscPlugMethodName = "penButton1";
      this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscPenAddr + "/" + i + "/" + oscButtonAddr + "/" + 1; // "/wacom/1/pen/0/button/1"
      this.oscP5.plug(parent, oscPlugMethodName, oscAddress);

      /*  DUOSWITCH */      // pen buttons 2 and 3 are the grip buttons (aka DuoSwitch)
      this.oscPlugMethodName = "penButton2";
      this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscPenAddr + "/" + i + "/" + oscButtonAddr + "/" + 2; // "/wacom/1/pen/0/button/2"
      this.oscP5.plug(parent, oscPlugMethodName, oscAddress);
      this.oscPlugMethodName = "penButton3";
      this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscPenAddr + "/" + i + "/" + oscButtonAddr + "/" + 3; // "/wacom/1/pen/0/button/2"
      this.oscP5.plug(parent, oscPlugMethodName, oscAddress);

      /* ERASER */
      this.oscPlugMethodName = "eraser";
      this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscEraserAddr + "/" + i; // for example: "wacom/1/eraser/0"
      this.oscP5.plug(parent, oscPlugMethodName, oscAddress);

      /* ERASER TIP */
      this.oscPlugMethodName = "eraserButton1";
      this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscEraserAddr + "/" + i + "/" + oscButtonAddr + "/" + 1; // "wacom/1/eraser/0/button/1"
      this.oscP5.plug(parent, oscPlugMethodName, oscAddress);

      /* ERASER PROXIMITY */
      this.oscPlugMethodName = "eraserProximity";
      this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscEraserAddr + "/" + i + "/" + oscProximityAddr; // For example "/wacom/1/eraser/0/proximity"
      this.oscP5.plug(parent, oscPlugMethodName, oscAddress);

      for (int j=0; j<5; j++) {
        this.oscPlugMethodName = "doNothing";

        this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscPenAddr + "/" + i + "/" + j; // For example "/wacom/1/pen/0/2"
        this.oscP5.plug(parent, oscPlugMethodName, oscAddress);

        this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscEraserAddr + "/" + i + "/" + j; // For example "/wacom/1/eraser/0/2"
        this.oscP5.plug(parent, oscPlugMethodName, oscAddress);
      }

      println("");
    }

    /* EXPRESS KEYS */
    for (int i=1; i<=keyCount; i++) {
      this.oscPlugMethodName = "key"+i;
      String oscKeyAddr = "key" + "/" + i;
      this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscKeyAddr; // for example: "/wacom/1/key/8"
      this.oscP5.plug(parent, oscPlugMethodName, oscAddress);
    }

    /*  TOUCH STRIPS */
    this.oscPlugMethodName = "strip1";
    this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscStripAddr + "/" + 1; // "/wacom/1/strip/1"
    this.oscP5.plug(parent, oscPlugMethodName, oscAddress);
    this.oscPlugMethodName = "strip2";
    this.oscAddress = "/" + oscTabletAddr + "/" + TABLET_INDEX + "/" + oscStripAddr + "/" + 2; // "/wacom/1/strip/2"
    this.oscP5.plug(parent, oscPlugMethodName, oscAddress);
  }

  void sendTestMessage() {
    /* createan osc message with address pattern /test */
    OscMessage myMessage = new OscMessage("/test");
    myMessage.add(mouseX); /* add an int to the osc message */
    myMessage.add(mouseY); /* add a second int to the osc message */

    /* send the message */
    this.oscP5.send(myMessage, myRemoteLocation);
  }
}

/********************************************/
/*               OSC EVENT                  */
/********************************************/

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* with theOscMessage.isPlugged() you check if the osc message has already been
   * forwarded to a plugged method. if theOscMessage.isPlugged()==true, it has already 
   * been forwared to another method in your sketch. theOscMessage.isPlugged() can 
   * be used for double posting but is not required.
   */
  if (theOscMessage.isPlugged()==false) {
    /* print the address pattern and the typetag of the received OscMessage */
    //println("### received an osc message.");
    //println("### addrpattern\t"+theOscMessage.addrPattern());
    //println("### typetag\t"+theOscMessage.typetag());
  }
}
