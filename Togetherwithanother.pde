import org.openkinect.processing.*;
import java.nio.*;
import processing.sound.*;

//sound
SoundFile myNoise;
SoundFile myBackground;

//kinect
Kinect2 kinect2A;
Kinect2 kinect2B;

//depth range
int minThresh;
int maxThresh;

//meeting depth
float meetDepth;

float soundVal= 0;

void setup() {


  size(512, 424, P3D);

  myBackground = new SoundFile(this, "background.mp3");
  myBackground.play();
  myNoise = new SoundFile(this, "noise.wav");
  myNoise.play();
  myNoise.amp(0.2);

  kinect2A = new Kinect2(this);
  kinect2A.initDepth();

  kinect2B = new Kinect2(this);
  kinect2B.initDepth();

  //Start tracking each kinect
  kinect2A.initDevice(0);
  kinect2B.initDevice(1);

  minThresh= 0;
  maxThresh= 1500;

  background(0);
}

void draw() {

  int[] depthA = kinect2A.getRawDepth();
  int[] depthB = kinect2B.getRawDepth();

  int[] colorA = {255, 187, 80};
  int[] colorB = {0, 255, 225};

  if (frameCount %8==0) {
    displayDepth(depthA, colorA);
    displayDepth(depthB, colorB);
  }

  int m = second();

  if (m % 20==0) {
    fill(0, 30);
    rect(0, 0, width, height);
  }
}

void displayDepth(int[] depthArr, int[] rgb) {
  pushMatrix();
  translate(width/4, height/2, 50);
  rotateY(3.1); 
  beginShape(POINTS);
  
  PVector avgPos= new PVector(0, 0);
  int totalPoint = 0;
  
  for ( int y = 0; y < kinect2A.depthHeight; y+=4) {
    for (int x = 0; x < kinect2A.depthWidth; x+=4) {

      int offset = x + kinect2A.depthWidth * y;
      int depthData = depthArr[offset];

      PVector point = new PVector();
      point.z = depthArr[offset];
      point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
      point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
      avgPos.add(point);
      totalPoint++;

      int displayVal = 0;

      if ( depthData > minThresh && depthData < maxThresh ) {

        displayVal = round(map(depthData, 2300, 700, 240, 80));
        blendMode(ADD);
        stroke(rgb[0], rgb[1], rgb[2], displayVal);
      } else {
        blendMode(BLEND);
        stroke(0, 0, 0, 48);
      }

      vertex(point.x, point.y, point.z);
    }
  }
  
      float d= avgPos.div(totalPoint).mag();
      d = constrain(d, 0, 800);
      soundVal= map(d, 0, 0.8, 0, 1200);
      println(d);
      myNoise.amp(soundVal);

  endShape();  
  popMatrix();
}


//camera information based on the Kinect v2 hardware
static class CameraParams {
  static float cx = 254.878f;
  static float cy = 205.395f;
  static float fx = 365.456f;
  static float fy = 365.456f;
  static float k1 = 0.0905474;
  static float k2 = -0.26819;
  static float k3 = 0.0950862;
  static float p1 = 0.0;
  static float p2 = 0.0;
}