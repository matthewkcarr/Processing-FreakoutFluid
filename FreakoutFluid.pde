/***********************************************************************
 
 Demo of the MSAFluid library (www.memo.tv/msafluid_for_processing)
 Move mouse to add dye and forces to the fluid.
 Click mouse to turn off fluid rendering seeing only particles and their paths.
 Demonstrates feeding input into the fluid and reading data back (to update the particles).
 Also demonstrates using Vertex Arrays for particle rendering.
 
/***********************************************************************
 
 Copyright (c) 2008, 2009, Memo Akten, www.memo.tv
 *** The Mega Super Awesome Visuals Company ***
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of MSA Visuals nor the names of its contributors 
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 * ***********************************************************************/ 

import msafluid.*;
import beads.*;

import processing.opengl.*;
import javax.media.opengl.*;
//import processing.opengl.*;

final float FLUID_WIDTH = 120;

float invWidth, invHeight;    // inverse of screen dimensions
float aspectRatio, aspectRatio2;

MSAFluidSolver2D fluidSolver;

ParticleSystem particleSystem;

PImage imgFluid;

AudioContext ac;
PowerSpectrum ps;
color fore = color(255, 255, 255);
color back = color(0,0,0);

boolean drawFluid = true;

void setup() {
    size(960, 640, OPENGL);    // use OPENGL rendering for bilinear filtering on texture
//    size(screen.width * 49/50, screen.height * 49/50, OPENGL);
    hint( ENABLE_OPENGL_4X_SMOOTH );    // Turn on 4X antialiasing

    invWidth = 1.0f/width;
    invHeight = 1.0f/height;
    aspectRatio = width * invHeight;
    aspectRatio2 = aspectRatio * aspectRatio;

    // create fluid and set options
    fluidSolver = new MSAFluidSolver2D((int)(FLUID_WIDTH), (int)(FLUID_WIDTH * height/width));
    fluidSolver.enableRGB(true).setFadeSpeed(0.003).setDeltaT(0.5).setVisc(0.0001);

    // create image to hold fluid picture
    imgFluid = createImage(fluidSolver.getWidth(), fluidSolver.getHeight(), RGB);

    // create particle system
    particleSystem = new ParticleSystem();

    /* this is the audio portion */
    ac = new AudioContext(); // set up the parent AudioContext object
    // set up a master gain object
    Gain g = new Gain(ac, 2, 0.3);
    ac.out.addInput(g);
  
    // load up a sample included in code download
    SamplePlayer player = null;
    try
    {
      player = new SamplePlayer(ac, new Sample(sketchPath("") + "Drum_Loop_01.wav")); // load up a new SamplePlayer using an included audio file
      //player = new SamplePlayer(ac,  new Sample(sketchPath("") + "dubstep.wav"));
      g.addInput(player); // connect the SamplePlayer to the master Gain
    }
    catch(Exception e)
    {
      e.printStackTrace(); // if there is an error, print the steps that got us to that error
    }
    // in this block of code, we build an analysis chain
    // the ShortFrameSegmenter breaks the audio into short, descrete chunks
    ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
    sfs.addInput(ac.out);
  
    // FFT stands for Fast Fourier Transform
    // all you really need to know about the FFT is that it lets you see what frequencies are present in a sound
    // the waveform we usually look at when we see a sound displayed graphically is time domain sound data
    // the FFT transforms that into frequency domain data
    FFT fft = new FFT();
    sfs.addListener(fft); // connect the FFT object to the ShortFrameSegmenter
  
    ps = new PowerSpectrum(); // the PowerSpectrum pulls the Amplitude information from the FFT calculation (essentially)
    fft.addListener(ps); // connect the PowerSpectrum to the FFT

    ac.out.addDependent(sfs); // list the frame segmenter as a dependent, so that the AudioContext knows when to update it
    ac.start(); // start processing audio
    /* this is the audio portion */
    
    // init TUIO
    initTUIO();
}


