#!/bin/bash
if [ $# -ne 3 ] 
then 
    echo Usage: ./ckpt_create.sh num_cores set_key sync
    exit
fi

cores=$1
setkey=$2
sync=$3
mem=2GB
config=c${cores}-${mem}
ckptdir=ckpt/x86-linux/$config/spec2017-speccast_roi/$config/x86-linux_set${setkey}_sync${sync}

python3 my_scripts/fs/spec2017-speccast/gen_script.py --sync_at ${sync} -c ${cores} -k ${setkey}
echo "run script generated"

mkdir -p log

./build/X86_MOESI_hammer/gem5.fast \
-d $ckptdir \
configs/example/fs.py \
--cpu-type X86KvmCPU \
--kernel ~/.cache/gem5/x86-linux-kernel-4.19.83 \
--disk-image /home/zhewen/repo/gem5-stable/gem5-resources/src/spec-2017-speccast/disk-image/spec-2017-speccast/spec-2017-speccast1-image/spec-2017-speccast1 \
--num-cpus=$cores \
--num-dirs=4 \
--mem-size=$mem \
--work-begin-exit-count 64 \
--checkpoint-at-end \
--script=my_scripts/fs/spec2017-speccast/set${setkey}_sync${sync}_c${cores}.rcS

echo "Completed spec-speccast ${setkey}_${sync}..." >> log/spec2017-speccast_ckpt_status.txt