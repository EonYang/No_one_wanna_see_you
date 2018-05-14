PImage openCVBlur (PImage input, int blurLevel){
  PImage r ;
  OpenCV tempImg = new OpenCV(this, 512, 376);
  tempImg.loadImage(input);
  tempImg.blur(blurLevel);
  r = tempImg.getOutput();
  return r;
}