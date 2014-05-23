
import processing.serial.*;
import hypermedia.video.*;
import java.awt.*;


OpenCV opencv;
Serial port;  

boolean seen = false;
boolean gone = false;

int milliGone = 0;
int milliSeen = 0;

// contrast/brightness values
int contrast_value    = 0;
int brightness_value  = 1;

int sizeX = 640, sizeY = 480;

int val;

int dX,X=sizeX/2;
int dY,Y=sizeY/2;

void setup() {
  size( sizeX, sizeY );
  
  println(Serial.list());
  println("totale porte " + Serial.list().length);

// Per il rilevamento automatico dell'arduino (Vedi anche sorgente Arduino)
  String portName = Serial.list()[findport(0)];  
  port = new Serial(this, portName, 9600);
  port.write('@');
  port.clear();
  
// Assegna la libreria OpenCV per il rilevamento facciale  
  opencv = new OpenCV( this );
  opencv.capture( width, height );                   
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );  
  
  // print usage
  println( "\nDrag mouse on X-axis inside this sketch window to change contrast" );
  println( "Drag mouse on Y-axis inside this sketch window to change brightness" );
}

public void stop() {
  opencv.stop();
  super.stop();
}

void draw() {
  background(100);
  // grab a new frame and convert to gray
  opencv.read();
  //opencv.convert( GRAY );
  opencv.contrast( contrast_value );
  opencv.brightness( brightness_value );

  // proceed detection
  Rectangle[] faces = opencv.detect( 1.2, 4, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );

  // display the image
  image( opencv.image(), 0, 0 );

  // draw face area(s)
  noFill();
  stroke(55, 255, 33); 
  
  if(faces.length > 0)
  {
   for ( int i=0; i<faces.length; i++ ) {
    
     if(!seen)
     {
       seen = true;
     }
     milliSeen = millis();

     dX = faces[i].x + (faces[i].width / 2);
     dY = faces[i].y+(faces[i].height/2);
    
     if(dX!=X){
       if(dX<X) port.write('*');
       else{ port.write('+');}
       }
      
       if(dY!=Y){
       if(dY<Y) port.write('#');
       else{ port.write('@');}
       }
    
     rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height );
   
     text(".", (faces[i].x + (faces[i].width / 2)), (faces[i].y+(faces[i].height/2)));

     text( "center:" + "\n" + "x: " + (faces[i].x + (faces[i].width / 2)), 20, 20);
     text( "y: " + (faces[i].y+(faces[i].height/2)), 20, 50);
    
    
     text( "faces[i].x: " + faces[i].x, 110, 20);
     text( "faces[i].width: " + faces[i].width, 110, 50);

     text( "faces[i].y: " + faces[i].x, 110, 80);
     text( "faces[i].height: " + faces[i].height, 110, 110);

     text( "X", sizeX/2, sizeY/2);

     text( "mouseX: " + mouseX, 20, 80);
     text( "mousey: " + mouseY, 20, 110);
   }
  }
  
  else if(seen && (milliSeen + 2000) >= millis())
  {
    if(dX!=X)
    {
      if(dX<X)
      { 
        port.write('*');
      }
      else
      { 
        port.write('+');}
      }
      if(dY!=Y)
      {
       if(dY<Y)
       { 
         port.write('#');
       }
       else
       { 
        port.write('@');
       }
      }
  }
   if(!gone && seen && (milliSeen + 2000) <= millis())
  {
    System.out.println("1");
   gone = true;
   seen = false;
   milliGone = millis();
  }  if (gone && !seen && (milliGone + 10000) < millis()){
    System.out.println("2");
    gone = false;
    for(int k=0; k<100; k++){
    port.write('s');
    System.out.println("OK");
   }
  }
  
}

/**
 * Changes contrast/brigthness values
 */
void mouseDragged() {
  contrast_value   = (int) map( mouseX, 0, width, -128, 128 );
  brightness_value = (int) map( mouseY, 0, width, -128, 128 );
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
      i=Serial.list().length; //Per saltare alla fine del ciclo, odio i break.
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

void keyPressed(){
  if(key == 'w')  port.write('#');
  if(key == 's')  port.write('@');
  if(key == 'd')  port.write('+');
  if(key == 'a')  port.write('*');
  if(key == 'l')  port.write('s');
}

//Simple wire code for Arduino
// Processing software doesn't works if this not run on Arduino board

/*
void setup() {
 Serial.begin(9600);  // Start serial communication at 9600 bps
 while(Serial.read()!=64){
 Serial.write("#");
 }
 Serial.write("\n\n Online..");
 }
 
 void loop() {
 Serial.write('*');
 }
 */
