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
mem=${1}GB
config=c${cores}-${mem}

ckptdir=ckpt/x86-linux/spec2017-speccast_roi/$config/x86-linux_set${setkey}_sync${sync}_util${util}
kernel_loc=~/.cache/gem5/x86-linux-kernel-4.19.83 
image_loc=/home/zhewen/repo/gem5-stable/gem5-resources/src/spec-2017-speccast/disk-image/spec-2017-speccast/spec-2017-speccast1-image/spec-2017-speccast1
script_loc=my_scripts/fs/spec2017-speccast/set${setkey}_sync${sync}_c${cores}_u${util}.rcS

python3 my_scripts/fs/spec2017-speccast/gen_script.py --sync_at ${sync} -c ${cores} -k ${setkey} -u ${util}
echo "run script generated"

echo "create ckpt once $work begin seen!"

mkdir -p log

./build/X86_MOESI_hammer/gem5.fast \
-d $ckptdir \
configs/example/fs.py \
--cpu-type X86KvmCPU \
--kernel ${kernel_loc} \
--disk-image ${image_loc} \
--num-cpus=$cores \
--num-dirs=4 \
--mem-size=$mem \
--work-begin-exit-count $work \
--checkpoint-at-end \
--script=${script_loc}

echo "Completed spec-speccast set${setkey}_sync${sync}_util${util}..." >> log/spec2017-speccast_ckpt_status.txt

cp ${script_loc} ${ckptdir}/set${setkey}_sync${sync}_c${cores}_u${util}.rcS