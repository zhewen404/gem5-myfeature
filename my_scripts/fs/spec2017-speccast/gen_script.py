import argparse
import time
import os

bench_map = {
    1: ['mcf', 'cactusBSSN', 'perlbench 1', 'bwaves 2', \
        'lbm', 'x264 1', 'omnetpp', 'x264 1'],
    2: ['bwaves 1', 'x264 2', \
        'namd', 'perlbench 3'],
}

def construct_argparser():

    parser = argparse.ArgumentParser(description='writeStats')
    parser.add_argument('-k',
                        '--key',
                        help='benchmark key',
                        type=int,
                        default=1,
                        )
    parser.add_argument('-c',
                        '--core',
                        help='thread num',
                        type=int,
                        default=16,
                        )
    parser.add_argument('--sync_at',
                        help='sync at',
                        type=int,
                        default=2,
                        )
    return parser

if __name__ == "__main__":
    parser = construct_argparser()
    args = parser.parse_args()

    benchmarks = bench_map[args.key]

    filename = f"my_scripts/fs/spec2017-speccast/"\
        f"set{args.key}_sync{args.sync_at}_c{args.core}.rcS"
    file1 = open(filename, "w")

    command = f'sleep 5\n./spec_cast_gem5 -w -c myspeccast'+ \
        ' -p {args.core} -l {args.sync_at} --' + \
        " --".join(benchmarks)
    command += f' > out.txt\ncat out.txt\n'
    print("******** command for full system:")
    print(command)

    file1.write(command)
    file1.close()
    print(f'written file {filename}')
