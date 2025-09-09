#!/bin/bash

#SBATCH --exclusive

#SBATCH --hint nomultithread
#SBATCH --gpu-bind closest

#SBATCH --partition amdgpu

#SBATCH --time 00:02:00

#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --gres gpu:1

#SBATCH --mem 10gb

# -----------

make -f Makefile_amdflang clean && make -f Makefile_amdflang

# -----------

# -----------
EXE=poisson

INP=poisson.data

M=$(grep ntx $INP | awk '{print $1}')
nit=$(grep iter $INP | awk '{print $1}')

LOG=log.${M}.${nit}it.${SLURM_JOB_ID}
# -----------

# -----------
LOCAL_WORK_DIR=$SLURM_SUBMIT_DIR/TMP/$SLURM_JOB_ID
mkdir -p $LOCAL_WORK_DIR

cp bin/$EXE $INP $LOCAL_WORK_DIR

cd $LOCAL_WORK_DIR
pwd
# -----------

srun ./$EXE | tee $LOG

mv $LOG $SLURM_SUBMIT_DIR

