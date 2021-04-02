import controlP5.*;
import processing.opengl.*;
import peasy.*;
import java.util.ArrayList;

PeasyCam cam;
PMatrix3D currCameraMatrix;
PGraphics3D g3;
ControlP5 MyController;

int sphereWeight = 8;

float angleIncrease = 0.01;
float angle;
float yPos;
float xPos;
float r = 50;
float realR;
float magneticSlider;
float magneticRotation = PI;
float velocitySlider = 1;
float velocityRotation;
float velocityMagnitude;
float forceSlider;
float forceRotation;
float forceMagnitude;

float velocity;
float force;
int switchMagneticField = 2; //if =2 uscente if =1 entrante
color CL_carica = #00FF00;
color CL_magneticField = #006400;

int ON_OFF_carica = 0;
//0=Proton #00FF00 0,255,0; 1=Electron 186,85,211 #BA55D3

ArrayList<MagneticField> magFields = new ArrayList<MagneticField>();
int j;
boolean arrayListLimit = false;

ArrayList<Points> points = new ArrayList<Points>();
float speedX;
float speedY;

float phiY;
float phiX;
float phiSlider;

public void loadArrayList() {
  for (int i = -2500; i < 2500; i+=100) {
    for (int u=0; u<50; u++) {
      magFields.add( new MagneticField(-2500 + 100 * j, i) ); 
      j = (j+1)%50;
    }
  }
}

public void emptyArrayList() {
  for (int i = 0; i < magFields.size(); i++) {
    magFields.remove(i);
    i--;
  }
}

public void switchMagneticField() {
  if (switchMagneticField == 2) {
    switchMagneticField = 1;
    CL_magneticField = #FFA500; //Orange 255,165,0
  } else {
    switchMagneticField = 2;
    CL_magneticField = #006400;
  }
}

public void ON_OFF_carica() {
  if (ON_OFF_carica == 0) {
    ON_OFF_carica = 1;
    CL_carica = #BA55D3;
  } else {
    ON_OFF_carica = 0;
    CL_carica = #00FF00;
  }
}

void setup() {
  size(1000, 1000, P3D);
  g3 = (PGraphics3D)g;
  cam = new PeasyCam(this, 100);
  MyController = new ControlP5(this);
  //min, max, beginning, X, Y, width, height
  MyController.addButton("switchMagneticField", 10, 50, 130, 200, 20);
  MyController.getController("switchMagneticField").setColorBackground(#006400);
  MyController.addButton("ON_OFF_carica", 10, 50, 110, 200, 20);
  MyController.getController("ON_OFF_carica").setColorBackground(CL_carica);
  MyController.addSlider("velocitySlider", 0, 100, 50, 50, 70, 200, 20);
  MyController.getController("velocitySlider").setColorForeground(#4169E1);
  MyController.addSlider("forceSlider", 1, 100, 50, 50, 90, 200, 20);
  MyController.getController("forceSlider").setColorForeground(#DC143C);
  MyController.addSlider("phiSlider", -PI, PI, 0, 50, 150, 200, 20);
  MyController.getController("phiSlider").setColorForeground(#0F38FA);
  MyController.setAutoDraw(false);

  angle = 0;
  stroke(255);
  fill(255);

  loadArrayList();
  //print(k);
}

void draw() {
  background(0);
  if (ON_OFF_carica == 0 && switchMagneticField == 1) { //protone entrante
    protonEntry();
  } else if (ON_OFF_carica == 0 && switchMagneticField == 2) { //protone uscente
    protonExit();
  } else if (ON_OFF_carica == 1 && switchMagneticField == 1) { //elettrone entrante
    electronEntry();
  } else if (ON_OFF_carica == 1 && switchMagneticField == 2) { //elettrone uscente
    electronExit();
  }
  gui();
  MyController.getController("ON_OFF_carica").setColorBackground(CL_carica);
  MyController.getController("switchMagneticField").setColorBackground(CL_magneticField);
}
void protonExit() {
  velocity = velocitySlider;
  force = forceSlider;
  phiX = getPhi()[0];
  phiY = getPhi()[1];
  speedX = map(phiX, -80, 80, -2, 2);
  speedY = map(phiY, -80, 80, -2, 2);
  //-------------------PERPENDICOLAR VELOCITY-----------------------
  if (phiSlider == 0 || phiSlider == -PI || phiSlider == PI) {
    r = bound(50 + velocity - force);
    for (MagneticField mag : magFields) {
      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 2);
      popMatrix();
    }


    drawOrbit(r);

    yPos = r * sin(angle);
    xPos = r * cos(angle);

    points.add( new Points(xPos, yPos, 0, 0) );
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, 0, 0);
    
    pushMatrix();
    translate(xPos, yPos, 0);
    velocityMagnitude = map(velocitySlider, 0, 100, 0, 70);
    drawVelocity(5, 10, velocityMagnitude, 10, velocityRotation, 1);
    forceMagnitude = map(forceSlider, 0, 100, 0, 50);
    drawForce(5, 10, forceMagnitude, 10, forceRotation);
    fill(0, 255, 0);
    sphere(sphereWeight);
    popMatrix();
    angleIncrease = bound(0.125 - r*0.001); 
    velocityRotation += angleIncrease;
    forceRotation += angleIncrease;
    angle += angleIncrease;


    //-------------------VELOCITY = 0---------------------------
  } else if (velocity == 0) {
    pushMatrix();
    translate(xPos, yPos, 0);
    stroke(0, 255, 0);
    fill(0, 255, 0);
    sphere(6);
    popMatrix();
    for (MagneticField mag : magFields) {
      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 2);
      popMatrix();
    }
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, 0, 0);
    //----------------OBLIQUOUS VELOCITY---------------------------
  } else {
    r = bound(50 + velocity - force);

    for (MagneticField mag : magFields) {
      if (mag.x==-3000 || mag.x == 3000 || frameCount % 200 == 1) {
        arrayListLimit = true;
        break;
      }

      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 2);
      popMatrix();
      mag.x = mag.x - speedX;
      mag.y = mag.y - speedY;
    }
    if (arrayListLimit) {
      emptyArrayList();
      loadArrayList();
      arrayListLimit = false;
    }

    drawOrbit(r);

    yPos = r * sin(angle);
    xPos = r * cos(angle);

    //Stores points touched by the particle
    points.add( new Points(xPos, yPos, speedX, speedY) );
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, speedX, speedY);

    pushMatrix();
    translate(xPos, yPos, 0);
    velocityMagnitude = map(velocitySlider, 0, 100, 0, 70);
    drawVelocity(5, 10, velocityMagnitude, 10, velocityRotation, 1);
    forceMagnitude = map(forceSlider, 0, 100, 0, 50);
    drawForce(5, 10, forceMagnitude, 10, forceRotation);
    fill(0, 255, 0);
    sphere(sphereWeight);
    popMatrix();
    angleIncrease = bound(0.125 - r*0.001); 
    velocityRotation += angleIncrease;
    forceRotation += angleIncrease;
    angle += angleIncrease;
  }
}

