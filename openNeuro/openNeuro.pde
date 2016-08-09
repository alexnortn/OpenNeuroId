// Open NeuroImaging Lab Identity
// Alex Norton 2016

import toxi.sim.grayscott.*;
import toxi.math.*;
import toxi.color.*;

import processing.pdf.*;
import java.io.File; // Make Directory

int NUM_ITERATIONS = 10;
int MAX_ITERATIONS = 10000;
int MAX_OUTPUT = 50;

int _iteration;
int _counter = 0;
String _id;

GrayScott gs;
ToneMap toneMap;

PImage seed;
PImage convolution;
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
	seed = loadImage("test.png");
	seed.loadPixels();

	convolution = createImage(seed.width, seed.height, RGB);

	// Typography
	metaFont = createFont("PostGrotesk-Medium.otf", 12);
	textFont(metaFont);

	gs = new PatternedGrayScott(width,height,false);

	updateCoefficients();
	
	// f | k | dU | dV

	// f  --> reactant f birth/introduction rate
	// k  --> reactant k birth/introduction rate
	// dU --> reactant f diffusion rate
	// dV --> reactant k diffusion rate

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
	// if (mousePressed) {
	// 	gs.setRect(mouseX, mouseY,20,20);
	// }

	// image(seed, 0, 0);

	// // runGrayScott(NUM_ITERATIONS);
	// // _iteration += NUM_ITERATIONS;


	// loadPixels();

	// // Edge Detection
	// for (int x = 1; x < width-1; x++) { // Start in from edges
	// 	for (int y = 1; y < height-1; y++) { // Start in from edges
	// 		int index = x + width * y;
	// 		pixels[index] = edgeDetector(x, y);
	// 	}
	// } 

	// updatePixels();

	thresholdDetector();

	noLoop(); 

	// drawText();

	// if (_iteration >= MAX_ITERATIONS) {
	// 	outputSim();
	// 	setup();
	// }

	// println(frameCount);

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
		gs.update(1);
	}
	// read out the V result array
	// and use tone map to render colours
	for (int i = 0; i < gs.v.length; i++) {
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
	setup();
}
 
// Iterate through many many values of each
void updateCoefficients() {

	// Cortex 1 -->
	_f =  0.022;
	_k =  0.074;
	_dU = 0.229;
	_dV = 0.1;

	// Left / Right Brain -->
	// _f =  0.021886185 + random(-0.01, 0.01);
	// _k =  0.073436916 + random(-0.01, 0.01);
	// _dU = 0.20551047 + random(-0.01, 0.01);
	// _dV = 0.09671787 + random(-0.01, 0.01);	

	// Coral --> [0.23, 0.76, 0.12, 0.06]
	// Brain --> [0.2, 0.7, 0.12, 0.06]
	// Electrons --> [0.23, 0.76, 0.12, 0.06]
	// gs.setCoefficients(0.0077,0.0649,0.1,0.03); // Mitosis
}

void thresholdDetector() {
	seed.loadPixels();
	convolution.loadPixels();
	int threshold = 150;

	for (int x = 0; x < seed.width; x++) {
		for (int y = 0; y < seed.height; y++ ) {
			int loc = x + y * seed.width;
			// Test the brightness against the threshold
			if (brightness(seed.pixels[loc]) > threshold) {
				convolution.pixels[loc]  = color(255);  // White
			} 
			else {
				convolution.pixels[loc]  = color(0);    // Black
			}
		}
	}

	// We changed the pixels in convolution
	convolution.updatePixels();
	// Display the convolution
	image(convolution,0,0);
}

// Centerline extraction

// Based on Sobel Operator --> Swap out for Canny Convolution
// https://en.wikipedia.org/wiki/Sobel_operator

color edgeDetector(int x, int y) {
	int matrixsize = 3;
	int offset = matrixsize / 2;

  	// Detect horizontal lines
	float[][] kernelx = { { -1, 0, 1 },
	                      { -2, 0, 2 },
	                      { -1, 0, 1 }}; 

  	// Detect vertical lines
	float[][] kernely = {{ -1, -2, -1 },
	                      { 0,  0,  0 },
	                      { 1,  2,  1 }}; 

  	// Calculate magnitude for X
  	float magX = 0.0;

  	for (int a = 0; a < matrixsize; a++) {
  		for (int b = 0; b < matrixsize; b++) {
  			int xn = x + a - offset;
  			int yn = y + b - offset; 

  			int index = xn + yn * width;

  			magX += greyValue(pixels[index]) * kernelx[a][b];
  		}
  	}

  	// Calculate magnitude for Y
  	float magY = 0.0;

  	for (int a = 0; a < matrixsize; a++) {
  		for (int b = 0; b < matrixsize; b++) {
  			int xn = x + a - offset;
  			int yn = y + b - offset;

  			int index = xn + yn * width;

  			magY += greyValue(pixels[index]) * kernely[a][b];
  		}
  	}

  	return color( sqrt(magX*magX + magY*magY) ); // pixel output
}

int greyValue(color c) {
	
	int r = (c&0x00FF0000) >> 16; // red part
	int g = (c&0x0000FF00) >> 8;  // green part
	int b = (c&0x000000FF); 	  // blue part
	
	int grey = (r+b+g)/3;		  // grey part

	return grey;
}

class PatternedGrayScott extends GrayScott {
	public PatternedGrayScott(int w, int h, boolean tiling) {
		super(w,h,tiling);
	}

	public float getFCoeffAt(int x, int y) { // F
		int index = x + width * y;
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



