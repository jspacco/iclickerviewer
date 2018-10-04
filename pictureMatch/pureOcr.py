import commonMethods

# populates imageTable with strict/potential matches
# using only the OCR engine
def generatePairedTableOnlyOcr( imageTable ):

  foundOneMatch = False
  singular = []
  # used imagehashing to figure out pairs
  for elemOneKey, elemOneValue in imageTable.items():
    one = elemOneValue["ocr_text"]
    for elemTwoKey, elemTwoValue in imageTable.items():
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
