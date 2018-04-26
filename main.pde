import KinectPV2.*;
KinectPV2 kinect;
//import gab.opencv.*;
//OpenCV opencvBody;
PImage mainImg;
PImage bodyImg;
PImage refImg;
PImage depthImgCropped;
int[] refImgPixels;
boolean isBody;
int R, G, B, A; 
int range = 30;

PImage bodyImgCropped;
PImage mainImgCropped;

int[] area = {0, 0, 400, 300};
int[] colorCropXYWH = {250, 10, 1520, 1050};



void setup() {   
  fullScreen(); 
  //size(1520, 1050);   
  kinect = new KinectPV2(this);   
  kinect.enableColorImg(true);    
  kinect.enableBodyTrackImg(true);  
  kinect.enableDepthImg(true);
  kinect.init();
  bodyImgCropped = createImage(512, 376, RGB);
  depthImgCropped = createImage(512, 376, RGB);
  //opencvBody = new OpenCV(this, 512, 376);
  mainImgCropped = createImage( colorCropXYWH[2], colorCropXYWH[3], RGB);
  refImg = createImage( colorCropXYWH[2], colorCropXYWH[3], RGB);
  mainImg = kinect.getColorImage();

  //opencvBody.loadImage(bodyImgCropped);
  mainImgCropped.copy(mainImg, colorCropXYWH[0], colorCropXYWH[1], colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
  refImg.copy(mainImgCropped, 0, 0, colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
  refImg.loadPixels();
}  

void draw() {  
  background(255);

  mainImg = kinect.getColorImage();
  //image(mainImg, 0,0);
  bodyImg = kinect.getBodyTrackImage();
  bodyImgCropped.copy(bodyImg, 0, 24, 512, 376, 0, 0, 512, 376);
  //opencvBody.loadImage(bodyImgCropped);
  //bodyImgCropped.filter(BLUR, 12);
  // initialize depthimage
  // crop
  // depthImgCropped
  bodyImg = kinect.getBodyTrackImage();
  depthImgCropped.copy(kinect.getDepthImage(), 0, 24, 512, 376, 0, 0, 512, 376);
  depthImgCropped.filter(BLUR, 2);

  mainImgCropped.copy(mainImg, colorCropXYWH[0], colorCropXYWH[1], colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
  bodyImgCropped.loadPixels();
  mainImgCropped.loadPixels();
  //find nearest person, range ex: 60 - 90;
  
  int nearestP = FindFirstPerson();
  
  for (int y = 0; y < mainImgCropped.height; y++) {
    for (int x = 0; x < mainImgCropped.width; x++) {  
      int xP = floor(map(x, 0, mainImgCropped.width, 0, bodyImgCropped.width));
      int yP = floor(map(y, 0, mainImgCropped.height, 0, bodyImgCropped.height));
      PxPGetPixel(xP, yP, bodyImgCropped.pixels, bodyImgCropped.width);               // get the RGB of the image (Bart)
      isBody = false;
      if (R < 240) {  
        isBody = true;
      }
      PxPGetPixel(xP, yP, depthImgCropped.pixels, depthImgCropped.width); 
      int depth = R;
      // if (is body && in range)
      if (isBody == true && ((nearestP < depth && depth < nearestP + range) || depth < 10)) {
        int i = x + y* mainImgCropped.width;
        mainImgCropped.pixels[i] = refImg.pixels[i];
      }
    }
  } 
  mainImgCropped.updatePixels();
  image(mainImgCropped, 0, 0);
  //image(mainImgCropped, colorCropXYWH[0], colorCropXYWH[1]);
  //pushStyle();
  //tint(255, 100);
  //image(bodyImgCropped, area[0], area[1],area[2],area[3]);
  //popStyle();
  //image(refImg, 400, 0, 400, 300);
  //blend(refImg, 0,0,1920,1080,0,0,1920,1080,ADD);

  
  image(bodyImgCropped, 0, 0, 400, 300);
  image(depthImgCropped, 400, 0, 400, 300);
  image(refImg, 800, 0, 400, 300);
  
  textSize(120);
  text(nearestP, 200, 900);
} 

PImage[] refVideo;


void StoreRefVideo () {
}

int FindFirstPerson () {
  int nearest = 255;
  for (int y = 0; y < depthImgCropped.height; y+=4) {
    for (int x = 0; x < depthImgCropped.width; x+=4) { 
      PxPGetPixel(x, y, bodyImgCropped.pixels, bodyImgCropped.width);               // get the RGB of the image (Bart)
      isBody = false;
      if (R) {  
        isBody = true;
      }
      if (isBody) {
        PxPGetPixel(x, y, depthImgCropped.pixels, depthImgCropped.width);
        int depth = R;
        if (depth < nearest && depth >= 50) nearest = depth;
      }
    }
  }
  return nearest;
}

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
