#import the necessary packages
from PIL import Image
import pytesseract
import cv2
import os
import numpy as np
import removeMC #removes the multiple choice box in the picture
import removeWriting  #removes all the non-black pixels in the picture

# returns the number of changes required to make string 2 into string 1
def editDistDP( str1, str2):
  m = len(str1)
  n = len(str2)
  # Create a table to strore rsults of subproblems
  dp = [[0 for x in range(n+1)] for x in range(m+1)]

  # Fill d[][] in bottom up manner
  for i in range(m+1):
    for j in range(n+1):
      
      if i == 0:
        dp[i][j] = j

      elif j == 0:
        dp[i][j] = i

      elif str1[i - 1] == str2[j-1]:
        dp[i][j] = dp[i-1][j-1]

      else:
        dp[i][j] = 1 + min( dp[i][j-1], dp[i-1][j], dp[i-1][j-1])

  return dp[m][n]


### driver of the files
#image = cv2.imread( "Q14.jpg") #cv2.imread(imagePathName)
#imageTwo = cv2.imread("Q15.jpg")
## calling another function
# will remove the multiple choice box and return the image
#image = removeMC.removeMCBox(image)

# remove all the nonblack pixels in the picture
# image = removeWriting.removeWritingAndColor(image)

#convert image to grayscale
#gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
#grayTwo= cv2.cvtColor(imageTwo, cv2.COLOR_BGR2GRAY)
#if True:
#  gray = cv2.threshold(gray, 0, 255,
#    cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]
# 
## write the grayscale image to disk as a temporary file so we can
## apply OCR to it
#filename = "A14.png" #"{}.png".format(os.getpid())
#cv2.imwrite(filename, gray)
#
##load the image as a PIL/Pillow image, apply OCR, and then delete
## the temporary file
#text = pytesseract.image_to_string(Image.open(filename))
#text = text.replace(" ", "")
#text = text.replace("\n","")
#text = text.replace("\t","")
#os.remove(filename)
#print(text)
#
#filename = "A15.png" #"{}.png".format(os.getpid())
#cv2.imwrite(filename, grayTwo)
#
##load the image as a PIL/Pillow image, apply OCR, and then delete
## the temporary file
#text2 = pytesseract.image_to_string(Image.open(filename))
#text2 = text.replace(" ", "")
#text2 = text.replace("\n","")
##text2 = text.replace("\t","")
#print(text2)
#num = editDistDP( text, text2 )
#print( num )
#print( float(num)/len(textOne) )
#imageOne = cv2.imread('./test_50_pictures/L1804050925_Q12.jpg')
#imageOne = removeMC.removeMCBox( imageOne )
#grayOne = cv2.cvtColor(imageOne, cv2.COLOR_BGR2GRAY)
#grayOne = cv2.threshold(grayOne, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]
#
#imageTwo = cv2.imread('./test_50_pictures/L1804050925_Q11.jpg')
#imageTwo = removeMC.removeMCBox( imageTwo )
#grayTwo = cv2.cvtColor(imageTwo, cv2.COLOR_BGR2GRAY)
#grayTwo = cv2.threshold(grayTwo, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]
#
#
#fileOne = "fileOne.jpg"
#cv2.imwrite( fileOne, grayOne)
##
#fileTwo = "fileTwo.jpg"
#cv2.imwrite( fileTwo, grayTwo )
##
#textOne = pytesseract.image_to_string( Image.open(fileOne))
#os.remove(fileOne)
#
#textTwo = pytesseract.image_to_string( Image.open(fileTwo))
#os.remove(fileTwo)
#
#print( type(textOne) )
#
#textOne.replace( " ", "" )
#textTwo.replace( " ", "" )
#print(textOne)
#print(textTwo)
#
#print( len(textOne) )
#print( len(textTwo) )
#num = editDistDP( textOne, textTwo )
#print( num )
#print( float(num)/len(textOne) )
