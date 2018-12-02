from compareCourseImages import compare_courses, construct_image_table

def process_classes(classes, outdir, full=False):
    # image_comparator = ImageComparator()
    done = set()
    for dir1 in classes:
        for dir2 in classes:
            if dir1 == dir2:
                # don't compare directories to themselves
                continue
            if '{}-{}'.format(dir1, dir2) in done:
                # if we compare dir1 to dir2,
                # then we don't need to compare dir2 to dir1
                continue
            # send in the hash
            print('comparing {} to {}'.format(dir1, dir2))
            result = compare_courses(dir1, dir2, full)
            if full:
                out = open('{}/{}-{}-FULL.txt'.format(outdir, dir1, dir2), 'w')
            else:
                out = open('{}/{}-{}.txt'.format(outdir, dir1, dir2), 'w')
            out.write(result + "\n")
            out.flush()
            out.close()
            # if we compare dir1 to dir2,
            # then we don't need to compare dir2 to dir1
            done.add('{}-{}'.format(dir1, dir2))
            done.add('{}-{}'.format(dir2, dir1))
            print('Finished with {} and {}'.format(dir1, dir2))

def main():
    outdir = 'output'

    tests = ['test1', 'test2']

    cs141s = ['KnoxCS141W15', 'KnoxCS141F15-1', 'KnoxCS141F15-2', 'KnoxCS141W16',
        'KnoxCS141F16-1', 'KnoxCS141F16-2', 'KnoxCS141W17-2']

    cse141s = ['KnoxCS201S15', 'KnoxCS201S16',
        'UCSD.CSE141F15', 'UCSD.CSE141F14-A', 'UCSD.CSE141F14-B',
        'UCSD.CSE141F16', 'UCSD.CSE141S17-1', 'UCSD.CSE141S17-2']

    all = ['KnoxCS141F15-1',
        'KnoxCS141F15-2',
        'KnoxCS141F16-1',
        'KnoxCS141F16-2',
        'KnoxCS141W15',
        'KnoxCS141W16',
        'KnoxCS141W17-2',
        'KnoxCS201S15',
        'KnoxCS201S16',
        'UCSD.CSE141F14-A',
        'UCSD.CSE141F14-B',
        'UCSD.CSE141F15',
        'UCSD.CSE141F16',
        'UCSD.CSE141S17-1',
        'UCSD.CSE141S17-2']

    debug = ['KnoxCS201S15', 'UCSD.CSE141F16']
    outdir = 'tmp'

    full = True

    process_classes(cs141s, outdir, full)
    process_classes(cse141s, outdir, full)

    #for d in all:
    #    construct_image_table(d)

if __name__ == '__main__':
    main()
