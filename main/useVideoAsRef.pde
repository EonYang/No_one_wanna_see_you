

class RefVideoManager {

  int frameLimit;
  PImage[] refImages;
  int lastShownIndex;
  int lastSavedIndex;
  //int lastUpdateFrameCount;
  int updateInterval = 10000;
  boolean isUptoDate;
  int refreshed = 0;

  RefVideoManager() {
    frameLimit = 60;
    lastShownIndex = 0;
    lastSavedIndex = 0;
    //lastUpdateFrameCount = -500;
    refImages = new PImage[frameLimit];
    isUptoDate = false;
  }

  PImage getOneFrame() {

    lastShownIndex ++ ;
    //text(lastShownIndex % frameLimit, 400, 500);
    return refImages[lastShownIndex % frameLimit];
  }

  void storeNewFreame(PImage mainImgCropped) {  
    PImage newFrame = createImage( colorCropXYWH[2], colorCropXYWH[3], RGB);
    newFrame.copy(mainImgCropped, 0, 0, colorCropXYWH[2], colorCropXYWH[3], 0, 0, colorCropXYWH[2], colorCropXYWH[3]);
    refImages[lastSavedIndex] = newFrame;
    text("saving", 0, 100);
    lastSavedIndex ++;
    if (lastSavedIndex == (frameLimit)) {
      lastSavedIndex = 0;
      isUptoDate = true;
      refreshed ++;
    }
  }

  void autoStoreNewFrame(PImage mainImgCropped) {
    
    if (!isUptoDate && frameCount >= 60) { 
      this.storeNewFreame(mainImgCropped);
      
    }

    if ((frameCount % updateInterval) == (updateInterval-1)) isUptoDate = false;
  }

  //void showOneImage() {
  //  //image(refVideo.get(0), 0,0);
  //  //image(refImages[lastShownIndex % frameLimit], 0, 0);
  //  image(refImages[lastShownIndex % frameLimit], 400, 0, 400, 300);
  //  text(lastShownIndex % frameLimit, 400, 500);
  //  lastShownIndex++;
  //}
}
