from PIL import Image
import pytesseract
import cv2
import os
import numpy as np
import removeWriting  #removes all the non-black pixels in the picture

# get text from image
# imagePic is the cv2.imread return value: matrix representing the picture
# fileName is the name of the file without the MCBox that was edited
# preProcess is if we need to run the preProcess statements
# 
# 
# 
def getText( preProcess, imagePic, fileName):

  # load the example image
  image = cv2.imread(fileName)#imagePic 

  # remove all the nonblack pixels in the picture
  # image = removeWriting.removeWritingAndColor(image)

  #convert image to grayscale
  gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

  # check to see if we should apply thresholding to preprocess the
  # image
  if preProcess == "thresh":
    gray = cv2.threshold(gray, 0, 255,
      cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]
   
  # make a check to see if median blurring should be done to remove
  # noise
  elif preProcess == "blur":
    gray = cv2.medianBlur(gray, 3)
   
  # write the grayscale image to disk as a temporary file so we can
  # apply OCR to it
  filename = fileName 
  cv2.imwrite(filename, gray)

  #load the image as a PIL/Pillow image, apply OCR, and then delete
  # the temporary file
  text = pytesseract.image_to_string(Image.open(filename))
  text = text.replace(" ", "")
  text = text.replace("\n","")
  text = text.replace("\t","")
  os.remove(filename)
  return text