void protonEntry() {
  //DrawMagneticField magField = new DrawMagneticField(5, 10, 70, 10, 1);                                        //(5, 10, 70, 10, 1);
  velocity = velocitySlider;
  force = forceSlider;
  phiX = getPhi()[0];
  phiY = getPhi()[1];
  speedX = map(phiX, -80, 80, -2, 2);
  speedY = map(phiY, -80, 80, -2, 2);
  
  if (phiSlider == 0 || phiSlider == -PI || phiSlider == PI) {
    r = bound(50 + velocity - force);
    for (MagneticField mag : magFields) {
      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 1);
      popMatrix();
    }

    drawOrbit(r);

    yPos = r * sin(angle);
    xPos = r * cos(angle);
    
    points.add( new Points(xPos, yPos, 0, 0) );
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, 0, 0);

    pushMatrix();
    translate(xPos, yPos, 0);
    velocityMagnitude = map(velocitySlider, 0, 100, 0, 70);
    drawVelocity(5, 10, velocityMagnitude, 10, velocityRotation, -1);
    forceMagnitude = map(forceSlider, 0, 100, 0, 50);
    drawForce(5, 10, forceMagnitude, 10, forceRotation);
    fill(0, 255, 0);
    sphere(sphereWeight);
    popMatrix();
    angleIncrease = bound(0.125 - r*0.001); 
    velocityRotation -= angleIncrease;
    forceRotation -= angleIncrease;
    angle -= angleIncrease;


    //-------------------VELOCITY = 0---------------------------
  } else if (velocity == 0) {
    pushMatrix();
    translate(xPos, yPos, 0);
    stroke(0, 255, 0);
    fill(0, 255, 0);
    sphere(6);
    popMatrix();
    for (MagneticField mag : magFields) {
      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 1);
      popMatrix();
    }
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, 0, 0);
  } else {
    r = bound(50 + velocity - force);

    for (MagneticField mag : magFields) {
      if (mag.x==-3000 || mag.x == 3000 || frameCount % 200 == 1) {
        arrayListLimit = true;
        break;
      }

      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 1);
      popMatrix();
      mag.x = mag.x - speedX;
      mag.y = mag.y - speedY;
    }
    if (arrayListLimit) {
      emptyArrayList();
      loadArrayList();
      arrayListLimit = false;
    }

    drawOrbit(r);

    yPos = r * sin(angle);
    xPos = r * cos(angle);

    //Stores points touched by the particle
    points.add( new Points(xPos, yPos, speedX, speedY) );
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, speedX, speedY);

    pushMatrix();
    translate(xPos, yPos, 0);
    velocityMagnitude = map(velocitySlider, 0, 100, 0, 70);
    drawVelocity(5, 10, velocityMagnitude, 10, velocityRotation, -1);
    forceMagnitude = map(forceSlider, 0, 100, 0, 50);
    drawForce(5, 10, forceMagnitude, 10, forceRotation);
    fill(0, 255, 0);
    sphere(sphereWeight);
    popMatrix();
    angleIncrease = bound(0.125 - r*0.001); 
    velocityRotation -= angleIncrease;
    forceRotation -= angleIncrease;
    angle -= angleIncrease;
  }
}

