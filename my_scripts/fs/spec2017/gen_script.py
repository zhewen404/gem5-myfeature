import argparse
import time
import os
benchmark_choices =[
    "500.perlbench_r", "502.gcc_r", "503.bwaves_r",
    "505.mcf_r", "507.cactusBSSN_r", "508.namd_r",
    "510.parest_r", "511.povray_r", "519.lbm_r",
    "520.omnetpp_r", "521.wrf_r", "523.xalancbmk_r",
    "525.x264_r", "527.cam4_r", "531.deepsjeng_r",
    "538.imagick_r", "541.leela_r", "544.nab_r",
    "548.exchange2_r", "549.fotonik3d_r", "554.roms_r",
    "557.xz_r", "600.perlbench_s", "602.gcc_s",
    "603.bwaves_s", "605.mcf_s", "607.cactusBSSN_s",
    "608.namd_s", "610.parest_s", "611.povray_s",
    "619.lbm_s", "620.omnetpp_s", "621.wrf_s",
    "623.xalancbmk_s", "625.x264_s", "627.cam4_s",
    "631.deepsjeng_s", "638.imagick_s", "641.leela_s",
    "644.nab_s", "648.exchange2_s", "649.fotonik3d_s",
    "654.roms_s", "996.specrand_fs", "997.specrand_fr",
    "998.specrand_is", "999.specrand_ir"
]

bench_map = {
    1: [\
            "600.perlbench_s", "602.gcc_s", \
            "603.bwaves_s", "605.mcf_s", "607.cactusBSSN_s",
            "608.namd_s", "610.parest_s", "611.povray_s",
            "619.lbm_s", "620.omnetpp_s", "621.wrf_s",
            "623.xalancbmk_s", "625.x264_s", "627.cam4_s",
            "631.deepsjeng_s", "638.imagick_s", "641.leela_s",
            "644.nab_s", "648.exchange2_s", "649.fotonik3d_s",
            "654.roms_s", \
            "600.perlbench_s", "602.gcc_s", \
            "603.bwaves_s", "605.mcf_s", "607.cactusBSSN_s",
            "608.namd_s", "610.parest_s", "611.povray_s",
            "619.lbm_s", "620.omnetpp_s", "621.wrf_s",
            "623.xalancbmk_s", "625.x264_s", "627.cam4_s",
            "631.deepsjeng_s", "638.imagick_s", "641.leela_s",
            "644.nab_s", "648.exchange2_s", "649.fotonik3d_s",
            "654.roms_s", \
            "600.perlbench_s", "602.gcc_s", \
            "603.bwaves_s", "605.mcf_s", "607.cactusBSSN_s",
            "608.namd_s", "610.parest_s", "611.povray_s",
            "619.lbm_s", "620.omnetpp_s", "621.wrf_s",
            "623.xalancbmk_s", "625.x264_s", "627.cam4_s",
            "631.deepsjeng_s", "638.imagick_s", "641.leela_s",
            "644.nab_s", "648.exchange2_s", "649.fotonik3d_s",
            "654.roms_s", \
            "600.perlbench_s",\
        ]
}

def construct_argparser():

    parser = argparse.ArgumentParser(description='writeStats')
    parser.add_argument('-s',
                        '--sim',
                        help='sim size',
                        default='test',
                        choices=["test", "train", "ref"],
                        )
    parser.add_argument('-k',
                        '--key',
                        help='benchmark key',
                        type=int,
                        default=1,
                        )
    parser.add_argument('-c',
                        '--core',
                        help='thread num',
                        default=16,
                        )
    parser.add_argument('-d',
                        '--dir',
                        help='specified ckpt dir',
                        )
    return parser

if __name__ == "__main__":
    parser = construct_argparser()
    args = parser.parse_args()

    benchmarks = bench_map[args.key]

    filename = f"my_scripts/fs/spec2017/"\
        f"set{args.key}_{args.sim}_{args.core}.rcS"
    file1 = open(filename, "w")

    string_wr = ''
    for i in range(len(benchmarks)):

        output_dir = "speclogs_" + ''.join(x.strip() \
            for x in time.asctime().split())
        output_dir = output_dir.replace(":","")
        output_dir += f'-{i}'

        # We create this folder if it is absent.
        try:
            os.makedirs(os.path.join(args.dir, output_dir))
        except FileExistsError:
            print("output directory already exists!")


        benchmark = benchmarks[i]
        string_ = "taskset -c {} {} {} {} &\n".format\
            (i, benchmark, args.sim, output_dir)
        string_wr += string_

    file1.write(string_wr)
    file1.close()
    print(f'written file {filename}')
