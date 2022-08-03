#!/bin/bash
if [ $# -ne 3 ] 
then 
    echo Usage: ./ckpt_create.sh num_cores set_key sim
    exit
fi

cores=$1
setkey=$2
sim=$3
mem=2GB
config=c${cores}-${mem}
ckptdir=ckpt/x86-linux/$config/spec2017_roi/$sim/x86-linux_${config}_$setkey

python3 my_scripts/fs/spec2017/gen_script.py -s ${sim} -c ${cores} -k ${setkey} -d ${ckptdir}
echo "run script generated"

mkdir -p log

./build/X86_MOESI_hammer/gem5.fast \
-d $ckptdir \
configs/example/fs.py \
--kernel ~/.cache/gem5/x86-linux-kernel-4.19.83 \
--disk-image /home/zhewen/repo/gem5-stable/gem5-resources/src/spec-2017/disk-image/spec-2017/spec-2017-image/spec-2017 \
--num-cpus=$cores \
--num-dirs=4 \
--mem-size=$mem \
--work-end-exit-count 64 \
--checkpoint-at-end \
--script=my_scripts/fs/spec2017/set${setkey}_${sim}_${cores}.rcS

echo "Completed spec ${setkey}_${sim}..." >> log/spec2017_ckpt_status.txt