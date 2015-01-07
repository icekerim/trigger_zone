// Zone triggering program using Kinect depth sensor
// NEEDS SimpleOpenNI and MS SDK
// I made this because Webcam Zone Trigger failed to work at all
// So I built what I needed in Processing in a few hours, including debugging and testing.
// This is for an interactive kiosk where someone will step in front of a device, and the screen will pop up with info about device.
// Enter the coordinates below in the String zones[][] block.


// format for zones are "X", "Y", "Z", depth, and website loaded
// depth is measurement from Z towards camera (gets closer / number goes down)
// {X, Y, Z, depth, website}
// uncomment to add more zones.

String zones[][] = {
 {"221", "247", "3300", "100", "https://github.com/jwcrawley/trigger_zone"}
,{"450", "120", "5800", "300", "http://www.google.com/earth/explore/showcase/liquidgalaxy.html"}
,{"330", "210", "4100", "150", "https://www.oculus.com/dk2/"} 
,{"330", "210", "4100", "150", "https://www.oculus.com/dk2/"}
};
// This is the minimum amount of time for a link to be sent to the browser. The default is 1 second, or 1000 milliseconds. 
int link_delay = 1000 ;


int last_zone_triggered = -1 ; 
  
  
// Library calls for Kinect  
import SimpleOpenNI.*;
SimpleOpenNI  context;



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
}





void draw()
{
  context.update();
  image(context.depthImage(), 0, 0);
  int[] dmap = context.depthMap() ;
  
  
  // Color all zones with a blue circle with 16 diameter.
  for(int i = 0 ; i < zones.length ; i++) {
    fill(0,0,255);
    ellipse(Float.parseFloat(zones[i][0]), Float.parseFloat(zones[i][1]), 16, 16) ;  
  }

  // When the amount of time exceeds the link_delay time, it runs the depth detection code.
  if((millis() - time) >= link_delay){
    for(int i = 0 ; i < zones.length ; i++) {
     int x = Integer.parseInt(zones[i][0]) ;
     int y = Integer.parseInt(zones[i][1]) ;
     int z = Integer.parseInt(zones[i][2]) ;
     int depth = Integer.parseInt(zones[i][3]) ;
       if(last_zone_triggered != i){
         if((dmap[width*y+x]) != 0){
           if( ((z-depth)  <= dmap[width*y+x]) && (dmap[width*y+x] <= z)){
             fill(255,0,0);
             ellipse(Float.parseFloat(zones[i][0]), Float.parseFloat(zones[i][1]), 16, 16) ;
             link(zones[i][4]);
             time = millis() ;
             last_zone_triggered = i ;
             print(" iteration ");
             print(i);
             println("  ", dmap[width*y+x] );
             
           }
         }
        }
    }
  }

}
