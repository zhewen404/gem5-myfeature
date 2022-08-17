#!/bin/bash
if [ $# -ne 5 ] 
then 
    echo Usage: ./ckpt_resume_condor.sh num_cores setkey sync util experiment
    exit
fi

cores=$1
setkey=$2
sync=$3
util=$4
experiment=$5

mem=${cores}GB
config=c${cores}-${mem}
workend=$(($cores*$util/100))

# EDIT three vars below!
kernel_loc=../x86-linux-kernel-4.19.83 
image_loc=../spec-2017-speccast1
# checkpoint_dir=../$config/x86-linux_set${setkey}_sync${sync}_util${util} # if resources
checkpoint_dir=../sync${sync}/x86-linux_set${setkey}_sync${sync}_util${util}
# checkpoint_dir=../x86-linux_set${setkey}_sync${sync}_util${util} # if staging
#if inplace
# checkpoint_dir=ckpt/x86-linux/spec2017-speccast_roi/$config/x86-linux_set${setkey}_sync${sync}_util${util}

case $experiment in
  0) 
    name=uniqueAccess
    coh=X86_MESI_Three_Level_Unique_Access
    l2_size='1MB'
    l2_assoc=32
    l1_size='128kB'
    l1_assoc=8
    ;;
  1)
    name=base0
    coh=X86_MESI_Three_Level
    l2_size='1MB'
    l2_assoc=32
    l1_size='32kB'
    l1_assoc=512 # fully assoc
    ;;
  2)
    name=base1
    coh=X86_MESI_Three_Level
    l2_size='1MB'
    l2_assoc=32
    l1_size='64kB'
    l1_assoc=1024 # fully assoc
    ;;
  3)
    name=base2
    coh=X86_MESI_Three_Level
    l2_size='1MB'
    l2_assoc=32
    l1_size='128kB'
    l1_assoc=2048 # fully assoc
    ;;
  4)
    name=base3
    coh=X86_MESI_Three_Level
    l2_size='1MB'
    l2_assoc=32
    l1_size='256kB'
    l1_assoc=4096 # fully assoc
    ;;
  5)
    name=base4
    coh=X86_MESI_Three_Level
    l2_size='1MB'
    l2_assoc=32
    l1_size='512kB'
    l1_assoc=8192 # fully assoc
    ;;
  6)
    name=base5
    coh=X86_MESI_Three_Level
    l2_size='1MB'
    l2_assoc=32
    l1_size='1MB'
    l1_assoc=16384 # fully assoc
    ;;
  7)
    name=base6
    coh=X86_MESI_Three_Level
    l2_size='1MB'
    l2_assoc=32
    l1_size='2MB'
    l1_assoc=32768 # fully assoc
    ;;
  8)
    name=base7
    coh=X86_MESI_Three_Level
    l2_size='1MB'
    l2_assoc=32
    l1_size='4MB'
    l1_assoc=65536 # fully assoc
    ;;
  9)
    name=base8
    coh=X86_MESI_Three_Level
    l2_size='1MB'
    l2_assoc=32
    l1_size='8MB'
    l1_assoc=131072 # fully assoc
    ;;
  *)
    echo "bad option experiment $experiment" ;
    exit 1;;
esac

out_dir=my_STATS/${name}/c${cores}_set${setkey}_sync${sync}_u${util}_${experiment}

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
