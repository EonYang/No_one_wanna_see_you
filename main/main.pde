import KinectPV2.*;
KinectPV2 kinect;

import gab.opencv.*;
import spout.*;

PGraphics canvas;
Spout sender;

// use indexManager to hold and change index of removed person.
IndexManager indexManager = new IndexManager();
RefVideoManager alfredo = new RefVideoManager();


// Create 3 PImages for video, body and reference
PImage mainImg;
PImage bodyImg;
PImage refImg;

// Create ArrayList of image to be refVideo
//ArrayList<PImage> refVideo;

// Since we need to map those images by ourselves, create PImages for those mapped images.
// Since reference image is generated from main image, no need to map it.
PImage mainImgCropped;
PImage bodyImgCropped;


int R, G, B, A; 

// For calibrating.
int[] area = {0, 0, 400, 300};
int[] colorCropXYWH = {230, 20, 1520, 1050};

void setup() {   
  //fullScreen(); 

  size(1520, 1050, P3D); 
  canvas = createGraphics(1520, 1050, P3D);
  sender = new Spout(this);
  sender.createSender("no one wanna see you", 1520, 1050);

  imageMode(CENTER);
  frameRate(30);



  // Set up the kinect
  kinect = new KinectPV2(this);   
  kinect.enableColorImg(true);    
  kinect.enableBodyTrackImg(true);  
  //kinect.enableDepthImg(true);
  kinect.init();

  // initialize PImages
  bodyImgCropped = createImage(512, 376, RGB);
  mainImgCropped = createImage( colorCropXYWH[2], colorCropXYWH[3], RGB);
  refImg = createImage( colorCropXYWH[2], colorCropXYWH[3], RGB);

  // Initialize reference image
  mainImg = kinect.getColorImage();
  mainImgCropped.copy(mainImg, colorCropXYWH[0], colorCropXYWH[1], colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
  refImg.copy(mainImgCropped, 0, 0, colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
  refImg.loadPixels();
}  

void draw() {  
  background(50);

  mainImg = kinect.getColorImage();
  mainImgCropped.copy(mainImg, colorCropXYWH[0], colorCropXYWH[1], colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
  mainImgCropped.loadPixels();

  //obtain an ArrayList of the users currently being tracked
  ArrayList<PImage> bodyTrackList = kinect.getBodyTrackUser();

  int tempIndex = 0;

  //iterate through all the bodies
  if (bodyTrackList.size() == 0) {
    alfredo.autoStoreNewFrame(mainImgCropped);
  } else {

    if (alfredo.refImages[alfredo.frameLimit-1] != null) {
      refImg = alfredo.getOneFrame();

      indexManager.updateIndex();
      tempIndex = indexManager.getIndex() % bodyTrackList.size();

      bodyImgCropped.copy(bodyTrackList.get(tempIndex), 0, 24, 512, 376, 0, 0, 512, 376);

      // blur the body image to expand it, in order to get a better covering, check openCVBlur tab for more.
      bodyImgCropped = openCVBlur(bodyImgCropped, 16);

      mainImgCropped = removePerson(mainImgCropped, bodyImgCropped, refImg);
    }
  }
  // Draw it
  //mainImgCropped.updatePixels();
  //translate(width/2, height/2);
  ////scale(1.25);
  //image(mainImgCropped, 0, 0);

textSize(60);
    text(alfredo.refreshed, 0, 100);
  // draw on canvas and send to isadora
  canvas.beginDraw();
  canvas.lights();
  canvas.image(mainImgCropped, 0, 0);
  canvas.endDraw();
  sender.sendTexture(canvas);
} 

// When press, refresh reference image
void mousePressed() {
  refImg.copy(mainImgCropped, 0, 0, colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
  refImg.loadPixels();
}

void keyPressed() {
  if (key == 'z') {
    alfredo.storeNewFreame(mainImgCropped);
  }
}
