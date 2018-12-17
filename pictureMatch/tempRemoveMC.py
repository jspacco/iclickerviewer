#import the necessary packages
from PIL import Image
import cv2
import numpy as np
import imutils

# removes the multiple choice box from images
def removeMCBox(pictureToEdit):

  # make sure that the image is in the same directory
  template = cv2.imread( "./mcBox/grayMC.jpg",0) 
  w, h = template.shape[::-1]

  # load the example image and convert it to grayscale
  img = pictureToEdit
  imageTwo = img.copy()

  #convert into gray code
  gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

  # Apply template Matching
  res = cv2.matchTemplate(gray,template,eval('cv2.TM_CCOEFF_NORMED') )
  min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(res)
  top_left = max_loc
  bottom_right = (top_left[0] + w, top_left[1] + h)

  cv2.rectangle(img,top_left, bottom_right, (255,255,255) , -1)
  return img
