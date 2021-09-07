import numpy as np
import soundfile as sf

from numpy import loadtxt

lines = loadtxt("Muestreo", comments="#", delimiter=" ", unpack=False)

sf.write('AudioReconstruido.wav', lines, 44100, 'PCM_24')