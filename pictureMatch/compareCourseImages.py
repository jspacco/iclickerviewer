from __future__ import print_function
import sys
import time
import glob
import cv2
import imagehash
from PIL import Image
import tempRemoveMC
import imageToText
from commonMethods import percentHashDifference, percentageEditDistance


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# CONSTANTS
THRESH_HASH_DISTANCE_STRICT = 0.05
THRESH_OCR_DISTANCE_STRICT = 0.03

THRESH_HASH_DISTANCE_STRICT_IMAGE_DOMINANT = 0.01
THRESH_HASH_DISTANCE_REMOVE_IMAGE_DOMINANT = 0.35
THRESH_OCR_DISTANCE_REMOVE_IMAGE_DOMINANT = 1.999

THRESH_HASH_DISTANCE_REMOVE = 0.1
THRESH_OCR_DISTANCE_REMOVE = 0.16

THRESH_HASH_DISTANCE_GRAPH = 0.009

def folder_and_file(path):
    last_slash = path.rfind('/')
    first_slash = path.find('/')
    if first_slash < last_slash:
        next_last_slash = path.rfind('/', 0, last_slash)
        path = path[next_last_slash+1:]
    return path

class ImageFeatures:
    def __init__(self, filename, image_hash, text):
        self.filename = filename
        self.image_hash = image_hash
        self.text = text

    def __hash__(self):
        return hash(self.filename)

    def __str__(self):
        return '{}\t{}\t{}'.format(self.filename, str(self.image_hash), self.text)

    def is_image_dominant(self):
        return len(self.text) < 75

def construct_image_table(directoryPathName, preProcess='None', templateChange='n'):
    startTime = time.time()
    table = {}

    # check for HASHCACHE.txt file
    # if we have it, just read the file; don't bother recreating all of
    # the hash information, since it doesn't change
    if len(glob.glob(directoryPathName + '/' + 'HASHCACHE.txt')) > 0:
        eprint("Try to use cached information for {}".format(directoryPathName))
        for line in open(directoryPathName + '/' + 'HASHCACHE.txt'):
            line = line.rstrip('\n ')
            filename, hash_hex, text = line.split('\t')
            # TODO remove non-ASCII chars from text?
            table[filename] = ImageFeatures(filename, imagehash.hex_to_hash(hash_hex), text)
        return table

    # build the imagePq
    # also build a dictionary with the name of the image as the key
    for imagePath in glob.glob(directoryPathName + "/*.jpg"):
        if '_C' in imagePath:
            # skip files containing a C in them (these are the bar charts)
            continue
        image = cv2.imread(imagePath)

        # remove MC box
        image = tempRemoveMC.removeMCBox(image)

        # imageName is in the format ./../something/L123123123_Q12.jpg
        dotPosition = imagePath.rfind(".")
        slashPosition = imagePath.rfind("/")
        filename = "{}.jpg".format(imagePath[slashPosition + 1:dotPosition] + "_1")
        #eprint("filename: {}".format(filename))
        # TODO shortpath should make these changes:
        # path/to/UIC.CS108F17/L1709011030_Q1.jpg
        # should be:
        # UIC.CS108F17/L1709011030_Q1.jpg
        shortpath = folder_and_file(imagePath)
        #eprint("imagePath: {}".format(imagePath))
        cv2.imwrite(filename, image)

        # calculate the hashvalue of the pic using phash
        hashVal = imagehash.phash(Image.open(filename))

        # get text from image
        text = imageToText.getText(preProcess, image, filename)

        table[shortpath] = ImageFeatures(shortpath, hashVal, text)
    endTime = time.time()
    # end of above for loop
    # create HASHCACHE.txt file
    out = open('{}/HASHCACHE.txt'.format(directoryPathName), 'w')
    for image_features in table.values():
        out.write(str(image_features)+'\n')
    out.flush()
    out.close()
    return table


# the main code that looks at each of the elements and add/removes the
# respective pairs
def find_image_matches(table1, table2, full=False):
    print("comparing {} with {}".format(len(table1), len(table2)))
    compared = set()
    result = ''
    full_result = ''
    # TODO speed up by not recomputing
    for filename1, image1 in table1.items():
        for filename2, image2 in table2.items():
            key1 = "{}-{}".format(filename1, filename2)
            key2 = "{}-{}".format(filename2, filename1)
            if key1 in compared or key2 in compared:
                continue
            compared.add(key1)
            compared.add(key2)
            diffOCRdistance = percentageEditDistance(image1.text, image2.text)
            diffHashDistance = percentHashDifference(image1.image_hash, image2.image_hash)
            full_result += "{}\t{}\t{}\t{}\n".format(filename1, filename2, diffOCRdistance, diffHashDistance)
            if diffHashDistance <= THRESH_HASH_DISTANCE_STRICT or diffOCRdistance <= THRESH_OCR_DISTANCE_STRICT:
                # a picture is a strict match if the ocr is within 3 percent and
                # image structure is within a 5 percent difference
                # strict match
                result += "{}\t{}\t0\n".format(filename1, filename2)
            elif image1.is_image_dominant() or image2.is_image_dominant():
                # image dominant means that the text is less than 75 chars
                # not sure why Ravi picked that threshold?
                # if image is imageDominant
                if diffHashDistance < THRESH_HASH_DISTANCE_STRICT_IMAGE_DOMINANT:
                    # strict match
                    result += "{}\t{}\t0\n".format(filename1, filename2)
                elif diffHashDistance > THRESH_HASH_DISTANCE_REMOVE_IMAGE_DOMINANT \
                        or diffOCRdistance > THRESH_OCR_DISTANCE_REMOVE_IMAGE_DOMINANT:
                    # no match?
                    # removeList.append(matchKey)
                    #eprint("{} {} PASS remove image dominant".format(filename1, filename2))
                    pass
                elif diffHashDistance > THRESH_HASH_DISTANCE_REMOVE \
                        and diffOCRdistance > THRESH_OCR_DISTANCE_REMOVE:
                    # removeList.append(matchKey)
                    # no match?
                    #eprint("{} {} PASS remove".format(filename1, filename2))
                    pass
            else:
                # if not a strict match or needing to be removed checked it against
                # other elements that also do not need to be removed
                # CAN BE DONE WITH removed elements also but for the time being
                # have not checked the feasibility with all elements
                # TODO what does the addList do?
                #eprint("addList?")
                pass
                # addList.append( ( matchKey, diffOCRdistance, diffHashDistance  ) )
    if full:
        return full_result.rstrip()
    else:
        return result.rstrip()


def compare_courses(dir1, dir2, full=False):
    # None, thresh, blur (Default: None)
    preprocess = 'None'

    # y/n (default: n)
    templateChange = 'n'

    table1 = construct_image_table(dir1, preprocess, templateChange)

    table2 = construct_image_table(dir2, preprocess, templateChange)

    return find_image_matches(table1, table2, full)
