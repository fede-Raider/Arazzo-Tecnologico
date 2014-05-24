

import processing.serial.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;
Serial port;  

boolean agganciato = false;

int sizeX = 640, sizeY = 480;

int actualTime;
int prevTime;

int dX,X=sizeX/2;
int dY,Y=sizeY/2;

int centerSize = 60;
int outerSize  = 120;

float centerX = X/2;
float centerY = Y/2;

float centerLeft = centerX + centerSize/2;
float centerRight = centerX - centerSize/2;
float centerUp = centerY - centerSize/2;
float centerDown = centerY + centerSize/2;

float outerLeft = centerX + outerSize/2;
float outerRight = centerX - outerSize/2;
float outerUp = centerY - outerSize/2;
float outerDown = centerY + outerSize/2;

void setup() 
{
  size( sizeX, sizeY );
  
  println(Capture  .list());
  println("totale porte " + Serial.list().length);
  
  actualTime = millis();
  prevTime = millis();
 
  String portName = Serial.list()[9];
  port = new Serial(this, portName, 9600);
  port.write('@');
  port.clear();
  
  String[] captureDevices = Capture.list();
  
  video = new Capture(this, 640/2, 480/2,"Fotocamera USB");
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  
  //println(Capture.list());

  video.start();

}


//Identifica la faccia più vicina calcolandone la grandezza
int closestFace(Rectangle[] faces)
{
  int target = 0;
  for(int i = 0; i < faces.length; i++)
  {
    if(faces[i].width * faces[i].height > faces[target].width * faces[target].height)
      target = i;
  }
  return target;
}
    
int Distance(Rectangle target)
{
  return X - target.height;
}

float DistanceM(int distance) //Approssimativo è dir poco
{
  return distance / 3.8;
}

void draw() {
   scale(2);
  opencv.loadImage(video);

  image(video, 0, 0 );

  noFill();
  strokeWeight(2);
  Rectangle[] faces = opencv.detect();
  
  stroke(0,0,255);
  rect(centerRight,centerUp,centerSize,centerSize);
  point(centerX,centerY);
  
  stroke(255,0,0);
  rect(outerRight,outerUp,outerSize,outerSize);
  
  if(faces.length > 0)
  {
    int target = closestFace(faces);
    stroke(0, 255, 0);
     
    
    rect(faces[target].x,faces[target].y,faces[target].width,faces[target].height);
    point(faces[target].x+faces[target].width/2, faces[target].y+faces[target].height/2);
    line(faces[target].x+faces[target].width/2,faces[target].y+faces[target].height/2,
         centerX,centerY);
     
    dX = faces[target].x+faces[target].width/2;
    dY = faces[target].y+faces[target].height/2; 
    
    
    if(!agganciato)
    {
     actualTime = millis();
     if(actualTime - prevTime > 100)
     {
      prevTime = actualTime;
     if(dX > centerRight)
      if(dX < outerRight)
       port.write("*1");
      else
       port.write("*2");
       
     if(dX < centerLeft)
      if(dX > outerRight)
       port.write("+1");
      else
       port.write("+2");
       
     if(dY > centerUp)
      if(dY < outerUp)
       port.write("@1");
      else
       port.write("@2");
       
     if(dY < centerDown)
      if(dY > outerDown)
       port.write("#1");
      else
       port.write("#2");
     }
     if(dY < centerUp && dY > centerDown 
      && dX < centerRight && dX > centerLeft)
       agganciato = true; 
    
    }
    else
    {
      if(dY > outerUp || dY < outerDown
       || dX > outerRight || dX < outerLeft)
        agganciato = false;
    }
  }
  
}


void keyPressed(){
  if(key == 'w')  port.write("#2");
  if(key == 's')  port.write("@2");
  if(key == 'd')  port.write("+2");
  if(key == 'a')  port.write("*2");
  if(key == 'e')  port.write("%2");
  if(key == 'q')  port.write("$2");
  if(key == 'l')  port.write('s');
}


void captureEvent(Capture c) {
  c.read();
}

