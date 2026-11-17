#!/bin/sh
# Job pre-processing for ERA5 WW3 run on Archer 2.
# In support of NOC submission to COWCLIP round 3.
# Written by BT and LB 28/07/2023.

# Updates for HadGEM 07/01/2024.
# Updates for GFDL 10/07/2024.
# Updates for CNRM 11/08/2024.

#------------------------------------------------------------------------------------------#
# Environment.
   module swap PrgEnv-cray PrgEnv-gnu
   module load cray-hdf5
   module load cray-netcdf

   WORK_DIR="/work/n01/n01/USER1/waves/WW3"
   PATH_SER="/home/n01/n01/USER1/ww3/WW3/build_GNU_SHRD_OK/bin"
   OUTPUT="script_ops_out"
   EXP="<exp><start_year>"
   RUN_TYPE=<run_type>

   cd ${WORK_DIR}/${EXP}/input
#------------------------------------------------------------------------------------------#
# Generate monthly wind and ice processing files.
#------------------------------------------------------------------------------------------#
# Check for ERA5 or HadGEM runs.
   if [ ${RUN_TYPE} == "ERA5" ] || [ ${RUN_TYPE} == "ERA" ] || [ ${RUN_TYPE} == "GFDL" ] || [ ${RUN_TYPE} == "CNRM" ]; then

# Leap year functions.
# https://askubuntu.com/questions/1081137/how-do-i-check-which-years-are-leap-years
# isleap() { date -d $1-02-29 &>/dev/null && echo is leap || echo is not leap; }
# date -d ${YEAR}-02-29 &>/dev/null
# echo $?
      date -d <start_year>-02-29 &>/dev/null
      if [ $? == 1 ]; then
         ln -s ./date_file_NOLEAP ./date_file
      else
         ln -s ./date_file_LEAP ./date_file
      fi
   else
      ln -s ./date_file_HADGEM ./date_file
   fi

#------------------------------------------------------------------------------------------#
# Find variable names for different netCDF input files.
#------------------------------------------------------------------------------------------#
## Get variable names from NetCDF file.
#   if [ ${RUN_TYPE} == "GFDL" ]; then
#      ln -s /work/n01/n01/USER1/winds/ssp370_GFDL-ESM4/monthly/ssp370_GFDL-ESM4_UV_<start_year>01.nc ./wind.nc
#
#      LAT_VAR=`ncdump -h wind.nc | sed -n -e '/dimensions/,/variables/ p' | grep '[Ll][Aa][Tt]' | gawk '{ print $1 }'`
#      LON_VAR=`ncdump -h wind.nc | sed -n -e '/dimensions/,/variables/ p' | grep '[Ll][Oo][Nn]' | gawk '{ print $1 }'`
#
#      U10=`ncdump -h wind.nc | sed -n -e '/variables/,/global attributes/ p' | grep -m1 '[Uu][Bb1a][Oo0s]' | gawk '{ print $2 }' | cut -d'(' -f1`
#      V10=`ncdump -h wind.nc | sed -n -e '/variables/,/global attributes/ p' | grep -m1 '[Vv][Bb1a][Oo0s]' | gawk '{ print $2 }' | cut -d'(' -f1`
#
#      cat ww3_prnc_nml.WND | sed \
#         -e 's/<lat>/'${LAT_VAR}'/' \
#         -e 's/<lon>/'${LON_VAR}'/' \
#         -e 's/u10/'${U10}'/' \
#         -e 's/v10/'${V10}'/' \
#         > ww3_prnc_nml.WND.TEMP
#      
#      mv ww3_prnc_nml.WND.TEMP ww3_prnc_nml.WND
#   fi

#------------------------------------------------------------------------------------------#
# Generate monthly wind and ice processing files.
#------------------------------------------------------------------------------------------#

   ARR_MONTHS=( $(cat date_file | gawk '{ print $1 }') )
   ARR_DAYS=( $(cat date_file | gawk '{ print $2 }') )

