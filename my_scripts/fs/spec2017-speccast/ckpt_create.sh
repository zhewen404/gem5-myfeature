#!/bin/bash
if [ $# -ne 4 ] 
then 
    echo Usage: ./ckpt_create.sh num_cores set_key sync util
    exit
fi

cores=$1
setkey=$2
sync=$3
util=$4
work=$(($cores*$util/100*$sync))
mem=24GB
config=c${cores}-${mem}
ckptdir=ckpt/x86-linux/$config/spec2017-speccast_roi/$config/x86-linux_set${setkey}_sync${sync}_util${util}

python3 my_scripts/fs/spec2017-speccast/gen_script.py --sync_at ${sync} -c ${cores} -k ${setkey} -u ${util}
echo "run script generated"

echo "create ckpt once $work begin seen!"

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
--work-begin-exit-count $work \
--checkpoint-at-end \
--script=my_scripts/fs/spec2017-speccast/set${setkey}_sync${sync}_c${cores}_u${util}.rcS

echo "Completed spec-speccast set${setkey}_sync${sync}_util${util}..." >> log/spec2017-speccast_ckpt_status.txt