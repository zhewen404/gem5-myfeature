#!/bin/bash
if [ $# -ne 4 ] 
then 
    echo Usage: ./create_ckpts.sh num_cores setkey sync experiment
    exit
fi

cores=$1
setkey=$2
sync=$3
experiment=$4
mem=2GB
config=c${cores}-${mem}
checkpoint_dir=ckpt/x86-linux/$config/spec2017-speccast_roi/$config/x86-linux_set${setkey}_sync${sync}

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


l1_size='128kB'
l1_assoc=8

l0_size='32kB'
l0_assoc=8

mkdir -p log
mkdir -p log/${name}

echo "Running gem5 for set${setkey}_sync${sync}..."

time ./build/${coh}/gem5.fast \
-d my_STATS/${name}/set${setkey}_sync${sync}_c${cores}_${experiment} \
configs/example/fs.py \
--kernel ~/.cache/gem5/x86-linux-kernel-4.19.83 \
--disk-image /home/zhewen/repo/gem5-stable/gem5-resources/src/spec-2017-speccast/disk-image/spec-2017-speccast/spec-2017-speccast1-image/spec-2017-speccast1 \
--work-end-exit-count 1 \
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
--mesh-rows=8 \
--vcs-per-vnet=8 \
--router-latency=1 2>&1 | tee log/${name}/set${setkey}_sync${sync}_c${cores}_${experiment}.txt


