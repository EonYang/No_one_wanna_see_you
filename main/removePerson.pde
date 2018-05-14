PImage removePerson (PImage targetImg, PImage bodyImg, PImage refImg) {

  // Main loop
  for (int y = 0; y < targetImg.height; y++) {
    for (int x = 0; x < targetImg.width; x++) {  

      // get the color of this pixel, see if this pixel belong to a body
      int xP = floor(map(x, 0, targetImg.width, 0, bodyImg.width));
      int yP = floor(map(y, 0, targetImg.height, 0, bodyImg.height));
      PxPGetPixel(xP, yP, bodyImg.pixels, bodyImg.width);               // get the RGB of the image (Bart)
      boolean isBody = false;
      if ((R+G+B) > 10) {  
        isBody = true;
      }
      if (isBody == true ) {
        int i = x + y* targetImg.width;
        targetImg.pixels[i] = refImg.pixels[i];
      }
    }
  }

  return targetImg;
}