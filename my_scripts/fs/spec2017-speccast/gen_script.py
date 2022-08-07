import argparse
import time
import os

working_set_map = {
    """
    @inproceedings{
        10.1145/3297663.3310311,
        author = {Singh, Sarabjeet and Awasthi, Manu},
        title = {Memory Centric Characterization and
            Analysis of SPEC CPU2017 Suite},
        year = {2019},
        publisher = {Association for Computing Machinery},
        booktitle = {Proceedings of the 2019 ACM/SPEC
            International Conference on Performance Engineering},
    }
    """

    'H': ['mcf', 'cactuBSSN', 'lbm'],
    'M': ['gcc 1', 'gcc 2', 'gcc 3', 'gcc 4', 'gcc 5',\
            'omnetpp', 'xalancbmk', 'xz 1', 'xz 2', 'xz 3', \
            'bwaves 1', 'bwaves 2', 'bwaves 3', 'bwaves 4', \
            'parest', 'cam4', 'fotonik3d', 'roms', \
        ],
    'L': ['perlbench', 'x264 1', 'x264 2', 'x264 3', \
            'deepsjeng', 'leela', 'exchange2', 'namd', \
            'povray', 'wrf', 'blender', 'imagick', 'nab', \
        ],
}

bench_map = {
    1: ['mcf', 'cactuBSSN', 'perlbench 1', 'bwaves 2', \
        'lbm', 'x264 1', 'omnetpp', 'namd'],
    2: ['bwaves 1', 'x264 2', \
        'namd', 'perlbench 3'],
    3: ['mcf', 'wrf', 'lbm', 'imagick', \
        'deepsjeng', 'cactuBSSN', 'povray', 'xz 2', \
        'cam4', 'leela', 'fotonik3d', 'nab', \
        'exchange2', 'xalancbmk', 'blender', 'roms', \
        ]
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
        f' -p {args.core} -l {args.sync_at} --' + \
        " --".join(benchmarks)
    # command += f' > out.txt\ncat out.txt\n'///
    command += '\n'
    print("******** command for full system:")
    print(command)

    file1.write(command)
    file1.close()
    print(f'written file {filename}')
