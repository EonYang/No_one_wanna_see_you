OpenCV opencvDepth;



//find nearest person;
//PImage bodyImg2 = FindFirstPerson(bodyTrackList);
//bodyImgCropped = FindFirstPerson(bodyTrackList);



// function for get the nearest person depth.
PImage FindFirstPerson (ArrayList<PImage> kinectBodyList, PImage kinectDepthImg) {
  PImage depthImgCropped;
  depthImgCropped = createImage(512, 376, RGB);

  //initialize depthimage, and map it. 
  depthImgCropped.copy(kinectDepthImg, 0, 24, 512, 376, 0, 0, 512, 376);

  // blur the depth image to reduce pixel jitter.
  opencvDepth.loadImage(depthImgCropped);
  opencvDepth.blur(12);
  depthImgCropped = opencvDepth.getOutput();

  PImage firstPerson;
  int fI = 0;
  firstPerson = createImage(512, 376, RGB);
  int nearestPoint = 255;
  for (int i = 0; i < kinectBodyList.size(); i++) {
    PImage body;
    body = createImage(512, 376, RGB);
    body.copy(kinectBodyList.get(i), 0, 24, 512, 376, 0, 0, 512, 376);
    body.loadPixels();
    int thisNearest = 255;
    for (int y = 0; y < body.height; y+=4) {
      for (int x = 0; x < body.width; x+=4) { 
        PxPGetPixel(x, y, body.pixels, body.width);               // get the RGB of the image (Bart)
        boolean isBody = false;
        if ((R+G+B) >= 60) {  
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