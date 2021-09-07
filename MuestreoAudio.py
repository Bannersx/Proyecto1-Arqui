import numpy as np
import librosa as lb
import os
import string

from fxpmath import Fxp

path = '/home/francisco/Downloads/10second.ogg' #path del audio
path = os.fspath(path)                          #retorna la representacion del path como file system
y, sr = lb.load(path, sr=44100)                 #carga el audio a 44KHz

i = 0      

hexaArray = []                                  #array vacio de hexadecimales

while i < len(y):

    x = Fxp(y[i], True, 16, 8)                  #paso de fraccion a binario
    hexa = x.hex()                              #paso de binario a hexadecimal
    hexaArray.append(hexa)                      #array de valores hexadecimales
    i=i+1

textFile = open('MuestreoHexa.txt', 'w')        #se crea el archivo .txt en la carpeta de /home
for i in hexaArray:                             #se revisa el array
    textFile.write(i.replace('0x','')+" ")      #se escriben los valores del array en el archivo de texto sin 0x
textFile.close()
