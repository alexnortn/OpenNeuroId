// Open NeuroImaging Lab Identity
// Alex Norton 2016

import toxi.sim.grayscott.*;
import toxi.math.*;

import toxi.color.*;

int NUM_ITERATIONS = 1000;

GrayScott gs;
ToneMap toneMap;
PImage seed;

void setup() {
  size(512,512);
  
  seed = loadImage("brain9.png");
  seed.loadPixels();

  gs = new PatternedGrayScott(width,height,false);
  // gs.setCoefficients(0.021,0.076,0.12,0.06);
  gs.setCoefficients(0.02,0.078,0.12,0.06); // [20-23]
  // Coral --> [0.23, 0.76, 0.12, 0.06]
  // Brain --> [0.2, 0.7, 0.12, 0.06]
  // Electrons --> [0.23, 0.76, 0.12, 0.06]
  // gs.setCoefficients(0.0077,0.0649,0.1,0.03); // Mitosis

  // create a color gradient for 256 values
  ColorGradient grad=new ColorGradient();
  // NamedColors are preset colors, but any TColor can be added
  // see javadocs for list of names:
  // http://toxiclibs.org/docs/colorutils/toxi/color/NamedColor.html
  grad.addColorAt(0,NamedColor.BLACK);
  // grad.addColorAt(16,NamedColor.CORNSILK);
  // grad.addColorAt(128,NamedColor.PINK);
  // grad.addColorAt(192,NamedColor.PURPLE);
  grad.addColorAt(256,NamedColor.WHITE);
  // this gradient is used to map simulation values to colors
  // the first 2 parameters define the min/max values of the
  // input range (Gray-Scott produces values in the interval of 0.0 - 0.5)
  // setting the max = 0.33 increases the contrast
  toneMap = new ToneMap(0,0.33,grad);

  gs.setRect(width/2, height/2,20,20);
}

void draw() {
  if (mousePressed) {
    gs.setRect(mouseX, mouseY,20,20);
  }

  loadPixels();
  // update the simulation a few time steps
  for(int i=0; i<NUM_ITERATIONS; i++) {
    if (i % 10 == 0) { println("tick " + i); }
    gs.update(1);
  }
  // read out the V result array
  // and use tone map to render colours
  for(int i = 0; i < gs.v.length; i++) {
    pixels[i] = toneMap.getARGBToneFor(gs.v[i]);
  }
  updatePixels();

  // if (frameCount % 500 == 0) {
  //   saveFrame("RD-#####.tga");
  //   gs.reset();
  //   gs.setRect(width/2, height/2,20,20);
  // }

  // drawSeed();

}

void drawSeed() {
  int seedWidth = seed.width;
  int seedHeight = seed.height;
  float x_offset = (width - seedWidth) / 2;
  float y_offset = (height - seedHeight) / 2;   

  image(seed, x_offset, y_offset);
}

void keyPressed() {
  gs.reset();
  gs.setRect(width/2, height/2,20,20);
}

class PatternedGrayScott extends GrayScott {
  public PatternedGrayScott(int w, int h, boolean tiling) {
    super(w,h,tiling);
  }

  public float getFCoeffAt(int x, int y) { // F
    int index = width * y + x;
    if ( red(seed.pixels[index]) == 255 ) {
      return 0;  
    }
    else {
      return f;
    }
  }

  // public float getKCoeffAt(int x, int y) { // K
  //   return k - y * 0.00004; // Vertical Gradation
  // } 
}



