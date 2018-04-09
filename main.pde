import KinectPV2.*;
KinectPV2 kinect;
PImage bg;
PImage prot;
PImage protResize;
PImage cover;
int[] coverPixels;
boolean isBody;
int R, G, B, A; 


void setup() {   
  size(1920, 1080);   
  kinect = new KinectPV2(this);   
  kinect.enableColorImg(true);    
  kinect.enableBodyTrackImg(true);   
  kinect.init();
  cover = kinect.getColorImage();
  cover.loadPixels();
  coverPixels = null;
  coverPixels = cover.pixels;
}  
void draw() {   
  bg = kinect.getColorImage();
  //background(bg);
  prot = kinect.getBodyTrackImage();
  prot.loadPixels();
  bg.loadPixels();
  for (int y = 0; y < cover.height; y++) {
    for (int x = 0; x < cover.width; x++) {  
      int xP = floor(map(x, 0, cover.width, 0, prot.width));
      int yP = floor(map(y, 0, cover.height, 0, prot.height));
      PxPGetPixel(xP, yP, prot.pixels, prot.width);               // get the RGB of the image (Bart)
      isBody = false;
      if ((R+G+B)/3 < 200) {  
        isBody = true;
      }
      PxPGetPixel(x, y, cover.pixels, cover.width); 
      int i = x + y* width;
      if (isBody == true) {
        bg.pixels[i] = coverPixels[i];
      } ;   
    }
  } 
  bg.updatePixels();
  image(bg, 0, 0);
  image(prot, 0, 0);
  //image(cover, 0, 0);
  //blend(cover, 0,0,1920,1080,0,0,1920,1080,ADD);
} 

void mousePressed(){
  cover = kinect.getColorImage();
  cover.loadPixels();
  coverPixels = new int[2073600];
  for (int y = 0; y < cover.height; y++) {
    for (int x = 0; x < cover.width; x++) {  
      int i = x + y* width;
       coverPixels[i] = cover.pixels[i];  
    }
  } 
}


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
