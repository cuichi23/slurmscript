#!/bin/bash -i 
#$ -S /bin/bash 
# 
# MPI-PKS script for job submission script with ’qsub’. 
# Syntax is Bash with special qsub-instructions that begin with ’#$’. 
# For more detailed documentation, see 
#     https://start.pks.mpg.de/dokuwiki/doku.php/getting-started:queueing_system 
# 

# check whether the csv-files are all in the same version
# compare size, in question overwrite smaller file

# --- Mandatory qsub arguments 
# Hardware requirements. 
#$ -l h_rss=16000M,h_fsize=1000M,h_cpu=40:00:00,hw=x86_64,h_stack="INFINITY"  

# Specify the parallel environment and the necessary number of slots. 
#$ -pe smp 12

# split stdout and stderr, directory for output files, directory for error files
#$ -j n -o $HOME/Programming/1AqueuePKS/joboutput/ -e $HOME/Programming/1AqueuePKS/joberrors/                                  

# --- Optional qsub arguments 
# Change working directory - your job will be run from the directory 
# that you call qsub in.  So stdout and stderr will end up there. 
#$ -cwd 

# --- Job Execution 
# For faster disk access copy files to /scratch first. 
# $$ would mean the folder on scratch is named after the job id, here we replace that with the id of the CSV-file
scratch=/scratch/$USER/$SGE_TASK_ID 
mkdir -p $scratch 
cd $scratch 
cp -r $HOME/Programming/1AqueuePKS/coupledOscillatorsDPLLqueueBasis/* $scratch

# Execution - running the actual program. 
# [Remember: Don’t read or write to /home from here.] 
echo "Running on $(hostname)" 
echo "We are in $(pwd)" 
# start single case
# python oracle.py ring 3 0.25 0.1 1.45 1.1225198136 0 400
# start many parameter sets, read-out from file, see Array Jobs in documentation
# sed command has to be adjusted, such that it reads out the parameters in the right order from the file
# also add that a parameter-file is written and placed into the results folder
# qsub -t 4-6:2 qjob.sh will spawn 2 jobs, with id 4 and 6
sleep 0.5 
echo python case_bruteforce.py `awk -F: 'FNR=='$SGE_TASK_ID' {print $1}' $HOME/Programming/1AqueuePKS/DPLLParametersForQUEUEwithTabs.csv` 0. > ID_LINE.txt
sleep 0.5
echo python case_bruteforce.py `awk 'FNR=='$SGE_TASK_ID' {print $10; print $12; print $1; print $2; print $3; print $4; print $5; print $6; print $11; print '1'; print $14; print $15; print $16; print $17;}' $HOME/Programming/1AqueuePKS/DPLLParametersForQUEUEwithTabs.csv` 0. > "$SGE_TASK_ID".txt
sleep 0.5
echo python case_bruteforce.py `awk 'FNR=='$SGE_TASK_ID' {print $10; print $12; print $1; print $2; print $3; print $4; print $5; print $6; print $11; print '1'; print $14; print $15; print $16; print $17;}' $HOME/Programming/1AqueuePKS/DPLLParametersForQUEUEwithTabs.csv` 0.
sleep 0.5
python case_bruteforce.py `awk 'FNR=='$SGE_TASK_ID' {print $10; print $12; print $1; print $2; print $3; print $4; print $5; print $6; print $11; print '1'; print $14; print $15; print $16; print $17;}' $HOME/Programming/1AqueuePKS/DPLLParametersForQUEUEwithTabs.csv` 0.

# Finish - Copy files back to your home directory, clean up. 
cp -r $scratch $HOME/Programming/1AqueuePKS/     
sleep 0.5
cd
sleep 0.5 
rm -rf $scratch


