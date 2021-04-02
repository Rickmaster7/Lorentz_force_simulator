class Points {
  float x;
  float y;
  float speedX;
  float speedY;
  Points(float x, float y, float speedX, float speedY) {
    this.x = x;
    this.y = y;
    this.speedX = speedX;
    this.speedY = speedY;
  }
  
  void showPoints(ArrayList<Points> points, float speedX, float speedY) {
    for (Points p : points) {
      stroke(255);
      strokeWeight(2);
      point(p.x+p.speedX, p.y+p.speedY);
      //p.state--;
      p.speedX-=speedX;
      p.speedY-=speedY;
    }
  }
}