# Winds.
   echo " WW3: Configuring wind files."
   echo " WW3: Configuring wind files." >> ${OUTPUT}
   for MONTHS in {0..11}; do
      cat ww3_prnc_nml.WND | sed -e 's/<start_month>/'${ARR_MONTHS[${MONTHS}]}'/g' \
                                 -e 's/<stop_day>/'${ARR_DAYS[${MONTHS}]}'/g' \
      > ww3_prnc.nml.WND.${ARR_MONTHS[${MONTHS}]}
   done

# Ice.
   echo " WW3: Configuring sea-ice files."
   echo " WW3: Configuring sea-ice files." >> ${OUTPUT}
   for MONTHS in {0..11}; do
      cat ww3_prnc_nml.ICE | sed -e 's/<start_month>/'${ARR_MONTHS[${MONTHS}]}'/g' \
                                 -e 's/<stop_day>/'${ARR_DAYS[${MONTHS}]}'/g' \
                                 > ww3_prnc.nml.ICE.${ARR_MONTHS[${MONTHS}]}
   done

# Shel files.
   echo " WW3: Configuring shel files."
   echo " WW3: Configuring shel files." >> ${OUTPUT}
   for MONTHS in {0..11}; do
      if [ ${MONTHS} == 11 ]; then
         cat ww3_shel_nml | sed -e 's/<start_month>/'${ARR_MONTHS[${MONTHS}]}'/g' \
                                -e 's/<stop_month>/01/g' \
                                -e 's/<stop_day>/01/g' \
                                -e 's/<stop_year>/'`expr <start_year> + 1`'/g' \
                                -e 's/<restart_stride>/'`expr ${ARR_DAYS[${MONTHS}]} \* 86400`'/g' \
         > ww3_shel.nml.${ARR_MONTHS[${MONTHS}]}
      else
         cat ww3_shel_nml | sed -e 's/<start_month>/'${ARR_MONTHS[${MONTHS}]}'/g' \
                                -e 's/<stop_month>/'${ARR_MONTHS[`expr ${MONTHS} + 1`]}'/g' \
                                -e 's/<stop_day>/01/g' \
                                -e 's/<stop_year>/<start_year>/g' \
                                -e 's/<restart_stride>/'`expr ${ARR_DAYS[${MONTHS}]} \* 86400`'/g' \
         > ww3_shel.nml.${ARR_MONTHS[${MONTHS}]}
      fi
   done
#                                    -e 's/<stop_day>/'${ARR_DAYS[${MONTHS}]}'/g' \

# TO-DO: Output files.

#------------------------------------------------------------------------------------------#
# Process winds and ice.
#------------------------------------------------------------------------------------------#
   cd ${WORK_DIR}/${EXP}

#------------------------------------------------------------------------------------------#
# 1. Grid pre-processor.
   echo " WW3: Executing grid preprocessor."
   echo " WW3: Executing grid preprocessor." >> ${OUTPUT}

   ${PATH_SER}/ww3_grid >> ${OUTPUT} 2>&1

#------------------------------------------------------------------------------------------#
# Check for ERA5, GFDL or HadGEM runs.
   if [ ${RUN_TYPE} == "ERA5" ]; then

# 2a. Input wind fields for NetCDF files.
      echo " WW3: Configuring fields (winds)."
      echo " WW3: Configuring fields (winds)." >> ${OUTPUT}

      for MONTHS in {0..11}; do
         if [ ! -f ./processed_winds/wind.ww3.${ARR_MONTHS[${MONTHS}]} ]; then
            echo " WW3: Creating new fields (winds)." >> ${OUTPUT}
            ln -s /work/n01/n01/USER2/ERA5-forcing/winds/10m_UV_<start_year>_`expr ${MONTHS} + 1`.nc ./wind.nc
            ln -s ./input/ww3_prnc.nml.WND.${ARR_MONTHS[${MONTHS}]} ./ww3_prnc.nml
            ${PATH_SER}/ww3_prnc >> ${OUTPUT} 2>&1
            mv wind.ww3 ./processed_winds/wind.ww3.${ARR_MONTHS[${MONTHS}]}
            mv ww3_prnc.nml.log ./processed_winds/ww3_prnc.nml.log.${ARR_MONTHS[${MONTHS}]}
            rm ./wind.nc ./ww3_prnc.nml
         else
            echo " WW3: Processed wind fields exist!" >> ${OUTPUT}
         fi
      done

