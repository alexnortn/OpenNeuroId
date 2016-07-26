// Open NeuroImaging Lab Identity
// Alex Norton 2016

import toxi.sim.grayscott.*;
import toxi.math.*;
import toxi.color.*;

import processing.pdf.*;
import java.io.File; // Make Directory

int NUM_ITERATIONS = 10;
int MAX_ITERATIONS = 5000;
int MAX_OUTPUT = 2;

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
	println(_counter);

	if (_counter >= MAX_OUTPUT) {
		exit();
	}

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
				text(str(_f), doubleInset, thirdLeading * 6);

				text("k:", inset, thirdLeading * 7);
				text(str(_k), doubleInset, thirdLeading * 7);

				text("dU:", inset, thirdLeading * 8);
				text(str(_dU), doubleInset, thirdLeading * 8);

				text("dV:", inset, thirdLeading * 9);
				text(str(_dV), doubleInset, thirdLeading * 9);
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
	saveFrame("RD-" + _id + "_" + _counter + ".tga");
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
	// Generation 1 -->
		// _f =  random(0.018, 0.025);
		// _k =  random(0.065, 0.085);
		// _dU = random(0.05, 0.2);
		// _dV = random(0.01, 0.1);

	// Test -->
		// _f =  0.0245;
		// _k =  0.0785;
		// _dU = 0.0895;
		// _dV = 0.0755;

	// Cortical Folds 1 -->
		// _f =  random(0.018, 0.025);
		// _k =  random(0.065, 0.08);
		// _dU = random(0.05, 0.1);
		// _dV = random(0.02, 0.1);

	// Cortical Folds 1 Relative -->
		// _f =  random(0.018, 0.025);
		// _k =  _f * 3;
		// _dU = random(0.05, 0.1);
		// _dV = 0.75 * _dU;

	// Cortical Folds 1 Relative -->
		_f =  0.024 + random(-0.002, 0.001);
		_k =  0.076 + random(-0.001, 0.002);
		_dU = 0.085 + random(-0.005, 0.005);
		_dV = 0.070 + random(-0.01, 0.01);		

	// Coral --> [0.23, 0.76, 0.12, 0.06]
	// Brain --> [0.2, 0.7, 0.12, 0.06]
	// Electrons --> [0.23, 0.76, 0.12, 0.06]
	// gs.setCoefficients(0.0077,0.0649,0.1,0.03); // Mitosis
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



