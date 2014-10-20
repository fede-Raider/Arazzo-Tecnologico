
import gab.opencv.OpenCV;
import java.awt.Rectangle;
import processing.serial.Serial;
import processing.video.Capture;

Capture video; //Streamer Video
OpenCV opencv; //Face detection engine
Serial port;   //Arduino serial port

int sizeX = 640, sizeY = 480; //Panel
float scaleFactor = 2; //scale Factor (ma dai?!)
float OuterRadius = 80; //OuterZone;
float InnerRadius = 30; //InnerZone
float OuterDiameter = OuterRadius*2;
float InnerDiameter = InnerRadius*2;

float centerX=(sizeX/2)/scaleFactor, centerY=(sizeY/2)/scaleFactor; //Center

//time
int last_detection; 
int time0 =0;

//detection var
boolean detected; 
boolean detectedOld; // last detection status
float dx, dy; //  face's dx and dy from center point

public static float dist = 0;


public void setup() {
  size(sizeX, sizeY);

  println(Capture.list());
  println("totale porte " + Serial.list().length);
  
  // uncomment if you want to use arduino
   /*
   time0=millis();
   String portName = Serial.list()[findport(0)];
   port = new Serial(this, portName, 9600);
   port.write("@");
   port.write("@");
   port.clear();
   */
  String[] captureDevices = Capture.list();

  video = new Capture(this, 640 / 2, 480 / 2, "Videocamera HD FaceTime (integrata)");
  //video = new Capture(this, 640/2, 480/2,"Fotocamera USB");
  //video = new Capture(this, 640 / 2, 480 / 2, "USB2.0 PC CAMERA");
  opencv = new OpenCV(this, 640 / 2, 480 / 2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); //funziona solo così, prendelo pe' bono

  video.start();
}

//Identifica la faccia più vicina calcolandone la grandezza
int closestFace(Rectangle[] faces) {
  int target = 0;
  for (int i = 0; i < faces.length; i++) {
    if (faces[i].width * faces[i].height > faces[target].width * faces[target].height) {
      target = i;
    }
  }
  return target;
}

public synchronized void draw() {
  frameRate(30);
  scale(scaleFactor);
  opencv.loadImage(video);

  image(video, 0, 0);

  noFill();
  strokeWeight(2);
  Rectangle[] faces = opencv.detect();

  stroke(0, 0, 255);
  ellipse(centerX, centerY, InnerDiameter, InnerDiameter);
  point(centerX, centerY);

  stroke(255, 0, 0);
  ellipse(centerX, centerY, OuterDiameter, OuterDiameter);
  if (faces.length > 0) {
    last_detection=millis();
    int target = closestFace(faces);
    stroke(0, 255, 0);

    dx = faces[target].x + faces[target].width / 2;
    dy = faces[target].y + faces[target].height / 2;

    ellipse(dx, dy, faces[target].width, faces[target].height);
    point(dx, dy);
    line(dx, dy, centerX, centerY);

    dist = sqrt(pow((centerX-dx), 2) + pow((centerY-dy), 2));
    if (dist>InnerRadius) {
      servo(dx, dy, dist);
    }
  } else {
    if (millis()-last_detection>60000*2) {
      println("dove sei?");
      last_detection = millis();
    }
  }
}


public void servo(float dx, float dy, double dist) {
  try{
  if (dx>centerX) {
    if (dist<OuterRadius) {
      port.write("*");
      println("sinistra");
    } else {
      port.write("**");
      println("sinistra2");
    }
  } else {
    if (dist<OuterRadius) {
      port.write("+");
      println("destra");
    } else {
      port.write("++");
      println("destra2");
    }
  }

  if (dy>centerY) {
    if (dist<OuterRadius) {
      port.write("@");
      println("giù");
    } else {
      port.write("@@");
      println("giù2");
    }
  } else if (dist<OuterRadius) {
    port.write("#");
    println("su");
  } else {
    port.write("##");
    println("su2");
  }}
  catch(Exception e){
    //System.err.println("Arduino non collegato");
  }
}

public void keyPressed() {
  if (key == 'w') {
    port.write("#");
  } else if (key == 's') {
    port.write("@");
  } else if (key == 'd') {
    port.write("+");
  } else if (key == 'a') {
    port.write("*");
  } else if (key == 'e') {
    port.write("%");
  } else if (key == 'q') {
    port.write("$");
  } else if (key == 'l') {
    port.write('s');
  }
}

void captureEvent(Capture c) {
  c.read();
}

int findport(int a) {
  
  Serial porttemp;
  int nport = -1;
  for (int i = a; i < Serial.list ().length; i++) {

    println("Ciclo " + i + " " + Serial.list()[i]);

    try {
      porttemp = new Serial(this, Serial.list()[i], 9600);
    } 
    catch (Exception e) {
      return findport(i + 1);
    }

    porttemp.clear();
    delay(10); // giusto il tempo per aprire la porta, altrimenti trova -1
    print(porttemp.read());
    if (porttemp.available()>0) {
      if (porttemp.read() == 35) { // 35 -> #
        nport = i;
        println("Arduino trovato sulla porta " + nport + " in " + (millis()-time0) + "ms");
        i = Serial.list().length;
      }
    }

    porttemp.clear();
    porttemp.stop();
    porttemp = null;
  }
  if (nport == -1) {
    System.err.println("\n\tNessun Ardunino trovato");
    System.exit(0);
  }
  return nport;
}

