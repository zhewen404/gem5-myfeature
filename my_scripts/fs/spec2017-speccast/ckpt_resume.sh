#!/bin/bash
if [ $# -ne 5 ] 
then 
    echo Usage: ./ckpt_resume.sh num_cores setkey sync util experiment
    exit
fi

cores=$1
setkey=$2
sync=$3
util=$4
experiment=$5

mem=64GB
config=c${cores}-${mem}
checkpoint_dir=ckpt/x86-linux/spec2017-speccast_roi/$config/x86-linux_set${setkey}_sync${sync}_util${util}
workend=$(($cores*$util/100))

# EDIT two vars below!
kernel_loc=~/.cache/gem5/x86-linux-kernel-4.19.83 
image_loc=/home/zhewen/repo/gem5-stable/gem5-resources/src/spec-2017-speccast/disk-image/spec-2017-speccast/spec-2017-speccast1-image/spec-2017-speccast1

case $experiment in
  0) 
    name=uniqueAccess
    coh=X86_MESI_Three_Level_Unique_Access
    l2_size='1MB'
    l2_assoc=32
    ;;
  *)
    echo "bad option experiment $experiment" ;
    exit 1;;
esac

out_dir=my_STATS/${name}/c${cores}_set${setkey}_sync${sync}_u${util}_${experiment}

l1_size='128kB'
l1_assoc=8

l0_size='32kB'
l0_assoc=8

mkdir -p $out_dir
cp $checkpoint_dir/set${setkey}_sync${sync}_c${cores}_u${util}.rcS $out_dir/set${setkey}_sync${sync}_c${cores}_u${util}.rcS

square_root=$(echo "$cores" | awk '{print sqrt($1)}')

echo "Running gem5 for set${setkey}_sync${sync}_util${util}..."

time ./build/${coh}/gem5.fast \
-d ${out_dir} \
configs/example/fs.py \
--kernel ${kernel_loc} \
--disk-image ${image_loc} \
--work-end-exit-count ${workend} \
--num-cpus=${cores} \
--num-dirs=4 \
--mem-size=${mem} \
--checkpoint-dir=$checkpoint_dir \
--checkpoint-restore=1 \
--ruby --restore-with-cpu O3CPU \
--num-l2caches=$cores \
--l0d_size=${l0_size} \
--l0i_size=${l0_size} \
--l0d_assoc=${l0_assoc} \
--l0i_assoc=${l0_assoc} \
--l1d_size=${l1_size} \
--l1d_assoc=${l1_assoc} \
--l2_size=${l2_size} \
--l2_assoc=${l2_assoc} \
--network=garnet \
--topology=MeshDirCorners_XY \
--mesh-rows=${square_root} \
--vcs-per-vnet=8 \
--router-latency=1 2>&1 | tee ${out_dir}/log.txt
