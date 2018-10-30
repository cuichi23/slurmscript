#!/bin/bash -i
#$ -S /bin/bash
#
# MPI-PKS script for job submission script with ’sbatch’.
# Syntax is Bash with special sbatch-instructions that begin with ’#SBATCH’.
# For more detailed documentation, see
#     https://start.pks.mpg.de/getting/started/slurm
#

# check whether the csv-files are all in the same version
# compare size, in question overwrite smaller file

# SBATCH Options
# Hardware requirements.
#SBATCH --mem=16G
#SBATCH --time 72:00:00

# Specify the parallel environment and the necessary number of slots.
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16

# split stdout and stderr, directory for output files, directory for error files
#SBATCH --output /home/lwetzel/Programming/1AqueuePKS/joboutput/%j_%a.out
#SBATCH --error /home/lwetzel/Programming/1AqueuePKS/joberrors/%j_%a.err

# print output to command line, important and helpful for debugging
set -x

# --- Job Execution
# For faster disk access copy files to /scratch first.
# $$ would mean the folder on scratch is named after the job id, here we replace that with the id of the CSV-file
scratch=/scratch/$USER/$SLURM_JOB_ID/$SLURM_ARRAY_TASK_ID
mkdir -p $scratch
cd $scratch
cp -r $HOME/Programming/1AqueuePKS/coupledOscillatorsDPLLqueueBasis/* $scratch

# Execution - running the actual program.
# [Remember: Don’t read or write to /home from here.]
echo "Running on $(hostname)"
echo "We are in $(pwd)"
# check python version
#python -V
#echo $PYTHONPATH

# load python 2.7 module
sleep 0.5
module load intelpython2

# check python version
#sleep 0.5
#python -V
#echo $PYTHONPATH
#echo $PATH
#ls -l $(which python)

# start single case
# python case_bruteforce.py ring 3 0.25 1 0.45 1.2068965517 0 1 0 1 3 1 0 -999 0.
# start many parameter sets, read-out from file, see Array Jobs in documentation
# sed command has to be adjusted, such that it reads out the parameters in the right order from the file
# also add that a parameter-file is written and placed into the results folder
# sbatch --array=4-6:2 qjob_slurm.sh will spawn 2 jobs, with id 4 and 6, then check status: squeue -u lwetzel
sleep 0.5
echo python case_bruteforce.py `awk -F: 'FNR=='$SLURM_ARRAY_TASK_ID' {print $1}' $HOME/Programming/1AqueuePKS/DPLLParametersForQUEUEwithTabs.csv` 0. > ID_LINE.txt
sleep 0.5
echo python case_bruteforce.py `awk 'FNR=='$SLURM_ARRAY_TASK_ID' {print $10; print $12; print $1; print $2; print $3; print $4; print $5; print $6; print $11; print '1'; print $14; print $15; print $16; print $17;}' $HOME/Programming/1AqueuePKS/DPLLParametersForQUEUEwithTabs.csv` 0. > "$SLURM_ARRAY_TASK_ID".txt
sleep 0.5
echo python case_bruteforce.py `awk 'FNR=='$SLURM_ARRAY_TASK_ID' {print $10; print $12; print $1; print $2; print $3; print $4; print $5; print $6; print $11; print '1'; print $14; print $15; print $16; print $17;}' $HOME/Programming/1AqueuePKS/DPLLParametersForQUEUEwithTabs.csv` 0.
sleep 0.5
python case_bruteforce.py `awk 'FNR=='$SLURM_ARRAY_TASK_ID' {print $10; print $12; print $1; print $2; print $3; print $4; print $5; print $6; print $11; print '1'; print $14; print $15; print $16; print $17;}' $HOME/Programming/1AqueuePKS/DPLLParametersForQUEUEwithTabs.csv` 0.

# Finish - Copy files back to your home directory, clean up.
mkdir $HOME/Programming/1AqueuePKS/$SLURM_ARRAY_TASK_ID
sleep 0.5
cp -r $scratch/results $HOME/Programming/1AqueuePKS/$SLURM_ARRAY_TASK_ID/results
sleep 0.1
cp -r $scratch/1params.txt $HOME/Programming/1AqueuePKS/$SLURM_ARRAY_TASK_ID
sleep 0.1
cp -r $scratch/*.txt $HOME/Programming/1AqueuePKS/$SLURM_ARRAY_TASK_ID
sleep 0.1
cp -r $scratch/case_bruteforce.py $HOME/Programming/1AqueuePKS/$SLURM_ARRAY_TASK_ID
sleep 0.1
cp -r $scratch/simulation.py $HOME/Programming/1AqueuePKS/$SLURM_ARRAY_TASK_ID
sleep 0.1
cd
sleep 0.5
rm -rf $scratch

