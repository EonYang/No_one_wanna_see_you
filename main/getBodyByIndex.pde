class IndexManager {

  int index;
  int refreshCount;

  IndexManager ( ) {
    index = 0;
    refreshCount = 0;
  }

  void _update(int currentSize) {
    index = floor(random(0, (currentSize )));
  }
  
  void refreshEvery5s (int currentSize) {
    if ((frameCount % 90) == 0) {
      this._update(currentSize);
    //println(frameCount);
    //println(index);
    refreshCount ++;
    }
  }
  
  void refreshWhenSizeGetsSmaller(int currentSize ){
    if (index > (currentSize -1 )) {
      this._update(currentSize);
      refreshCount ++;}
  
  }
  
}


PImage getBodyByIndex (ArrayList<PImage> bodies, int index) {
  PImage chosenPerson;
  chosenPerson = createImage(512, 376, RGB);
  chosenPerson.copy(bodies.get(index), 0, 24, 512, 376, 0, 0, 512, 376);
  return chosenPerson;
}
