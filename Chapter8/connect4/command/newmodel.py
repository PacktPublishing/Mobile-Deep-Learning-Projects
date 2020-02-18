def newmodel(argv):
    import argparse
    parser = argparse.ArgumentParser(description='New model and save to .h5 file')
    parser.add_argument('filename', nargs='?', default='latest.h5', help='save to filename')
    args = parser.parse_args(argv)

    from util.nn import NN
    NN(args.filename)
