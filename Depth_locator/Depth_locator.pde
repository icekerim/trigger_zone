// This program is used to find the X, Y, and depth of coordinate to feed the other sketch
// Simply run it with your kinect, and then click on the point you want a tripwire. It will give X, Y, Depth at the bottom of the screen


import SimpleOpenNI.*;
PFont f;

SimpleOpenNI  context;

void setup()
{
  size(640, 480);
  // background(200, 0, 0);
  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // mirror is by default enabled
  context.setMirror(true);
  // enable depthMap generation 
  context.enableDepth();

  // Text display stuff
  printArray(PFont.list());
  f = createFont("Georgia", 24);
  textFont(f);
  

}

void draw()
{
  context.update();
  image(context.depthImage(), 0, 0);
  
  if(mousePressed)
  {
    fill(255,0,0);
    int[] dmap = context.depthMap() ;
    text(mouseX, (width * 0.25), (height * 0.90));
    text(mouseY, (width * 0.5), (height * 0.90));
    text( dmap[(mouseY*width)+mouseX] , (width * 0.75), (height * 0.90));
  }
}

