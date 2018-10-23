#import the necessary packages
from PIL import Image
import cv2
import os
import numpy as np
import tempRemoveMC #removes the multiple choice box in the picture
import glob
import time
import imagehash
import imageToText
import findMatchesRegular
import pureOcr

# returns true if an imageName contains a C
# a C indicates that the questions should be skipped
# imageName is a string in the format L123123123_C12.jpg
def containsC( imageName ):

  underScoreIndex = imageName.rfind("_")
  slicedName = imageName[ underScoreIndex : ]
  cIndex = slicedName.rfind("C")

  return cIndex != -1



# will construct the imageTable with empty matchNamesRemoves
# will return the values of the populated imageTable
# OUTLAY OF THE METHOD
# will go through all the pictures in a given directory
# will calculate hash value for each picture and get text of each of pics
#
# will create a dictionary with {picName, imageBody}
#
# once the table is called it will determine whether to use the method
# with both imageHashing and ocr or use pureOCR
#
# a call to these methods will return a populated imageTable which will
# be returned
#
def constructImageTable( directoryPathName, preProcess, templateChange ):
  startTime = time.time()

  hashVal = 0 # hash value of a picture that is calculated
  imageObj = None # tuple of ( imageName/path, imageBody)
  imageBody = None # will be the body of what should be in an image

  imageTable = {} #image table will hold image objects in the format of
                  # imageName: imageObject
  # build the imagePq
  # also build a dictionary with the name of the image as the key
  for imagePath in glob.glob( directoryPathName +"/*.jpg"):

    if containsC( imagePath ):
        # skip files containing a C in them (these are the bar charts)
        continue
    image = cv2.imread( imagePath )

    #remove MC box
    image = tempRemoveMC.removeMCBox(image)

    # imageName is in the format ./../something/L123123123_Q12.jpg
    dotPosition = imagePath.rfind(".")
    slashPosition = imagePath.rfind("/")
    filename ="{}.jpg".format(imagePath[slashPosition+1:dotPosition] +"_1")
    print("filename: {}".format(filename))
    fullpath = imagePath
    # TODO split imagePath up more:
    # path/to/UIC.CS108F17/L1709011030_Q1.jpg
    # should be:
    # UIC.CS108F17/L1709011030_Q1.jpg
    print("imagePath: {}".format(imagePath))
    cv2.imwrite(filename, image)

    # calculate the hashvalue of the pic using phash
    hashVal = imagehash.phash( Image.open(filename) )

    # get text from image
    text = imageToText.getText( preProcess, image, filename)
    imageBody = { 'matchNamesRemove': set(), \
                  'matchNamesAdd': set(), \
                  'strictMatch': set(), \
                  'hash_value': hashVal, \
                  'ocr_text': text, \
                  'imageDominant': ( len(text) <= 75 ),
                  'filename': imagePath
                }
    imageObj = ( imagePath, imageBody )

    # save the element to the table, text and hash value
    imageTable[imagePath] = imageBody

  # end of above for loop

  if templateChange == 'y':
    imageTable = pureOcr.generatePairedTableOnlyOcr( imageTable )
  else:
    imageTable = findMatchesRegular.generatePairedTableRegular( imageTable )

  endTime = time.time()
  # how much time it took to run the entiriety of the code
  # print( "total time = " ),
  # print("--- %s seconds ---" % (endTime - startTime))

  return imageTable
