from compareCourseImages import compare_courses, construct_image_table, process_classes


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

    debug = ['KnoxCS201S15', 'KnoxCS201S16']

    debug = {'KnoxCS141F15-1' : '/Users/jspacco/projects/clickers/data/KnoxCS141F15-1/Images',
        'KnoxCS141F15-2' : '/Users/jspacco/projects/clickers/data/KnoxCS141F15-2/Images'}

    process_classes(debug, 'tmp', True)


    #process_classes(cs141s, outdir, full)
    #process_classes(cse141s, outdir, full)


if __name__ == '__main__':
    main()
