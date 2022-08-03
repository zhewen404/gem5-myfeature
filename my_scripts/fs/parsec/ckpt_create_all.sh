#!/bin/bash
if [ $# -ne 2 ] 
then 
    echo Usage: ./ckpt_create_all.sh num_cores sim
    exit
fi

cores=$1
sim=$2
mem=2GB
config=c${cores}-${mem}


for benchmark in 'blackscholes' 'bodytrack' 'canneal' 'dedup' 'facesim' 'ferret' 'fluidanimate' 'freqmine' 'raytrace' 'streamcluster' 'swaptions' 'vips' 'x264'
do
    python3 my_scripts/fs/parsec/gen_script.py -s ${sim} -c ${cores} -b ${benchmark}
    echo "run script generated"

mkdir -p log

    ./build/X86_MOESI_hammer/gem5.fast \
    -d ckpt/x86-linux/$config/parsec_roi/$sim/x86-linux_${config}_$benchmark \
    configs/example/fs.py \
    --kernel ~/.cache/gem5/x86-linux-kernel-4.19.83 \
    --disk-image /home/zhewen/repo/gem5-stable/gem5-resources/src/parsec/disk-image/parsec/parsec-image/parsec \
    --num-cpus=$cores \
    --num-dirs=4 \
    --mem-size=$mem \
    --work-begin-exit-count=1 --checkpoint-at-end \
    --script=my_scripts/fs/parsec/${benchmark}_${sim}_${cores}.rcS

    echo "Completed parsec ${benchmark}_${sim}..." >> log/ckpt_status.txt

done
