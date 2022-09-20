#!/bin/bash
if [ $# -eq 0 ] 
then 
    echo Usage: ./run.sh bench1 bench2 ...
    exit
fi

num_cores=$#
square_root=$(echo "$num_cores" | awk '{print sqrt($1)}')

coh=X86_MESI_Three_Level
cmd=
option=
cwd=
i=0
for bench in $@
do
    case $bench in
    x264)
        cmd_single=/home/zhewen/repo/cpu2017/benchspec/CPU/525.x264_r/run/run_base_refrate_orig_static-m64.0000/x264_r_base.orig_static-m64
        option_single='--pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o /home/zhewen/repo/cpu2017/benchspec/CPU/525.x264_r/run/run_base_refrate_orig_static-m64.0000/BuckBunny_New.264 /home/zhewen/repo/cpu2017/benchspec/CPU/525.x264_r/run/run_base_refrate_orig_static-m64.0000/BuckBunny.yuv 1280x720 > run_000-1000_x264_r_base.orig_static-m64_x264_pass1.out 2>> run_000-1000_x264_r_base.orig_static-m64_x264_pass1.err'
        cwd_single=/home/zhewen/repo/cpu2017/benchspec/CPU/525.x264_r/run/run_base_refrate_orig_static-m64.0000/
        ;;
    xz) 
        cmd_single=/home/zhewen/repo/cpu2017/benchspec/CPU/557.xz_r/run/run_base_refrate_orig_static-m64.0000/xz_r_base.orig_static-m64
        option_single='/home/zhewen/repo/cpu2017/benchspec/CPU/557.xz_r/run/run_base_refrate_orig_static-m64.0000/cld.tar.xz 160 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 59796407 61004416 6'
        cwd_single=/home/zhewen/repo/cpu2017/benchspec/CPU/557.xz_r/run/run_base_refrate_orig_static-m64.0000/
        ;;
    *)
        echo "bad option bench $bench" ;
        exit 1;;
    esac
    i=$i+1
    cmd+="${cmd_single}"
    option+="${option_single}"
    cwd+="${cwd_single}"

    if (( $i!=${num_cores} ))
    then
        cmd+=";"
        option+=";"
        cwd+=";"
    fi
done
# echo $option

l0_size='32kB'
l0_assoc=8

# --debug-flags=O3CPUAll,SyscallAll \

build/$coh/gem5.opt \
--outdir=aggregate_${num_cores}_${bench}_m5out \
configs/example/se_my.py \
--cpu-type O3CPU \
--num-cpus ${num_cores} \
--ruby \
--num-dirs=4 \
--num-l2caches=${num_cores} \
--l0d_size=${l0_size} \
--l0i_size=${l0_size} \
--l0d_assoc=${l0_assoc} \
--l0i_assoc=${l0_assoc} \
--l1d_size=32kB \
--l1i_size=32kB \
--l1d_assoc=8 \
--l1i_assoc=8 \
--l2_size=1MB \
--l2_assoc=32 \
--network=garnet \
--topology=MeshDirCorners_XY \
--mesh-rows=${square_root} \
--vcs-per-vnet=8 \
--router-latency=1 \
--mem-size 4GB \
--cmd=$cmd \
--options="$option" \
--cwd="$cwd" \
--checkpoint-restore 1 \
--restore-simpoint-checkpoint \
--checkpoint-dir agg_${bench} 
# --maxinsts=10000000