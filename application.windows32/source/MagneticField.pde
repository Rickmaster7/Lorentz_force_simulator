class MagneticField {
  float x;
  float y;
  
  MagneticField(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  void drawMagneticField(float bottom, float top, float h, int sides, int rotation) {
    pushMatrix();
    rotateX(PI / 2);
    rotateY(PI / 2);
    rotateZ(TWO_PI / 2 * rotation);
    noStroke();
    if (rotation == 2) fill(0, 100, 0);
    else fill(255, 165, 0);

    translate(0, h/2, 0);
    float angle;
    float[] x = new float[sides+1];
    float[] z = new float[sides+1];
    float[] x2 = new float[sides+1];
    float[] z2 = new float[sides+1];

    //get x and z position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = TWO_PI / (sides) * i;
      x[i] = sin(angle) * bottom;
      z[i] = cos(angle) * bottom;
    }
    for (int i = 0; i < x.length; i++) {
      angle = TWO_PI / (sides) * i;
      x2[i] = sin(angle) * top;
      z2[i] = cos(angle) * top;
    }

    //draw the bottom of the cylinder
    beginShape(TRIANGLE_FAN);
    vertex(0, -h/2, 0);
    for (int i=0; i < x.length; i++) {
      vertex(x[i], - h/2, z[i]);
    }
    endShape();

    //draw the center of the cylinder
    beginShape(QUAD_STRIP);
    for (int i=0; i < x.length; i++) {
      vertex(x[i], - h/2, z[i]);
      vertex(x2[i], - h/2, z[i]);
    }
    endShape();

    //draw the top of the cylinder
    beginShape(TRIANGLE_FAN);
    vertex(0, h/2, 0);
    for (int i=0; i < x.length; i++) {
      vertex(x2[i], - h/2, z[i]);
    }
    endShape();

    popMatrix();
  }
}