void electronExit() {
  //counterClockwise
  //drawMagneticField(5, 10, 70, 10, 2);
  velocity = velocitySlider;
  force = forceSlider;
  phiX = getPhi()[0];
  phiY = getPhi()[1];
  speedX = map(phiX, -80, 80, -2, 2);
  speedY = map(phiY, -80, 80, -2, 2);
  
  if (phiSlider == 0 || phiSlider == -PI || phiSlider == PI) {
    r = bound(50 + velocity - force);
    for (MagneticField mag : magFields) {
      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 2);
      popMatrix();
    }

    drawOrbit(r);

    yPos = r * sin(angle);
    xPos = r * cos(angle);
    
    points.add( new Points(xPos, yPos, 0, 0) );
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, 0, 0);

    pushMatrix();
    translate(xPos, yPos, 0);
    velocityMagnitude = map(velocitySlider, 0, 100, 0, 70);
    drawVelocity(5, 10, velocityMagnitude, 10, velocityRotation, -1);
    forceMagnitude = map(forceSlider, 0, 100, 0, 50);
    drawForce(5, 10, forceMagnitude, 10, forceRotation);
    stroke(186, 85, 211);
    fill(186, 85, 211);
    sphere(sphereWeight);
    popMatrix();
    angleIncrease = bound(0.125 - r*0.001); 
    velocityRotation -= angleIncrease;
    forceRotation -= angleIncrease;
    angle -= angleIncrease;

    //-------------------VELOCITY = 0---------------------------
  } else if (velocity == 0) {
    pushMatrix();
    translate(xPos, yPos, 0);
    stroke(186, 85, 211);
    fill(186, 85, 211);
    sphere(6);
    popMatrix();
    for (MagneticField mag : magFields) {
      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 2);
      popMatrix();
    }
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, 0, 0);
  } else {
    r = bound(50 + velocity - force);

    for (MagneticField mag : magFields) {
      if (mag.x==-3000 || mag.x == 3000 || frameCount % 200 == 1) {
        arrayListLimit = true;
        break;
      }

      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 2);
      popMatrix();
      mag.x = mag.x - speedX;
      mag.y = mag.y - speedY;
    }
    if (arrayListLimit) {
      emptyArrayList();
      loadArrayList();
      arrayListLimit = false;
    }

    drawOrbit(r);

    yPos = r * sin(angle);
    xPos = r * cos(angle);

    //Stores points touched by the particle
    points.add( new Points(xPos, yPos, speedX, speedY) );
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, speedX, speedY);

    pushMatrix();
    translate(xPos, yPos, 0);
    velocityMagnitude = map(velocitySlider, 0, 100, 0, 70);
    drawVelocity(5, 10, velocityMagnitude, 10, velocityRotation, -1);
    forceMagnitude = map(forceSlider, 0, 100, 0, 50);
    drawForce(5, 10, forceMagnitude, 10, forceRotation);
    fill(186, 85, 211);
    sphere(sphereWeight);
    popMatrix();
    angleIncrease = bound(0.125 - r*0.001); 
    velocityRotation -= angleIncrease;
    forceRotation -= angleIncrease;
    angle -= angleIncrease;
  }
}

