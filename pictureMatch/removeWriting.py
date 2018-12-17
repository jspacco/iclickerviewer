#import the necessary packages

from PIL import Image
import cv2
import numpy as np

def removeWritingAndColor(imageToLoad):

  # load the example image and convert it to grayscale
  image = imageToLoad

  # preprocessing image to remove all grey, blue, red and green
  # image[ np.where( (np.greater_equal(image, [ 72,72,72 ]) ).all(axis = 2) )] = [255,255,255] #mess around here to find perfect match 
  image[ np.where( (np.greater_equal(image, [ 150,0,0 ]) ).all(axis = 2) )] = [255,255,255]
  image[ np.where( (np.greater_equal(image, [ 0,150,0 ]) ).all(axis = 2) )] = [255,255,255]
  image[ np.where( (np.greater_equal(image, [ 0,0,150 ]) ).all(axis = 2) )] = [255,255,255]

  return image
