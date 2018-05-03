import KinectPV2.*;
KinectPV2 kinect;

import gab.opencv.*;
OpenCV opencvBody;
OpenCV opencvDepth;


// use indexManager to hold and change index of removed person.
IndexManager indexManager = new IndexManager();


// Create 3 PImages for video, body and reference
PImage mainImg;
PImage bodyImg;
PImage refImg;

// Since we need to map those images by ourselves, create PImages for those mapped images.
// Since reference image is generated from main image, no need to map it.
PImage mainImgCropped;
PImage bodyImgCropped;

// Use depth image to separate users. 
PImage depthImgCropped;

int R, G, B, A; 
float range = 1.7;

// For calibrating.
int[] area = {0, 0, 400, 300};
int[] colorCropXYWH = {240, 40, 1520, 1050};

void setup() {   
  println(indexManager.index);
  fullScreen(); 
  //size(1520, 1050);   
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
  depthImgCropped = createImage(512, 376, RGB);
  mainImgCropped = createImage( colorCropXYWH[2], colorCropXYWH[3], RGB);
  refImg = createImage( colorCropXYWH[2], colorCropXYWH[3], RGB);


  // use opencv blur for better performance
  opencvBody = new OpenCV(this, 512, 376);
  opencvDepth = new OpenCV(this, 512, 376);


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

  //iterate through all the users
  if (bodyTrackList.size() != 0) {

    // initialize depthimage, and map it. 
    depthImgCropped.copy(kinect.getDepthImage(), 0, 24, 512, 376, 0, 0, 512, 376);

    // blur the depth image to reduce pixel jitter.
    opencvDepth.loadImage(depthImgCropped);
    opencvDepth.blur(12);
    depthImgCropped = opencvDepth.getOutput();

    //find nearest person;
    //PImage bodyImg2 = FindFirstPerson(bodyTrackList);
    //bodyImgCropped = FindFirstPerson(bodyTrackList);
    
    // change target every 5 seconds or when size gets smaller
    indexManager.refreshEvery5s(frameCount, bodyTrackList.size());
    indexManager.refreshWhenSizeGetsSmaller(bodyTrackList.size());
    bodyImgCropped = getBodyByIndex(bodyTrackList, indexManager.index);

    //PImage bodyImg2 = (PImage)bodyTrackList.get(bodyTrackList.size() - 1);
    //bodyImgCropped.copy(bodyImg2, 0, 24, 512, 376, 0, 0, 512, 376);

    // blur the body image to expand it, in order to get a better covering.
    opencvBody.loadImage(bodyImgCropped);
    opencvBody.blur(8);
    bodyImgCropped = opencvBody.getOutput();

    // Main loop
    for (int y = 0; y < mainImgCropped.height; y++) {
      for (int x = 0; x < mainImgCropped.width; x++) {  

        // get the color of this pixel, see if this pixel belong to a body
        int xP = floor(map(x, 0, mainImgCropped.width, 0, bodyImgCropped.width));
        int yP = floor(map(y, 0, mainImgCropped.height, 0, bodyImgCropped.height));
        PxPGetPixel(xP, yP, bodyImgCropped.pixels, bodyImgCropped.width);               // get the RGB of the image (Bart)
        boolean isBody = false;
        if ((R+G+B) > 10) {  
          isBody = true;
        }

        // get the depth of this pixel, see if it's in range
        //PxPGetPixel(xP, yP, depthImgCropped.pixels, depthImgCropped.width); 
        //int depth = R;

        // if (is body && in range), substitute the pixel.
        //if (isBody == true && ((nearestP < depth && depth < nearestP * range) || depth < 10)) {
        if (isBody == true ) {
          int i = x + y* mainImgCropped.width;
          mainImgCropped.pixels[i] = refImg.pixels[i];
        }
      }
    }
  }
  //bodyImg = kinect.getBodyTrackImage();

  // Draw it
  mainImgCropped.updatePixels();
  translate(width/2, height/2);
  scale(1.25);
  image(mainImgCropped, 0, 0);


  // Codes for debugging and calibrating
  //image(mainImgCropped, colorCropXYWH[0], colorCropXYWH[1]);
  //pushStyle();
  //tint(255, 100);
  //image(bodyImgCropped, area[0], area[1],area[2],area[3]);

  //pushMatrix();
  //pushStyle();
  //scale(0.8);
  //translate(-width/2, -height/2);
  //imageMode(CORNER);

  //image(mainImgCropped, 0, 0);
  //image(bodyImgCropped, 0, 0, 400, 300);
  //image(depthImgCropped, 800, 0, 400, 300);
  //image(refImg, 400, 0, 400, 300);

  //popStyle();
  //popMatrix();
} 

// try to use ref video instead of still ref image.

PImage[] refVideo;

void StoreRefVideo () {
}


// When press, refresh reference image
void mousePressed() {
  refImg.copy(mainImgCropped, 0, 0, colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
  refImg.loadPixels();
}


// codes for calibrating

//void mousePressed(){
//  area[0] = mouseX;
//  area[1] = mouseY;
//}

//void mouseDragged(){
//  area[2] = mouseX - area[0];
//  area[3] = mouseY - area[1];
//}

//void mouseReleased(){
//  area[2] = mouseX - area[0];
//  area[3] = mouseY - area[1];
//  println(area);
//}