void electronEntry() {
  //clockwise
  //drawMagneticField(5, 10, 70, 10, 1);
  velocity = velocitySlider;
  force = forceSlider;
  phiX = getPhi()[0];
  phiY = getPhi()[1];
  speedX = map(phiX, -80, 80, -2, 2);
  speedY = map(phiY, -80, 80, -2, 2);
    if (phiSlider == 0 || phiSlider == -PI || phiSlider == PI) {
    r = bound(50 + velocity - force);
    for (MagneticField mag : magFields) {
      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 1);
      popMatrix();
    }

    drawOrbit(r);

    yPos = r * sin(angle);
    xPos = r * cos(angle);

    points.add( new Points(xPos, yPos, 0, 0) );
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, 0, 0);
    
    pushMatrix();
    translate(xPos, yPos, 0);
    velocityMagnitude = map(velocitySlider, 0, 100, 0, 70);
    drawVelocity(5, 10, velocityMagnitude, 10, velocityRotation, 1);
    forceMagnitude = map(forceSlider, 0, 100, 0, 50);
    drawForce(5, 10, forceMagnitude, 10, forceRotation);
    stroke(186, 85, 211);
    fill(186, 85, 211);
    sphere(sphereWeight);
    popMatrix();
    angleIncrease = bound(0.125 - r*0.001); 
    velocityRotation += angleIncrease;
    forceRotation += angleIncrease;
    angle += angleIncrease;

    //-------------------VELOCITY = 0---------------------------
  } else if (velocity == 0) {
    pushMatrix();
    translate(xPos, yPos, 0);
    fill(186, 85, 211);
    fill(186, 85, 211);
    sphere(6);
    popMatrix();
    for (MagneticField mag : magFields) {
      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 1);
      popMatrix();
    }
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, 0, 0);
  } else {
    r = bound(50 + velocity - force);

    for (MagneticField mag : magFields) {
      if (mag.x==-3000 || mag.x == 3000 || frameCount % 200 == 1) {
        arrayListLimit = true;
        break;
      }

      pushMatrix();
      translate(mag.x, mag.y);
      mag.drawMagneticField(5, 10, 70, 10, 1);
      popMatrix();
      mag.x = mag.x - speedX;
      mag.y = mag.y - speedY;
    }
    if (arrayListLimit) {
      emptyArrayList();
      loadArrayList();
      arrayListLimit = false;
    }

    drawOrbit(r);

    yPos = r * sin(angle);
    xPos = r * cos(angle);

    //Stores points touched by the particle
    points.add( new Points(xPos, yPos, speedX, speedY) );
    Points p = new Points(xPos, yPos, speedX, speedY);
    p.showPoints(points, speedX, speedY);

    pushMatrix();
    translate(xPos, yPos, 0);
    velocityMagnitude = map(velocitySlider, 0, 100, 0, 70);
    drawVelocity(5, 10, velocityMagnitude, 10, velocityRotation, 1);
    forceMagnitude = map(forceSlider, 0, 100, 0, 50);
    drawForce(5, 10, forceMagnitude, 10, forceRotation);
    fill(186, 85, 211);
    sphere(sphereWeight);
    popMatrix();
    angleIncrease = bound(0.125 - r*0.001); 
    velocityRotation += angleIncrease;
    forceRotation += angleIncrease;
    angle += angleIncrease;
  }
}
void drawForce(float bottom, float top, float h, int sides, float rotation) {
  pushMatrix();
  rotateX(PI / 2);
  rotateY(rotation);
  rotateZ(PI / 2);
  noStroke();
  fill(220, 20, 60); //#DC143C
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

void drawVelocity(float bottom, float top, float h, int sides, float rotation, int switchVelocityRotation) { //if switchVelocityRotation=1 clockwise
  pushMatrix();
  rotateX(PI / 2);
  rotateY(rotation - PI/2 * switchVelocityRotation);
  rotateZ(PI / 2);
  noStroke();
  fill(65, 105, 225);
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



void drawOrbit(float r) {
  stroke(255);
  strokeWeight(0.5);
  noFill();
  ellipse(0, 0, r * 2, r * 2);
}

void drawPhi() {
  stroke(15, 56, 250);
  strokeWeight(3);
  translate(150, 250);
  line(-100, 0, 100, 0);
  float r = 80;
  float x = r * cos(phiSlider);
  float y = r* sin(phiSlider);
  line(0, 0, x, y);
}

float[] getPhi() {
  float r = 80;
  float x = r * cos(phiSlider);
  float y = r * sin(phiSlider);
  float[] phi = new float[2];
  phi[0] = x;
  phi[1] = y;
  //print(phi[0] + "  ");
  //print(phiSlider + "   ");
  return(phi);
}


void gui() {
  currCameraMatrix = new PMatrix3D(g3.camera);
  camera();
  MyController.draw();
  drawPhi();
  g3.camera = currCameraMatrix;
}

float bound(float x) {
  if (x > 0.01) return x;
  else x = 0.01; 
  return x;
}
