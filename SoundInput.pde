import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;



class SoundInput
{
  // Object minim qui représente l'interface
  // avec la carte audio
  Minim minim;

  // Object qui capte l'entrée miro
  AudioInput entreeMicro;

  // Niveau micro
  float niveauMicro,niveauMicroSmooth;
  float niveauMicroSmoothLevel = 0.2;

  // Analyse spectracle
  FFT fft;
  boolean useFFT = false;
  boolean useAvg = false;

  // ----------------------------------------------------
  SoundInput(PApplet p)
  {
    this.setup(p);
  }

  // ----------------------------------------------------
  SoundInput(PApplet p, int nbBands)
  {
    this.useFFT = true;
    this.setup(p);
    this.fft.linAverages(nbBands);
    this.useAvg = true;
  }

  // ----------------------------------------------------
  void setup(PApplet p)
  {
    // Initialise la libraire Minim
    minim = new Minim(p);
    entreeMicro = minim.getLineIn(Minim.STEREO, 512);
    if (useFFT)
      fft = new FFT(entreeMicro.bufferSize(), entreeMicro.sampleRate());
    // p.registerMethod("update", this);
  }

  // ----------------------------------------------------
  void update()
  {
    niveauMicro = entreeMicro.mix.level();
    niveauMicroSmooth += (niveauMicro-niveauMicroSmooth)*niveauMicroSmoothLevel;
    if (useFFT)
      fft.forward(entreeMicro.mix.toArray());
  }

  // ----------------------------------------------------
  void setLevelSmooth(float level_)
  {
    niveauMicroSmoothLevel = level_;
  }

  // ----------------------------------------------------
  float getLevel()
  {
    return niveauMicro;
  }

  // ----------------------------------------------------
  float getLevelSmooth()
  {
   return niveauMicroSmooth; 
  }
  
  // ----------------------------------------------------
  float getFFTLevel(int i)
  {
    if (!useFFT) return 0.0f;

    
    if (i < getFFTSize())
    {
      return fft.getBand(i);
    }
    else
    {
      println("L'index de bande FFT ["+i+"] n'est pas valide");
      return 0.0f;
    }
  }

  // ----------------------------------------------------
  void drawFFT(float s)
  {
    if (!useFFT) return;
    
    rectMode(CORNER);
    float bandWidth = float(width)/float(getFFTSize());
    float x=0;
    for (int i = 0; i < getFFTSize(); i++)
    {
      // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
      if (useAvg)
      {
        noStroke();
        fill(0);
        rect(x,height,bandWidth,height-fft.getBand(i)*s);
        x+=bandWidth;
      }
      else
      {
        x = i;
        stroke(0);
        line(x, height, x, height - fft.getBand(i)*s);
      }
    }
  }

  // ----------------------------------------------------
  int getFFTSize()
  {
    if (!useFFT) return 0;
    return (useAvg ? fft.avgSize() : fft.specSize());
  }
}

