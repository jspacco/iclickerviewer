import argparse
import constructImageTable
import naiveConstructPairs


def checkAnswers( imageTable, folderName ):
  
    left_ = folderName.find("_")
    right_ = folderName.rfind("_")

    number = folderName[left_+1:right_]
    answerfile = '../answers/answers_'+number+'.txt'
    answerfile = '../answers/answers_1.txt'
    answers = open( answerfile, 'r' )
    answersDict = {}
    for line in answers:
      seperate = line.split()
      key = seperate[0]
      value = seperate[1]
      answersDict[key] = value
    
    
    answers.close()
    
    for key, value in answersDict.iteritems():
      completeKey = folderName+key 
      completeValue = folderName+value

      print(completeKey),
      print(completeValue)
      if value == 'None':
        if len(imageTable[completeKey]['strictMatch']) == 0:
          print( "NO MATCHES AND NO STRICT MATCHES==========GOOD" )
        else:
          print( "NO MATCHES SUPPOSED TO BE FOUND ========== FALSE NEGATIVE" )
          print( imageTable[completeKey]['strictMatch'] )
        continue
      contained = ( completeValue in imageTable[completeKey]['matchNamesRemove'] or \
                    completeValue in imageTable[completeKey]['matchNamesAdd'] or \
                    completeValue in imageTable[completeKey]['strictMatch'] )

      if contained:
        print('found'),
        if completeValue in imageTable[completeKey ]['strictMatch']:
          if len(imageTable[completeKey]['strictMatch']) > 1:
            print
            print("bigger than 1")
            print(imageTable[completeKey]['strictMatch'])
          print( 'in strict match')
        else:
          print
      else:
        print( "NOT FOUND =============================" )

# these matches are printed out in tiers
# tier 1: matchNamesAdd intersection matchNamesRemove
# tier 2: matchNamesAdd union matchNamesRemove
def printPotential( imageTable, key ):
  print('POTENTIAL MATCH NAMES:')
  
  displayed = imageTable[key]["strictMatch"]
  
  bestPotential = imageTable[key]["matchNamesAdd"] & imageTable[key]["matchNamesRemove"] - displayed
  print("\tTier 1:")
  for elem in bestPotential:
    print("\t"),
    print( elem )
  displayed = displayed | bestPotential
  
  nextBest = imageTable[key]["matchNamesAdd"] - displayed
  print("\tTier 2:")
  for elem in nextBest:
    print("\t"),
    print( elem )

  displayed = imageTable[key]['matchNamesAdd'] | displayed

  nextBest = imageTable[key]['matchNamesRemove'] - displayed
  for elem in nextBest:
    print("\t"),
    print( elem )

# argument will be a table whose key value is the picture name
# and the pair value will be a image body
# we will only print the matched names for now
def printImageTable( imageTable ):
  print(len(imageTable))
  
  for key, elem in imageTable.iteritems():
    print( "KEY: %s" % key)
    print( 'STRICT MATCH NAMES:')
    for match in elem['strictMatch']:
      print("\t"),
      print(match)
    printPotential( imageTable, key)

# THE MAIN DRIVER PROGRAM
# FLAGS parsing
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required=True,
	help="path to input images folder to be OCR'd")
ap.add_argument("-p", "--preprocess", type=str, default="None",
	help="type of preprocessing to be done (thresh/blur)")
ap.add_argument("-t", "--templateChange", type=str, default="n",
  help="does the template change in the given folder (y/n)" )
args = vars(ap.parse_args())

# populate imageTable with matches found
imageTable = None
imageTable = constructImageTable.constructImageTable( args["image"], args["preprocess"], args['templateChange'])

# print imageTable with different tiers of what matches were found
printImageTable(imageTable)
# checkAnswers( imageTable, args['image'] )
