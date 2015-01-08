

// Zone triggering program using Kinect depth sensor
// NEEDS SimpleOpenNI and MS SDK
// I made this because Webcam Zone Trigger failed to work at all
// So I built what I needed in Processing in a few hours, including debugging and testing.
// This is for an interactive kiosk where someone will step in front of a device, and the screen will pop up with info about device.
// Enter the coordinates below in the String zones[][] block.


// format for zones are "X", "Y", "Z", depth, radius, and website loaded
// depth is measurement from Z towards camera (gets closer / number goes down)
// {X, Y, Z, depth, radius, website}
// uncomment to add more zones.

//  X       Y      Z     depth  radius       website

String zones[][] = {
  {"285", "365", "2800", "129", "10", "https://github.com/jwcrawley/trigger_zone"}
 ,{"450", "110", "5800", "100", "50", "http://www.google.com/earth/explore/showcase/liquidgalaxy.html"}
 ,{"111", "360", "2400", "100", "15", "https://www.oculus.com/order/dk1/"}
 ,{"340", "200", "4050", "75", "20", "https://www.oculus.com/dk2/"}
 ,{"50", "200", "3700", "100", "50", "https://iutechshowcase.wordpress.com/" }
};

// This is the minimum amount of time for a link to be sent to the browser. The default is 1 second, or 1000 milliseconds. 
int link_delay = 1000 ;



// Library calls for Kinect  
import SimpleOpenNI.*;
SimpleOpenNI  context ;
PFont f;

int last_zone_triggered = -1 ;
int time = millis() ;


void setup()
{
  size(640, 480);

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
  
    printArray(PFont.list());
  f = createFont("Georgia", 24);
  textFont(f);
  
  if(zones.length > 1){
    println(zones.length, "zones loaded into memory.");
  } else {
    println(zones.length, "zone loaded into memory.");
  }
}





void draw()
{
  context.update();
  image(context.depthImage(), 0, 0);
  int[] dmap = context.depthMap() ;
  
  
  if(mousePressed){
    fill(255,0,0);
    text(mouseX, (width * 0.25), (height * 0.90));
    text(mouseY, (width * 0.5), (height * 0.90));
    text( dmap[(mouseY*width)+mouseX] , (width * 0.75), (height * 0.90));
  }


  // Color all zones with a blue circle with 16 diameter.
  for (int i = 0; i < zones.length; i++) {
    fill(0x550000ff);  // Alpha blended blue circles so you can see through them.
    ellipse(Float.parseFloat(zones[i][0]), Float.parseFloat(zones[i][1]), Integer.parseInt(zones[i][4]), Integer.parseInt(zones[i][4]) ) ;
    fill(255,50,0);
    text(i, Integer.parseInt(zones[i][0])+10, Integer.parseInt(zones[i][1])-10);
  }

  // When the amount of time exceeds the link_delay time, it runs the depth detection code.
  if ((millis() - time) >= link_delay) {
    for (int i = 0; i < zones.length; i++) {
      int centerX = Integer.parseInt (zones[i][0]) ;
      int centerY = Integer.parseInt (zones[i][1]) ;
      int radius = Integer.parseInt(zones[i][4]) ;
      
      // The next 2 FORs are to create a bounding square for the circle as defined in Radius above. We dont want to solve for every point in kinect_depth
      
      for (int x = (centerX - radius + 1); x < (centerX + radius); x++ ) {
        for (int y = (centerY - radius + 1); y < (centerY + radius); y++ ) {
          
          // This IF uses the fact that x^2 + y^2 = radius^2 . So we solve count all points that are true for less than or = to radius^2.
          
          if ( (x -  centerX)*(x -  centerX) + (y - centerY)*(y - centerY) <= radius*radius ) {
            int z = Integer.parseInt(zones[i][2]); 
            int depth = Integer.parseInt(zones[i][3]); 
            
            // We dont want to keep loading the same page when someone is in front of a zone.
            if (last_zone_triggered != i) {
              int kinect_depth = dmap[width*y+x]; 
              
              // if the Depth isnt giving a reading, we don't compute it. Getting a depth isnt guaranteed.
              if (kinect_depth != 0) {
                
                // Count as good if the depth measured is between Z and depth.
                if ( (z <= kinect_depth) && (kinect_depth <= (z+depth)) ) {
                  fill(0x55ff0000); // Alpha blended red circles so you can see through them.
                  ellipse(centerX, centerY, radius, radius); // Makes the circles
                  link(zones[i][5]); // Sends the link to the web browser
                  time = millis(); 
                  last_zone_triggered = i; 
                  print("Zone "); 
                  print(i); 
                  println(" Triggered with", kinect_depth, ". Needed between ", z-1, " and ", z+depth+1, " .");
                }
              }
            }
          }
        }
      }
    }
  }
}
