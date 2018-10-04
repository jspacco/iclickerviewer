#import the necessary packages
import commonMethods

# CONSTANTS
THRESH_HASH_DISTANCE_STRICT = 0.05
THRESH_OCR_DISTANCE_STRICT = 0.03

THRESH_HASH_DISTANCE_STRICT_IMAGE_DOMINANT = 0.01
THRESH_HASH_DISTANCE_REMOVE_IMAGE_DOMINANT = 0.35
THRESH_OCR_DISTANCE_REMOVE_IMAGE_DOMINANT = 1.999

THRESH_HASH_DISTANCE_REMOVE = 0.1
THRESH_OCR_DISTANCE_REMOVE = 0.16

THRESH_HASH_DISTANCE_GRAPH = 0.009

# compares elements from addlist to each other and
# checks if the distance from the key of the two elements is almost the
# same
# if true then it adds those elements to the matchNamesAdd set of each other
def experimentGraph( imageTable, key, addList ):

  for one in addList:
    for two in addList:
      if one == two:
        continue
      if abs( one[1] - two[1] ) <= THRESH_HASH_DISTANCE_GRAPH:
        imageTable[one[0]]['matchNamesAdd'].add(two[0])
        imageTable[two[0]]['matchNamesAdd'].add(one[0])

# the main code that looks at each of the elements and add/removes the
# respective pairs
def findImagePairs( imageTable ):

  addList = [] # ( name, ocr_difference, hash_difference )
  removeList = []
  for key, value in imageTable.items():
    # HERE
    # print("KEY :"),
    # print(key)
    for matchKey in value["matchNamesRemove"]:

      diffOCRdistance = commonMethods.percentageEditDistance( imageTable[key]["ocr_text"],\
                                                              imageTable[matchKey]["ocr_text"] )
      diffHashDistance = commonMethods.percentHashDifference( imageTable[key]["hash_value"],\
                                                              imageTable[matchKey]["hash_value"] )
      # print(matchKey, " " , diffOCRdistance, diffHashDistance)

      # a picture is a strict match if the ocr is within 3 percent and
      # image structure is within a 5 percent difference
      if diffHashDistance <= THRESH_HASH_DISTANCE_STRICT and diffOCRdistance <= THRESH_OCR_DISTANCE_STRICT:
        imageTable[key]['strictMatch'].add(matchKey)

      # if image is imageDominant
      elif imageTable[key]["imageDominant"] or imageTable[matchKey]["imageDominant"]:
        if diffHashDistance < THRESH_HASH_DISTANCE_STRICT_IMAGE_DOMINANT:
          imageTable[key]['strictMatch'].add(matchKey)
        elif diffHashDistance > THRESH_HASH_DISTANCE_REMOVE_IMAGE_DOMINANT or diffOCRdistance > THRESH_OCR_DISTANCE_REMOVE_IMAGE_DOMINANT:
          removeList.append(matchKey)

      # if the picture is both not similar in image structure and writing
      elif diffHashDistance > THRESH_HASH_DISTANCE_REMOVE and diffOCRdistance > THRESH_OCR_DISTANCE_REMOVE:
        removeList.append(matchKey)

      # if not a strict match or needing to be removed checked it against
      # other elements that also do not need to be removed
      # CAN BE DONE WITH removed elements also but for the time being
      # have not checked the feasibility with all elements
      else:
        addList.append( ( matchKey, diffOCRdistance, diffHashDistance  ) )

    # populate the matchNamesAdd
    experimentGraph( imageTable, key, addList )
    # prune the matchNamesRemove
    commonMethods.removeItemsFromSet( imageTable, key, removeList )

    removeList = []
    addList = []

  return imageTable

# will generate a imageTable that has the matchNameRemove elements
# of each image to have all the elements in the set
# WILL be a lot more efficient if a full set of the whole dataset is
# passed in as a parameter
def generatePairedTableRegular( imageTable ):
  foundOneMatch = False
  singular = []

  for elemOneKey, elemOneValue in imageTable.items():
    one = elemOneValue["hash_value"]
    for elemTwoKey, elemTwoValue in imageTable.items():
      two = elemTwoValue["hash_value"]
      if elemOneKey != elemTwoKey:
        imageTable[elemOneKey]["matchNamesRemove"].add(elemTwoKey)
        foundOneMatch = True

    if( not foundOneMatch ):
      singular.append(elemOneKey)
    foundOneMatch = False # reset value for next element
  #end of outer for loop

  # the singulars are taken care of
  if len(singular) != 0:
    imageTable = commonMethods.addSingulars( imageTable, singular )

  # find all the matches that exist strict/potential
  imageTable = findImagePairs( imageTable )
  return imageTable
