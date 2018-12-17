import commonMethods

# populates imageTable with strict/potential matches
# using only the OCR engine
def generatePairedTableOnlyOcr( imageTable ):
  foundOneMatch = False
  singular = []
  # used imagehashing to figure out pairs
  for elemOneKey, elemOneValue in imageTable.items():
    one = elemOneValue["ocr_text"]
    for elemTwoKey, elemTwoValue in imageTable2.items():
      two = elemTwoValue["ocr_text"]
      if elemOneKey != elemTwoKey:
        ocrDiff = commonMethods.percentageEditDistance(one, two)
        if ocrDiff <= 0.3:
            imageTable[elemOneKey]["strictMatch"].add(elemTwoKey)
            foundOneMatch = True
        elif ocrDiff < 0.26:
            imageTable[elemOneKey]["matchNamesRemove"].add(elemTwoKey)
            foundOneMatch = True

    if( not foundOneMatch ):
      singular.append(elemOneKey)
    foundOneMatch = False # reset value for next element
  #end of outer for loop

  # the singulars are taken care of
  imageTable = commonMethods.addSingulars( imageTable, singular )
  return imageTable

def generatePairedTableOnlyOcr2( imageTable, imageTable2 ):
  # What format do I want results?
  # Image1  Image2  confidence (0/1/2)
  # UIC.CS108F17/L1709171030_Q5.jpg UIC.CS108F18/L1709101035_Q4.jpg

  result = ''

  # used imagehashing to figure out pairs
  for elemOneKey, elemOneValue in imageTable.items():
    one = elemOneValue["ocr_text"]
    for elemTwoKey, elemTwoValue in imageTable2.items():
      two = elemTwoValue["ocr_text"]
      if elemOneKey != elemTwoKey:
        ocrDiff = commonMethods.percentageEditDistance(one, two)
        if ocrDiff <= 0.3:
            # 1 means probable match
            result += "{}\t{}\t1\n".format(elemOneKey, elemTwoKey)
        elif ocrDiff < 0.26:
            # 0 means (almost) positive match
            result += "{}\t{}\t0\n".format(elemOneKey, elemTwoKey)

  # the singulars are taken care of
  return result
