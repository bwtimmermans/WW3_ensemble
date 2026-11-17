#!/bin/bash

# https://stackoverflow.com/questions/65672312/chain-multiple-slurm-jobs-with-dependency
#--------------------------------------------------------------#
# Example logic for a Slurm submission script to submit with dependencies.

   #EXP_NAME=GS256A_HadGEM_

   for YEAR in {2005..2006}; do
# First year.
      if [ ${YEAR} == "2005" ]; then
         cd /work/n01/n01/benerm_n01/waves/WW3/${YEAR}
         ID=$(sbatch --parsable ww3_run.sl)
      fi
# Remaining years.
      cd /work/n01/n01/benerm_n01/waves/WW3/${YEAR}
      ID=$(sbatch --parsable --dependency=after:${ID}:+5 ww3_run.sl)
   done

