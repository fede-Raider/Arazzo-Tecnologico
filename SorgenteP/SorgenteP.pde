

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

int centerSize = 40;
int outerSize  = 80;

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
 
 
  //String portName = Serial.list()[findport(0)];
  String portName = Serial.list()[7];
  port = new Serial(this, portName, 9600);
  port.write('@');
  port.clear();
  
  String[] captureDevices = Capture.list();
  
  //video = new Capture(this, 640/2, 480/2,"Fotocamera USB");
  video = new Capture(this, 640/2, 480/2,"USB2.0 PC CAMERA");
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  
  //println(Capture.list());

  video.start();

}

//Identifica la faccia più vicina calcolandone la grandezza
int closestFace(Rectangle[] faces){
  int target = 0;
  for(int i = 0; i < faces.length; i++){
    if(faces[i].width * faces[i].height > faces[target].width * faces[target].height)
      target = i;
  }
  return target;
}
    
int Distance(Rectangle target){
  return X - target.height;
}

float DistanceM(int distance){
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
  
  if(faces.length > 0){
    int target = closestFace(faces);
    stroke(0, 255, 0);
     
    
    rect(faces[target].x,faces[target].y,faces[target].width,faces[target].height);
    point(faces[target].x+faces[target].width/2, faces[target].y+faces[target].height/2);
    line(faces[target].x+faces[target].width/2,faces[target].y+faces[target].height/2,
         centerX,centerY);
     
    dX = faces[target].x+faces[target].width/2;
    dY = faces[target].y+faces[target].height/2; 
    
    
    if(!agganciato){
     actualTime = millis();
     if(actualTime - prevTime > 100)
     {
      prevTime = actualTime;
     if(dX > centerRight)
      if(dX < outerRight)
       port.write("*");
      else
       port.write("**");
       
     if(dX < centerLeft)
      if(dX > outerRight)
       port.write("+");
      else
       port.write("++");
       
     if(dY > centerUp)
      if(dY < outerUp)
       port.write("@");
      else
       port.write("@@");
       
     if(dY < centerDown)
      if(dY > outerDown)
       port.write("#");
      else
       port.write("##");
     }
    if(dY < centerUp && dY > centerDown 
      && dX < centerRight && dX > centerLeft)
       agganciato = true; 
    
    }
    else{
      if(dY > centerUp || dY < centerDown
       || dX > centerRight || dX < centerLeft)
        agganciato = false;
    }
  } 
}

void keyPressed(){
  if(key == 'w')  port.write("#");
  if(key == 's')  port.write("@");
  if(key == 'd')  port.write("+");
  if(key == 'a')  port.write("*");
  if(key == 'e')  port.write("%");
  if(key == 'q')  port.write("$");
  if(key == 'l')  port.write('s');
}

void captureEvent(Capture c) {
  c.read();
}

int findport(int a) {  
  Serial porttemp;
  int nport=-1;
  for (int i = a; i < Serial.list().length; i++) { 

    println("Ciclo " + i +" "+  Serial.list()[i]);

    try {
      porttemp = new Serial (this, Serial.list()[i], 9600);
    } 
    catch(Exception e ) {
      return findport(i+1);
    }

    porttemp.clear();
    delay(50); // giusto il tempo per aprire la porta, altrimenti trova -1

    if (porttemp.read() == 35) { // 35 -> #
      nport=i;
      println("Arduino trovato sulla porta " + nport + " in " + millis() + "ms");
      i=Serial.list().length;
    } 

    porttemp.clear();
    porttemp.stop();
    porttemp = null;
  }
  if (nport==-1) {
    System.err.println("\n\tNessun Ardunino trovato");
    System.exit(0);
  }
  return nport;
}

