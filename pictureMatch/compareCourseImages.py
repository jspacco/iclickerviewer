from __future__ import print_function
import sys
import os
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

TEXT_THRESHOLD = 0.13
PHASH_THRESHOLD = 0.13


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
    '''Check pathname. If it's a file, assume it's a HASHCACHE file.
If it's a directory, check for a HASHCACHE.txt file.
If it's a directory with no HASHCACHE file, find the images and build the HASHCACHE.txt file.
    '''
    startTime = time.time()
    table = {}

    # check for HASHCACHE.txt file
    # if we have it, just read the file; don't bother recreating all of
    # the hash information, since it doesn't change
    if os.path.isfile(directoryPathName + '/HASHCACHE.txt') > 0 or os.path.isfile(directoryPathName):
        eprint("Try to use cached information for {}".format(directoryPathName))
        if os.path.isfile(directoryPathName):
            file = open(directoryPathName)
        else:
            file = open(directoryPathName + '/HASHCACHE.txt')
        for line in file:
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


def img(classname, filename):
    return 'https://s3.amazonaws.com/iclickerviewer/{}/Images/{}'.format(classname, filename)


def name_only(filename):
    if '/' in filename:
        return filename[filename.index('/')+1:]
    return filename


def tohtml(msg, diff_text, diff_phash, class1, filename1, class2, filename2):
    filename1 = name_only(filename1)
    filename2 = name_only(filename2)
    return '''
<tr>
<td>{}</td>
<td>text: {:.2f}</td>
<td>phash: {:.2f}</td>
<td><img src="{}" width=400/></td>
<td><img src="{}" width=400/></td>
</tr>
'''.format(msg, float(diff_text), float(diff_phash),
            img(class1, filename1), img(class2, filename2))


def find_image_matches(class1, table1, class2, table2, htmlout=False):
    '''Match the images in class1 against the images from class2
    '''
    print("comparing {} with {}".format(len(table1), len(table2)))
    done = set()
    result = ''
    html = ''
    both = 0
    neither = 0
    phash = 0
    text = 0
    for filename1, image1 in table1.items():
        for filename2, image2 in table2.items():
            key = "{}-{}".format(filename1, filename2)
            if key in done:
                continue
            done.add(key)
            # also add the opposite of the key, so f1-f2 and f2-f1
            done.add("{}-{}".format(filename2, filename1))
            diff_text = percentageEditDistance(image1.text, image2.text)
            diff_phash = percentHashDifference(image1.image_hash, image2.image_hash)
            msg = '{:.2} {:.2} for {} and {}'.format(float(diff_text), float(diff_phash), filename1, filename2)
            if diff_text < TEXT_THRESHOLD and diff_phash < PHASH_THRESHOLD:
                #print("both: {}".format(msg))
                both += 1
                html += tohtml('both!', diff_text, diff_phash, class1, filename1, class2, filename2)
            elif diff_phash < PHASH_THRESHOLD:
                #print("phash: {}".format(msg))
                phash += 1
                html += tohtml('phash only', diff_text, diff_phash, class1, filename1, class2, filename2)
            elif diff_text < TEXT_THRESHOLD:
                #print("text: {}".format(msg))
                text += 1
                html += tohtml('text only', diff_text, diff_phash, class1, filename1, class2, filename2)
            else:
                # print("neither: {}".format(msg))
                neither += 1
            result += "{}\t{}\t{:.2}\t{:.2}\n".format(filename1, filename2, float(diff_text), float(diff_phash))
    print("both: {} phash: {} text: {} neither: {}".format(both, phash, text, neither))
    if htmlout:
        return '''
<html>
<head><title></title></head>
<body>
<table>
<tr>
    <th>message</th>
    <th>diff text</th>
    <th>diff phash</th>
    <th>file1</th>
    <th>file2</th>
</tr>
{}
</table>
</body>
</html>
'''.format(html)
    else:
        return result


# the main code that looks at each of the elements and add/removes the
# respective pairs
def find_image_matches2(table1, table2, full=False):
    print("comparing {} with {}".format(len(table1), len(table2)))
    done = set()
    result = ''
    full_result = ''
    for filename1, image1 in table1.items():
        for filename2, image2 in table2.items():
            key1 = "{}-{}".format(filename1, filename2)
            key2 = "{}-{}".format(filename2, filename1)
            if key1 in done or key2 in done:
                continue
            done.add(key1)
            done.add(key2)
            diffOCRdistance = percentageEditDistance(image1.text, image2.text)
            diffHashDistance = percentHashDifference(image1.image_hash, image2.image_hash)
            full_result += "{}\t{}\t{:.2}\t{:.2}\n".format(filename1, filename2, float(diffOCRdistance), float(diffHashDistance))
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


def compare_courses(class1, dir1, class2, dir2, full=False):
    # None, thresh, blur (Default: None)
    preprocess = 'None'

    # y/n (default: n)
    templateChange = 'n'

    table1 = construct_image_table(dir1, preprocess, templateChange)

    table2 = construct_image_table(dir2, preprocess, templateChange)

    return find_image_matches(class1, table1, class2, table2, full)


def process_classes(classes, outdir, htmlout=False):
    '''Compare a list of courses, pair by pair.
classes: list of courses
outdir: name of folder where the output file should be generated
full: True/False, should we generate "full" results, meaning we include
all of the pairwise comparisons between the files in the output, or
should we only list things that we are pretty sure match, according to
some standard.
    '''
    done = set()
    for class1, dir1 in classes.items():
        for class2, dir2 in classes.items():
            if class1 == class2:
                # don't compare directories to themselves
                continue
            if class1 + class2 in done:
                # if we compare dir1 to dir2,
                # then we don't need to compare dir2 to dir1
                continue
            # send in the hash
            print('comparing {} to {}'.format(class1, class2))
            done.add(class1 + class2)
            done.add(class2 + class1)
            result = compare_courses(class1, dir1, class2, dir2, htmlout)
            filename = '{}/{}-{}.txt'.format(outdir, class2, class2)
            if htmlout:
                filename = '{}/{}-{}.html'.format(outdir, class1, class2)
            out = open(filename, 'w')
            out.write(result + "\n")
            out.flush()
            out.close()
            # if we compare dir1 to dir2,
            # then we don't need to compare dir2 to dir1
            done.add('{}-{}'.format(dir1, dir2))
            done.add('{}-{}'.format(dir2, dir1))
            print('Finished with {} and {}'.format(dir1, dir2))