#------------------------------------------------------------------------------------------#
# 2b. Input sea-ice fields for NetCDF files.
      echo " WW3: Configuring fields (sea-ice)."
      echo " WW3: Configuring fields (sea-ice)." >> ${OUTPUT}

      for MONTHS in {01..12}; do
         if [ ! -f ./processed_ice/ice.ww3.${MONTHS} ]; then
            echo " WW3: Creating new fields (sea-ice)." >> ${OUTPUT}
            ln -s /work/n01/n01/USER1/waves/ice/<start_year>/SIC_<start_year>_${MONTHS}.nc ./ice.nc
            ln -s ./input/ww3_prnc.nml.ICE.${MONTHS} ./ww3_prnc.nml
            ${PATH_SER}/ww3_prnc >> ${OUTPUT} 2>&1
            mv ice.ww3 ./processed_ice/ice.ww3.${MONTHS}
            mv ww3_prnc.nml.log ./processed_ice/ww3_prnc.nml.log.${MONTHS}
            rm ./ice.nc ./ww3_prnc.nml
         else
            echo " WW3: Processed sea-ice fields exist!" >> ${OUTPUT}
         fi
      done

#------------------------------------------------------------------------------------------#
# Check for ERA5, GFDL or HadGEM runs.
   elif [ ${RUN_TYPE} == "GF" ]; then

# 2a. Input wind fields for NetCDF files.
      echo " WW3: Configuring fields (winds)."
      echo " WW3: Configuring fields (winds)." >> ${OUTPUT}

      for MONTHS in {01..12}; do
         if [ ! -f ./processed_winds/wind.ww3.${MONTHS} ]; then
            echo " WW3: Creating new fields (winds)." >> ${OUTPUT}
	    ln -s /work/n01/n01/USER1/winds/ssp370_GFDL-ESM4/monthly/ssp370_GFDL-ESM4_UV_<start_year>${MONTHS}.nc ./wind.nc
            ln -s ./input/ww3_prnc.nml.WND.${MONTHS} ./ww3_prnc.nml
            ${PATH_SER}/ww3_prnc >> ${OUTPUT} 2>&1
            mv wind.ww3 ./processed_winds/wind.ww3.${MONTHS}
            mv ww3_prnc.nml.log ./processed_winds/ww3_prnc.nml.log.${MONTHS}
            rm ./wind.nc ./ww3_prnc.nml
         else
            echo " WW3: Processed wind fields exist!" >> ${OUTPUT}
         fi
      done

#------------------------------------------------------------------------------------------#
# 2b. Input sea-ice fields for NetCDF files.
      echo " WW3: Configuring fields (sea-ice)."
      echo " WW3: Configuring fields (sea-ice)." >> ${OUTPUT}

      for MONTHS in {01..12}; do
         if [ ! -f ./processed_ice/ice.ww3.${MONTHS} ]; then
            echo " WW3: Creating new fields (sea-ice)." >> ${OUTPUT}
            ln -s /work/n01/n01/USER1/waves/ice/ssp370_GFDL-ESM4/SIC_<start_year>_${MONTHS}.nc ./ice.nc
            ln -s ./input/ww3_prnc.nml.ICE.${MONTHS} ./ww3_prnc.nml
            ${PATH_SER}/ww3_prnc >> ${OUTPUT} 2>&1
            mv ice.ww3 ./processed_ice/ice.ww3.${MONTHS}
            mv ww3_prnc.nml.log ./processed_ice/ww3_prnc.nml.log.${MONTHS}
            rm ./ice.nc ./ww3_prnc.nml
         else
            echo " WW3: Processed sea-ice fields exist!" >> ${OUTPUT}
         fi
      done

   else
      echo " WW3: Skipping HadGEM winds and ice."
      echo " WW3: Skipping HadGEM winds." >> ${OUTPUT}
   fi
#------------------------------------------------------------------------------------------#
   echo " WW3: Preparation complete." >> ${OUTPUT}
   echo

