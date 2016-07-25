// Open NeuroImaging Lab Identity
// Alex Norton 2016

import toxi.sim.grayscott.*;
import toxi.math.*;
import toxi.color.*;

import processing.pdf.*;
import java.io.File; // Make Directory

int NUM_ITERATIONS = 10;
int MAX_ITERATIONS = 5000;

int _iteration;
int _counter = 0;
String _id;

GrayScott gs;
ToneMap toneMap;

PImage seed;
PFont metaFont;

float _f;
float _k;
float _dU;
float _dV;

void setup() {
	size(512,512);

	_counter++;
	_iteration = 0;

	_id = "#" + 
		str(
			char(int(random(33,126))) +
			char(int(random(33,126))) +
			char(int(random(33,126))) +
			char(int(random(33,126))) +
			char(int(random(33,126))) +
			char(int(random(33,126))) 
		);

	// Axial Brain Mask
	seed = loadImage("brain9.png");
	seed.loadPixels();

	// Typography
	metaFont = createFont("PostGrotesk-Medium.otf", 12);
	textFont(metaFont);

	gs = new PatternedGrayScott(width,height,false);

	updateCoefficients();
	
	// f | k | dU | dV
	gs.setCoefficients(_f, _k, _dU, _dV); // [20-23]

	// gs.setCoefficients(0.021,0.076,0.12,0.06);
	// Coral --> [0.23, 0.76, 0.12, 0.06]
	// Brain --> [0.2, 0.7, 0.12, 0.06]
	// Electrons --> [0.23, 0.76, 0.12, 0.06]
	// gs.setCoefficients(0.0077,0.0649,0.1,0.03); // Mitosis

	// Perhaps you could store the coefficients in a sort of object?
	// Different scales effect the density of the simulation.

	gs.reset();

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

	runGrayScott(NUM_ITERATIONS);
	_iteration += NUM_ITERATIONS;

	drawText();

	if (_iteration >= MAX_ITERATIONS) {
		outputSim();
		setup();
	}
}

void drawText() {
	fill(200);
	
	int leading = 25;
	int halfLeading = 20;
	int thirdLeading = 15;

	int doubleInset = 50;
	int inset = 25;
	int halfInset = 15;

	text("GrayScott: " + _id, halfInset, halfLeading * 2);
	text("Iteration: " + _counter, halfInset, halfLeading * 3);

	pushMatrix();
		translate(0, 10);
		text("Coefficients", halfInset, halfLeading * 4);
			pushMatrix();
			translate(0, 10);
				text("f:", inset, thirdLeading * 6);
				text(_f, doubleInset, thirdLeading * 6);

				text("k:", inset, thirdLeading * 7);
				text(_k, doubleInset, thirdLeading * 7);

				text("dU:", inset, thirdLeading * 8);
				text(_dU, doubleInset, thirdLeading * 8);

				text("dV:", inset, thirdLeading * 9);
				text(_dV, doubleInset, thirdLeading * 9);
			popMatrix();
	popMatrix();
}

void runGrayScott(int iterations) {
	loadPixels();
	
	// update the simulation a few time steps
	for(int i = 0; i < iterations; i++) {
		// if (i % 10 == 0) { println("tick " + i); }
		gs.update(1);
	}
	// read out the V result array
	// and use tone map to render colours
	for(int i = 0; i < gs.v.length; i++) {
		pixels[i] = toneMap.getARGBToneFor(gs.v[i]);
	}

	updatePixels();
}

void outputSim() {
	runGrayScott(1);
	saveFrame("RD-" + _id + ".tga");
}


void saveVector() {
	PGraphics tmp = null;
	tmp = beginRecord(PDF, _counter + "_" + "GS." + ".pdf");
		outputSim();
	endRecord();
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

// Iterate through many many values of each
void updateCoefficients() {
	_f =  random(0.01, 0.035);
	_k =  random(0.035, 0.10);
	_dU = random(0.05, 0.25);
	_dV = random(0.01, 0.1);
}

//---------
// Consider simple blob detection algorithm for turning the pixel concentrations
// into a vector
// + Given Minimum area
// + Find blob
// + Draw points in center a regular intervals
// + Connect into polyline

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



