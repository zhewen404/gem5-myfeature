import argparse
import time
import os
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
working_set_map = {
    'H': ['mcf', 'cactuBSSN', 'lbm'],
    'M': ['omnetpp', 'xz 1', 'xz 2', 'xz 3', \
            'bwaves 1', 'bwaves 2', 'bwaves 3', 'bwaves 4', \
            'cam4', 'fotonik3d', 'roms', \
        ],
    'L': ['deepsjeng', 'leela', 'exchange2', 'namd', \
            'x264 1', 'x264 3', \
            'povray', 'wrf', 'blender', 'imagick', 'nab', \
        ],
}

bench_map = {
    1: ['povray'],
    2: ['cam4'],
    3: ['nab'],
    4: ['mcf'],
    5: ['namd'],
    6: ['omnetpp'],
    7: ['lbm'],
    8: ['fotonik3d'],
    9: working_set_map['H'], #h
    10: ['povray', 'cam4', 'nab', 'mcf', 'namd', \
        'omnetpp', 'lbm', 'fotonik3d'], #hetro
    11: working_set_map['L'],#L
    12: ['omnetpp', 'cam4', 'fotonik3d', 'roms', 'xz 1', 'xz 2', 'xz 3'],#M
    13: ['cactuBSSN'],
    14: ['xz 1'],
    15: ['xz 2'],
    16: ['xz 3'],
    17: ['roms'],
    18: ['deepsjeng'],
    19: ['leela'],
    20: ['exchange2'],
    21: ['x264 1'],
    22: ['x264 3'],
    23: ['wrf'],
    24: ['blender'],
    25: ['imagick'],
    26: ['lbm', 'omnetpp', \
        'xz 1', 'cam4', 'fotonik3d', 'roms', \
        'deepsjeng', 'leela', 'exchange2', 'namd', \
        'x264 1', 'povray', 'wrf', 'blender', \
        'imagick', 'nab', \
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
    parser.add_argument('-u',
                        '--util',
                        help='utilization',
                        type=int,
                        choices=[25, 50, 100],
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
        f"set{args.key}_sync{args.sync_at}_c{args.core}_u{args.util}.rcS"
    file1 = open(filename, "w")

    if args.util == 100:
        eff_core = args.core
    elif args.util == 50:
        eff_core = int(args.core/2)
    elif args.util == 25:
        eff_core = int(args.core/4)
    else: assert False, 'unknow args.util'

    if len(benchmarks) > eff_core:
        ori_len = len(benchmarks)
        benchmarks = benchmarks[0:eff_core]
        print(f'**predefined set contatins {ori_len} benchmarks, '\
            f'truncated to {len(benchmarks)} benchmarks now.\n'\
            f'{benchmarks}')

    command = f'sleep 5\n./spec_cast_gem5 -w -c myspeccast'+ \
        f' -p {eff_core} -l {args.sync_at} --' + \
        " --".join(benchmarks)
    # command += f' > out.txt\ncat out.txt\n'///
    command += '\n'
    print("******** command for full system:")
    print(command)

    file1.write(command)
    file1.close()
    print(f'written file {filename}')
