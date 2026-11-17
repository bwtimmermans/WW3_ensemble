#!/bin/sh
# Post-processing for ERA5 WW3 run on Archer 2.
# Write out NetCDF fields data for all variables.
# In support of NOC submission to COWCLIP round 3.
# Written by BT and LB 11/02/2024.

#------------------------------------------------------------------------------------------#
# Environment.
   module swap PrgEnv-cray PrgEnv-gnu
   module load cray-hdf5
   module load cray-netcdf

   WORK_DIR="/work/n01/n01/USER1/waves/WW3"
   #TARGET_DIR="/work/n01/n01/USER2/"
   TARGET_DIR=${PWD}
   #PATH_SER="/home/n01/n01/USER1/ww3/WW3/build_GNU_SHRD_OK/bin"
   PATH_SER="/work/n01/n01/USER1/waves/WW3_builds/build_GNU_SHRD_OK/bin"
   OUTPUT="script_ounf_out"
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
#   date -d 1979-02-29 &>/dev/null
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

# Output files.
   for MONTHS in {0..11}; do

# Create target diretory.
      mkdir -p ${TARGET_DIR}/${EXP}/output_${ARR_MONTHS[${MONTHS}]} 2> /dev/null
      cd ${TARGET_DIR}/${EXP}/output_${ARR_MONTHS[${MONTHS}]}

      echo " WW3: Generating ounf (NetCDF) files."
      echo " WW3: Generating ounf (NetCDF) files." >> ${OUTPUT}

      ln -s ${WORK_DIR}/${EXP}/mod_def.ww3 .
      ln -s ${WORK_DIR}/${EXP}/output_${ARR_MONTHS[${MONTHS}]}/out_grd.ww3 .
      ln -s ${WORK_DIR}/${EXP}/input/ww3_ounf_template.nml .

# Chose to unpack all field variables into a single NetCDF file.
# (Could create a separate file for each variable if needed.)
      #for BUOY_NAME in `cat ../../points | gawk '{ print $3 }' | cut -d"'" -f2`; do
      cat ./ww3_ounf_template.nml | sed -e 's/<start_month>/'${ARR_MONTHS[${MONTHS}]}'/g' \
                                                  -e 's/<stepping>/3600/g' \
                                                  -e 's/<num_outs>/'`expr ${ARR_DAYS[${MONTHS}]} \* 24`'/g' \
      > ./ww3_ounf.nml.${ARR_MONTHS[${MONTHS}]}
# Generate the output data.
      ln -s ./ww3_ounf.nml.${ARR_MONTHS[${MONTHS}]} ./ww3_ounf.nml
      ${PATH_SER}/ww3_ounf >> ${OUTPUT}
      if [ $? == 0 ]; then
         mv ww3.field.nc ww3.${EXP}_${ARR_MONTHS[${MONTHS}]}.nc
         echo " WW3: Writing month ${ARR_MONTHS[${MONTHS}]} successful."
         echo " WW3: Writing month ${ARR_MONTHS[${MONTHS}]} successful." >> ${OUTPUT}
      else
         echo " WW3: Writing month ${ARR_MONTHS[${MONTHS}]} failed."
         echo " WW3: Writing month ${ARR_MONTHS[${MONTHS}]} failed." >> ${OUTPUT}
      fi
      #rm ./ww3_ounf.nml

   done

   echo " WW3: Fields for experiment ${EXP} complete."
   echo " WW3: Fields for experiment ${EXP} complete." >> ${OUTPUT}

