class IndexManager {

  int index;

  IndexManager () {
    index = 0;
  }
  
  void updateIndex(){
    if ((frameCount % 100) == 5) { 
      index++;
    }
  }

  int getIndex () {
    return index;
  }

  //void _update(int currentSize) {
  //  index = floor(random(0, (currentSize - 1)));
  //}

  //void refreshEvery5s (int frameCount, int currentSize) {
  //  if ((frameCount % 15) == 5) this._update(currentSize);
  //}

  //void refreshWhenSizeGetsSmaller(int currentSize ) {
  //  if (index > (currentSize -1 )) this._update(currentSize);
  //}
}


//PImage getBodyByIndex (ArrayList<PImage> bodies, int index) {
//  PImage chosenPerson;
//  chosenPerson = createImage(512, 376, RGB);
//  chosenPerson.copy(bodies.get(index), 0, 24, 512, 376, 0, 0, 512, 376);
//  return chosenPerson;
//}
