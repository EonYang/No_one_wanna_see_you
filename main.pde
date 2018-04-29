import KinectPV2.*;
KinectPV2 kinect;

import gab.opencv.*;
OpenCV opencvBody;
OpenCV opencvDepth;

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
  fullScreen(); 
  //size(1520, 1050);   

  // Set up the kinect
  kinect = new KinectPV2(this);   
  kinect.enableColorImg(true);    
  kinect.enableBodyTrackImg(true);  
  kinect.enableDepthImg(true);
  kinect.init();

  // initialize PImages
  bodyImgCropped = createImage(512, 376, RGB);
  depthImgCropped = createImage(512, 376, RGB);
  mainImgCropped = createImage( colorCropXYWH[2], colorCropXYWH[3], RGB);
  refImg = createImage( colorCropXYWH[2], colorCropXYWH[3], RGB);


  // Try to use opencv for better performance
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
    opencvDepth.blur(24);
    depthImgCropped = opencvDepth.getOutput();

    //find nearest person;
    //PImage bodyImg2 = FindFirstPerson(bodyTrackList);
    bodyImgCropped = FindFirstPerson(bodyTrackList);

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
        if (R != 0) {  
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
  image(mainImgCropped, 0, 0);

  // Codes for debugging and calibrating
  //image(mainImgCropped, colorCropXYWH[0], colorCropXYWH[1]);
  //pushStyle();
  //tint(255, 100);
  //image(bodyImgCropped, area[0], area[1],area[2],area[3]);
  //popStyle();


  //image(bodyImgCropped, 0, 0, 400, 300);
  //image(depthImgCropped, 800, 0, 400, 300);
  //image(refImg, 400, 0, 400, 300);

  //textSize(120);
  //text(nearestP, 200, 900);
} 

// try to use ref video instead of still ref image.

PImage[] refVideo;

void StoreRefVideo () {
}

// function for get the nearest person depth.
PImage FindFirstPerson (ArrayList<PImage> bodies) {
  PImage firstPerson;
  int fI = 0;
  firstPerson = createImage(512, 376, RGB);
  int nearestPoint = 255;
  for (int i = 0; i < bodies.size(); i++) {
    PImage body;
    body = createImage(512, 376, RGB);
    body.copy(bodies.get(i), 0, 24, 512, 376, 0, 0, 512, 376);
    body.loadPixels();
    int thisNearest = 255;
    for (int y = 0; y < body.height; y+=4) {
      for (int x = 0; x < body.width; x+=4) { 
        PxPGetPixel(x, y, body.pixels, body.width);               // get the RGB of the image (Bart)
        boolean isBody = false;
        if ((R+G+B)/3 >= 10) {  
          isBody = true;
        }
        if (isBody) {
          PxPGetPixel(x, y, depthImgCropped.pixels, depthImgCropped.width);
          int depth = R;
          if (depth < thisNearest && depth >= 40) thisNearest = depth;
        }
      }
    }

    // set first person = this body
    if (thisNearest < nearestPoint) {
      nearestPoint = thisNearest;
      firstPerson = body;
      fI = i;
    }
  }
  //textSize(120);
  //text(nearestPoint, 1600, 700);
  //text(fI, 1600, 900);

  //for (int i = 0; i < bodies.size(); i++) {
  //  PImage bodyTrackImg = (PImage)bodies.get(i);
  //  if (i <= 1) {
  //    image(bodyTrackImg, 1520 + 240*i, 0, 160, 120);
  //  } else if (i <= 3) {
  //    image(bodyTrackImg, 1520 + 240*(i - 2), 120, 160, 120 );
  //  } else if (i <= 5) {
  //    image(bodyTrackImg, 1520 + 240*(i - 4), 240, 160, 120 );
  //  }
  //}

  return firstPerson;
}

// When press, refresh reference image
void mousePressed() {
  refImg.copy(mainImgCropped, 0, 0, colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
  refImg.loadPixels();
  //refImgPixels = new int[2073600];
  //for (int y = 0; y < refImg.height; y++) {
  //  for (int x = 0; x < refImg.width; x++) {  
  //    int i = x + y* width;
  //     refImgPixels[i] = refImg.pixels[i];  
  //  }
  //}
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


void PxPGetPixel(int x, int y, int[] pixelArray, int pixelsWidth) {
  int thisPixel=pixelArray[x+y*pixelsWidth];     // getting the colors as an int from the pixels[]
  A = (thisPixel >> 24) & 0xFF;                  // we need to shift and mask to get each component alone
  R = (thisPixel >> 16) & 0xFF;                  // this is faster than calling red(), green() , blue()
  G = (thisPixel >> 8) & 0xFF;   
  B = thisPixel & 0xFF;
}


void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);                       
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with te colors into the pixels[]
}
