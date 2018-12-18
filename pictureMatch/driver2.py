from compareCourseImages import compare_courses, construct_image_table, process_classes


def makemap(path, dirs):
    res = {}
    for d in dirs:
        res[d] = path+d+'/Images'
    return res


def main():
    outdir = 'output'
    path = '/Users/jspacco/projects/clickers/data/'

    tests = ['test1', 'test2']

    cs141s = makemap(path,
        ['KnoxCS141W15',
        'KnoxCS141F15-1',
        'KnoxCS141F15-2',
        'KnoxCS141W16',
        'KnoxCS141F16-1',
        'KnoxCS141F16-2',
        'KnoxCS141W17-2'])

    #'KnoxCS201S15',
    #'KnoxCS201S16',
    cse141s = makemap(path,
        ['UCSD.CSE141F14-A',
         'UCSD.CSE141F14-B',
         'UCSD.CSE141F15',
         'UCSD.CSE141F16',
         'UCSD.CSE141S17-1',
         'UCSD.CSE141S17-2'])

    cs142s = makemap(path,
        ['KnoxCS142W15',
        'KnoxCS142S15',
        'KnoxCS142W16',
        'KnoxCS142S16',
        'KnoxCS142W17',
        'KnoxCS142S17'])

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


    debug = {'KnoxCS141F15-1' : path+'KnoxCS141F15-1/Images',
        'KnoxCS141F15-2' : path+'KnoxCS141F15-2/Images'}

    debug = {'KnoxCS201S15' : path+'KnoxCS201S15/Images',
        'KnoxCS201S16' : path+'KnoxCS201S16/Images'}

    # process_classes(debug, 'tmp', True)


    #process_classes(cs141s, outdir, True)
    #process_classes(cse141s, outdir, True)
    process_classes(cse141s, outdir, False)


if __name__ == '__main__':
    main()