void mouseMoved() {
    float mouseNormX = mouseX * invWidth;
    float mouseNormY = mouseY * invHeight;
    float mouseVelX = (mouseX - pmouseX) * invWidth;
    float mouseVelY = (mouseY - pmouseY) * invHeight;
    

    //println("mouse x: " + mouseX);
    //println("mouse y: " + mouseY);
    //addForce(mouseNormX, mouseNormY, mouseVelX, mouseVelY);
    //addForce(0.5, 0, 0, 0.01);
    /*
    for(int i = 0; i < width; i+=50) {
      float mx = i * invWidth;
      float my = 0;
      float vx =  0;
      float vy = 0.01;
    
      addForce(mx, my, vx, vy);
      
      /*println("x:" + mx);
      println("y:" + my);
      println("vx:" + vx);
      println("vy:" + vy); 
    }
   */
}

void draw() {
    updateTUIO();
    fluidSolver.update();

    /* this is the audio portion */
    float[] features = ps.getFeatures(); // get the data from the PowerSpectrum object
  
    // if any features are returned
     
    if(features != null)
    { /*
      stroke(fore);
      background(back);
      // for each x coordinate in the Processing window
      for(int x = 0; x < width; x++)
      {
        // draw a vertical line corresponding to the frequency represented by this x-position
        int featureIndex = (x * features.length) / width; // figure out which featureIndex corresponds to this x-position
        int barHeight = Math.min((int)(features[featureIndex] * height), height - 1); // calculate the bar height for this feature
        //line(x, height, x, height - barHeight); // draw on screen
        addForce(x * invWidth, height * invHeight, x * invWidth,  (height - barHeight) * invHeight);
       } */
       
      for(int i = 0; i < width; i+=50) {
        int featureIndex = (i * features.length) / width;  // figure out which featureIndex corresponds to this x-position
        int barHeight = Math.min((int)(features[featureIndex] * height), height - 1);  //calculate the bar height for this feature
        float mx = i * invWidth;
        float my = 0;
        float vx =  0;
        float vy = (barHeight * invHeight) / 5;  //0.01;
   
        //
        if( barHeight != 0 ) {
           //println("bar height:" + barHeight);
           addForce(mx, my, vx, vy);
        }
         
        /*
        println("y:" + my);
        println("vx:" + vx);
        println("vy:" + vy); 
        */
      }
    }
     
    /* this is the audio portion */

    if(drawFluid) {
        for(int i=0; i<fluidSolver.getNumCells(); i++) {
            int d = 2;
            imgFluid.pixels[i] = color(fluidSolver.r[i] * d, fluidSolver.g[i] * d, fluidSolver.b[i] * d);
        }  
        imgFluid.updatePixels();//  fastblur(imgFluid, 2);
        image(imgFluid, 0, 0, width, height);
    } 
    
    particleSystem.updateAndDraw();  
}

void mousePressed() {
    drawFluid ^= true;
}

void keyPressed() {
    switch(key) {
    case 'r': 
        renderUsingVA ^= true; 
        println("renderUsingVA: " + renderUsingVA);
        break;
    }
    println(frameRate);
}



// add force and dye to fluid, and create particles
void addForce(float x, float y, float dx, float dy) {
    float speed = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio

    if(speed > 0) {
        if(x<0) x = 0; 
        else if(x>1) x = 1;
        if(y<0) y = 0; 
        else if(y>1) y = 1;

        float colorMult = 5;
        float velocityMult = 30.0f;

        int index = fluidSolver.getIndexForNormalizedPosition(x, y);

        color drawColor;

        colorMode(HSB, 360, 1, 1);
        float hue = ((x + y) * 180 + frameCount) % 360;
        drawColor = color(hue, 1, 1);
        colorMode(RGB, 1);  

        fluidSolver.rOld[index]  += red(drawColor) * colorMult;
        fluidSolver.gOld[index]  += green(drawColor) * colorMult;
        fluidSolver.bOld[index]  += blue(drawColor) * colorMult;

        particleSystem.addParticles(x * width, y * height, 10);
        fluidSolver.uOld[index] += dx * velocityMult;
        fluidSolver.vOld[index] += dy * velocityMult;
    }
}

