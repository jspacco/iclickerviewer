from compareCourseImages import compare_courses

def main():
    outdir = 'output'

    cs141s = ['KnoxCS141W15', 'KnoxCS141F15-1', 'KnoxCS141F15-2', 'KnoxCS141W16',
        'KnoxCS141F16-1', 'KnoxCS141F16-2', 'KnoxCS141W17-2']
    # cs141s = ['test1', 'test2']

    # image_comparator = ImageComparator()
    done = set()
    for dir1 in cs141s:
        for dir2 in cs141s:
            if dir1 == dir2:
                # don't compare directories to themselves
                continue
            if '{}-{}'.format(dir1, dir2) in done:
                # if we compare dir1 to dir2,
                # then we don't need to compare dir2 to dir1
                continue
            # send in the hash
            result = compare_courses(dir1, dir2)
            out = open('{}/{}-{}.txt'.format(outdir, dir1, dir2), 'w')
            out.write(result + "\n")
            # if we compare dir1 to dir2,
            # then we don't need to compare dir2 to dir1
            done.add('{}-{}'.format(dir1, dir2))
            done.add('{}-{}'.format(dir2, dir1))
            print('Finished with {} and {}'.format(dir1, dir2))


if __name__ == '__main__':
    main()
