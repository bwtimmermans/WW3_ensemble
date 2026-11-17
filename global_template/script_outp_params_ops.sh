#!/bin/sh
# Post-processing for ERA5 WW3 run on Archer 2.
# Write out a table of parameters for point output.
# In support of NOC submission to COWCLIP round 3.
# Written by BT and LB 28/07/2023.

#------------------------------------------------------------------------------------------#
# Environment.
   module swap PrgEnv-cray PrgEnv-gnu
   module load cray-hdf5
   module load cray-netcdf

   WORK_DIR="/work/n01/n01/USER1/waves/WW3"
   PATH_SER="/home/n01/n01/USER1/ww3/WW3/build_GNU_SHRD_OK/bin"
   OUTPUT="script_outp_out"
   EXP="<exp><start_year>"

   cd ${WORK_DIR}/${EXP}

# Check if WW3 runs have been completed.
   if [ ! -d output_01 ]; then
      echo " WW3: Output directory not found. Exiting."
      exit 1
   fi

##------------------------------------------------------------------------------------------#
## Assume date file is already in place.
##------------------------------------------------------------------------------------------#
## Leap year functions.
## https://askubuntu.com/questions/1081137/how-do-i-check-which-years-are-leap-years
## isleap() { date -d $1-02-29 &>/dev/null && echo is leap || echo is not leap; }
## date -d ${YEAR}-02-29 &>/dev/null
## echo $?
#   date -d <start_year>-02-29 &>/dev/null
#   if [ $? == 1 ]; then
#      ln -s ./date_file_NOLEAP ./date_file
#   else
#      ln -s ./date_file_LEAP ./date_file
#   fi
#
#------------------------------------------------------------------------------------------#
# Generate outp files.
#------------------------------------------------------------------------------------------#

   ARR_MONTHS=( $(cat input/date_file | gawk '{ print $1 }') )
   ARR_DAYS=( $(cat input/date_file | gawk '{ print $2 }') )

# Outp files.
   echo " WW3: Configuring outp files."
   echo " WW3: Configuring outp files." >> ${OUTPUT}

   for MONTHS in {0..11}; do
      COUNT=1

      cd ${WORK_DIR}/${EXP}
      mkdir ./output_${ARR_MONTHS[${MONTHS}]}/outp_params 2> /dev/null
      cd ./output_${ARR_MONTHS[${MONTHS}]}/outp_params
      ln -s ../../mod_def.ww3 .
      ln -s ../out_pnt.ww3 .
      ln -s ../../input/ww3_outp_params_23_template.inp .

# Create input files from the template.
      for BUOY_NAME in `cat ../../points | gawk '{ print $3 }' | cut -d"'" -f2`; do
         cat ./ww3_outp_params_23_template.inp | sed -e 's/<start_month>/'${ARR_MONTHS[${MONTHS}]}'/g' \
                                                     -e 's/<stepping>/3600/g' \
                                                     -e 's/<num_outs>/'`expr ${ARR_DAYS[${MONTHS}]} \* 24`'/g' \
                                                     -e 's/<buoy_num>/'${COUNT}'/g' \
                                                     -e 's/<buoy_name>/'${BUOY_NAME}'/g' \
         > ./ww3_outp_params_${BUOY_NAME}.inp.${ARR_MONTHS[${MONTHS}]}
# Generate the output data.
         ln -s ./ww3_outp_params_${BUOY_NAME}.inp.${ARR_MONTHS[${MONTHS}]} ./ww3_outp.inp
         ${PATH_SER}/ww3_outp
	 if [ $? == 0 ]; then
	    mv tab23.ww3 tab_${ARR_MONTHS[${MONTHS}]}_${BUOY_NAME}
         else
            echo " WW3: Writing output failed."
            echo " WW3: Writing output failed." >> ${OUTPUT}
	 fi
         rm ./ww3_outp.inp

         COUNT=`expr ${COUNT} + 1`
      done

      echo " WW3: Month ${ARR_MONTHS[${MONTHS}]} complete."
      echo " WW3: Month ${ARR_MONTHS[${MONTHS}]} complete." >> ${OUTPUT}
   done

##------------------------------------------------------------------------------------------#
## Process winds and ice.
##------------------------------------------------------------------------------------------#
#   cd ${WORK_DIR}/${EXP}
#
## 1. Grid pre-processor.
#   echo " WW3: Executing grid preprocessor."
#   echo " WW3: Executing grid preprocessor." >> ${OUTPUT}
#
#   ${PATH_SER}/ww3_grid >> ${OUTPUT} 2>&1
#
## 2a. Input wind fields for NetCDF files.
#   echo " WW3: Configuring fields (winds)."
#   echo " WW3: Configuring fields (winds)." >> ${OUTPUT}
#
#   for MONTHS in {0..2}; do
#      if [ ! -f ./processed_winds/wind.ww3.${ARR_MONTHS[${MONTHS}]} ]
#         then
#            echo " WW3: Creating new fields (winds)." >> ${OUTPUT}
#            ln -s /work/n01/n01/USER2/ERA5-forcing/10m_UV_<start_year>_`expr ${MONTHS} + 1`.nc ./wind.nc
#            ln -s ./input/ww3_prnc.nml.WND.${ARR_MONTHS[${MONTHS}]} ./ww3_prnc.nml
#            ${PATH_SER}/ww3_prnc >> ${OUTPUT} 2>&1
#            mv wind.ww3 ./processed_winds/wind.ww3.${ARR_MONTHS[${MONTHS}]}
#            mv ww3_prnc.nml.log ./processed_winds/ww3_prnc.nml.log.${ARR_MONTHS[${MONTHS}]}
#            rm ./wind.nc ./ww3_prnc.nml
#         else
#            echo " WW3: Processed wind fields exist!" >> ${OUTPUT}
#      fi
#   done
#
## 2b. Input sea-ice fields for NetCDF files.
#   echo " WW3: Configuring fields (sea-ice)."
#   echo " WW3: Configuring fields (sea-ice)." >> ${OUTPUT}
#
#   for MONTHS in {01..03}; do
#      if [ ! -f ./processed_ice/ice.ww3.${MONTHS} ]
#         then
#            echo " WW3: Creating new fields (sea-ice)." >> ${OUTPUT}
#            ln -s /work/n01/n01/USER1/waves/ice/<start_year>/SIC_<start_year>_${MONTHS}.nc ./ice.nc
#            ln -s ./input/ww3_prnc.nml.ICE.${MONTHS} ./ww3_prnc.nml
#            ${PATH_SER}/ww3_prnc >> ${OUTPUT} 2>&1
#            mv ice.ww3 ./processed_ice/ice.ww3.${MONTHS}
#            mv ww3_prnc.nml.log ./processed_ice/ww3_prnc.nml.log.${ARR_MONTHS[${MONTHS}]}
#            rm ./ice.nc ./ww3_prnc.nml
#         else
#            echo " WW3: Processed sea-ice fields exist!" >> ${OUTPUT}
#      fi
#   done
#
#   echo " WW3: Preparation complete." >> ${OUTPUT}
#   echo
#
