#!/bin/sh
#
# Script to generate text parameters and 1D spectra from WW3.

   #EXP=X_GS256A_ERA5_
   EXP=X_GS256A_HadGEM3_GC31_MM_

   for YEARS in {1986..2015}; do
      echo " Processing ${EXP}${YEARS}..."
      EXP_DIR="/work/n01/n01/benerm_n01/waves/WW3/${EXP}${YEARS}"
      cd ${EXP_DIR}
      if [ ! -d output_01/outp_params ]; then
         ./script_outp_params_ops.sh
         ./script_outp_1D_ops.sh
      else
         echo " Params output directory exists!"
         exit 1
      fi
   done
