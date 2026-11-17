#!/bin/bash -l
#SBATCH --job-name=<exp><start_year>
#SBATCH --time=04:00:00
#SBATCH --account=
#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128

   module swap PrgEnv-cray PrgEnv-gnu
   module load cray-hdf5
   module load cray-netcdf

# Time.
   DATE_VAR=$(date)
   echo " WW3: Script started at ${DATE_VAR}."

#-----------------------------------------#
# Script to run WW3 on Archer 2.
#-----------------------------------------#
   RUN_TYPE=<run_type>

   RUN_YEAR=<start_year>
   TIME_NOW="`date +%d%h%H%M%S`"
   PATH_SER="/work/n01/n01/USER1/waves/WW3_builds/build_GNU_SHRD_OK/bin"
#------------------------------------------------------------------------------------------#
# MPI run.
   SHEL_WORK="/work/n01/n01/USER1/waves/WW3_builds/build_GNU_MPI_OK/bin/ww3_shel"
   SHEL_COM="srun --distribution=block:block --hint=nomultithread ${SHEL_WORK}"
   PATH_H=${SLURM_SUBMIT_DIR}
   EXP=`echo ${PATH_H} | sed -e 's@^.*\/\([^\/]*$\)@\1@'`
#------------------------------------------------------------------------------------------#
# Serial run.
#   SHEL_COM="${SCRATCH}/waves/ww3_418/built_exes/gnu_NCEP_st4_bt_shrd/ww3_shel"
#   PATH_H=$PWD
#   EXP=`echo ${PATH_H} | sed -e 's@^.*\/\([^\/]*$\)@\1@'`
#------------------------------------------------------------------------------------------#

# Input directory.
#   echo "Workdir: ${SLURM_SUBMIT_DIR}"
   cd ${PATH_H}
   PATH_I=${PATH_H}/input

# Begin Wavewatch job.
#-----------------------------------------#
# Loop over months.
   for COUNT in {01..12}; do

# Check for previous restart file. Exit if unavailable.
      if [[ ${COUNT} == 01 && ${RUN_YEAR} -gt 1984 ]]; then
         ln -s /work/n01/n01/USER1/waves/WW3/<exp>$(expr ${RUN_YEAR} - 1)/output_12/restart001.ww3 ./restart.ww3
      fi         
# Create a new output directory and path.
      #PATH_O="/work/n01/n01/USER1/waves/WW3/${EXP}/output/"
      PATH_O="${PATH_H}/output_${COUNT}"
      mkdir -p ${PATH_O}

# Create a file to record the code config that was used.
      echo ${PATH_SER} >> ${PATH_O}/run_info
      echo ${SHEL_COM} > ${PATH_O}/run_info

# Copy input files.
      cp ww3_run.sl ${PATH_O}
      cp ww3_grid.nml ${PATH_O}
      #cp ww3_shel.nml ${PATH_O}

      #GRID_FILE="ww3_grid.nml"
      #STRT_FILE="ww3_strt1_bt.inp"
      SHEL_FILE="input/ww3_shel.nml.${COUNT}"
      OUTPUT=${PATH_O}/ww3_output
      FAILED_RUN="0"

# 1. Grid pre-processor -----------------------------------------------------
# Already run so not needed.

#      echo " WW3: Executing grid preprocessor."
#      echo " WW3: Executing grid preprocessor." >> ${OUTPUT}

#      ln -s ./${GRID_FILE} ./ww3_grid.inp > ${OUTPUT} 2>&1
#      ln -s ./input/bottom_${COUNT} ./bottom_${COUNT}
#      cp ww3_grid.inp ${PATH_O} 2>&1
#      ${PATH_SER}/ww3_grid >> ${OUTPUT} 2>&1
#      rm ./ww3_grid.inp ./bottom_${COUNT}

# 2. Initial conditions -----------------------------------------------------
# Restart file so not needed.
#
#      echo " WW3: Configuring initial conditions."
#      echo " WW3: Configuring initial conditions." >> ${OUTPUT}
#
#      ln -s ./${STRT_FILE} ./ww3_strt.inp >> ${OUTPUT} 2>&1
#      ${PATH_SER}/ww3_strt >> ${OUTPUT} 2>&1
#      rm ./ww3_strt.inp
#
# 3a. Input fields for ice fields -------------------------------------------

      echo " WW3: Configuring (ice) fields."
      echo " WW3: Configuring (ice) fields." >> ${OUTPUT}

      if [ ${RUN_TYPE} == "ERA5" ]; then
         if [ ! -f ./processed_ice/ice.ww3.${COUNT} ]; then
            echo " WW3: Ice not found. Exiting." >> ${OUTPUT}
            exit 1
         else
            echo " WW3: Linking to processed ice fields." >> ${OUTPUT}
            ln -s ./processed_ice/ice.ww3.${COUNT} ./ice.ww3
         fi
      else
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/HadGEM-360/ww3ice_histap977/ice_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/HadGEM-360/ww3ice_ar095/ice_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/HadGEM-360/ww3ice_au084/ice_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/CMIP6_HadGEM/ice_HadGEM-GC31-MM_ssp585_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/CMIP6_HadGEM/ssp585/ice_HadGEM-GC31-MM_ssp585_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/CMIP6_HadGEM/ssp126/ice_HadGEM-GC31-MM_ssp126_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/CNRM/ssp126/ice_CNRM_ssp126_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/CNRM/ssp370/ice_CNRM_ssp370_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/CNRM/hist/ice_CNRM_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/GFDL/hist/ice_GFDL_hist_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/GFDL/ssp126/ice_GFDL_ssp126_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_ICE_FILE="/work/n01/n01/USER2/prep_ice/GFDL/ssp370/ice_GFDL_ssp370_${RUN_YEAR}${COUNT}.ww3"
         LUIC_ICE_FILE="/work/n01/n01/USER1/waves/ice/prep_ice/ww3_ice/ERA5_ice_${RUN_YEAR}${COUNT}.ww3"

         if [ ! -f ${LUIC_ICE_FILE} ]; then
            echo " WW3: Ice not found. Exiting." >> ${OUTPUT}
            exit 1
         else
            echo " WW3: Linking to processed ice fields." >> ${OUTPUT}
            ln -s ${LUIC_ICE_FILE} ./ice.ww3
         fi
      fi

# 3b. Input fields for NetCDF files ------------------------------------------

      echo " WW3: Configuring (wind) fields."
      echo " WW3: Configuring (wind) fields." >> ${OUTPUT}

      if [ ${RUN_TYPE} == "ERA5" ] ; then
         if [ ! -f ./processed_winds/wind.ww3.${COUNT} ]; then
            echo " WW3: Winds not found. Exiting." >> ${OUTPUT}
            exit 2
         else
            echo " WW3: Linking to processed wind fields." >> ${OUTPUT}
            ln -s ./processed_winds/wind.ww3.${COUNT} ./wind.ww3
         fi
      else
         #LUIC_WIND_FILE="/work/n01/n01/USER2/prep_winds/HadGEM-360/ww3wind_histap977/wind_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER2/prep_winds/HadGEM-360/ww3wind_ar095/wind_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER2/prep_winds/HadGEM-360/ww3wind_au084/wind_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER2/prep_winds/CMIP6_HadGEM/wind_HadGEM-GC31-MM_ssp585_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER2/prep_winds/CMIP6_HadGEM/ssp585/wind_HadGEM-GC31-MM_ssp585_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER2/prep_winds/CMIP6_HadGEM/ssp126/wind_HadGEM-GC31-MM_ssp126_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER1/winds/HadGEM3-GC31-MM_ssp126/ww3_ssp126/wind_HadGEM-GC31-MM_ssp126_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER1/winds/CNRM_CM6_ssp126/ww3_winds/CNRM_CM6_ssp126_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER1/winds/CNRM_CM6_ssp370/ww3_winds/CNRM_CM6_ssp370_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER1/winds/CNRM_CM6_hist/ww3_winds/CNRM_CM6_hist_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER1/winds/HadGEM3-GC31-MM_ssp585_hist/winds_ww3/wind_HadGEM-GC31-MM_ssp585_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER1/winds/GFDL-ESM4_hist/ww3_winds/GFDL_ESM4_hist_${RUN_YEAR}${COUNT}.ww3"
         #LUIC_WIND_FILE="/work/n01/n01/USER1/winds/GFDL-ESM4_ssp370/ww3_winds/GFDL_ESM4_ssp370_${RUN_YEAR}${COUNT}.ww3"
         LUIC_WIND_FILE="/work/n01/n01/USER1/winds/ERA5_hist/ww3_winds/ERA5_${RUN_YEAR}${COUNT}.ww3"

         if [ ! -f ${LUIC_WIND_FILE} ]; then
            echo " WW3: Winds not found. Exiting." >> ${OUTPUT}
            exit 1
         else
            echo " WW3: Linking to processed wind fields." >> ${OUTPUT}
            ln -s ${LUIC_WIND_FILE} ./wind.ww3
         fi
      fi

# 4. Main program -----------------------------------------------------------

      echo " WW3: Executing shell."
      echo " WW3: Executing shell." >> ${OUTPUT} 2>&1

      if [ ! -f ./input/ww3_shel.nml.${COUNT} ]; then
         echo " WW3: shel file not found. Exiting." >> ${OUTPUT}
         exit 3
      else
         ln -s ./${SHEL_FILE} ./ww3_shel.nml >> ${OUTPUT} 2>&1
         ${SHEL_COM} >> ${OUTPUT} 2>&1
# Captured failure.
         if [ $? != 0 ]; then
            FAILED_RUN="1"
            mv ww3_shel.nml.log ${PATH_O}
            echo " WW3: Run failed. Exiting." >> ${OUTPUT}
            exit 4
         else
            mv ww3_shel.nml.log ${PATH_O}
            rm ./ww3_shel.nml ./ice.ww3 ./wind.ww3
         fi
      fi

## 5a. Point output -----------------------------------------------------------
#
#         echo " WW3: Output for mean wave paramters."
#
#         for OUTP_FILES in `ls input/ww3_outp_p*`
#            do
#               ln -s ${OUTP_FILES} ./ww3_outp.inp
#               ${PATH_SER}/ww3_outp >> ${OUTPUT} 2>&1
#               #/global/homes/t/timmer/ww3_418/model/built_exes/NCEP_st4_bt_shrd/ww3_outp
## Process the output.
#               OUT_TAB=`cat ${OUTP_FILES} | grep -v '^[ ]*$' | tail -1 | gawk '{ print $2 }'`
#               #cat tab${OUT_TAB}.ww3 | sed -e '1i '"${PARAM_NAMES}"'' \
#               #-e '1i '"${PARAMS}"'' \
#               #> ${PATH_O}/`echo ${TAB_FILES} | sed -e 's/\.ww3//'`_${COUNT}
#               cat tab${OUT_TAB}.ww3 > ${PATH_O}/tab_`head -5 ${OUTP_FILES} | sed -ne 's/^.*\([34]....\)$/\1/p'`_${COUNT}
#               rm ./ww3_outp.inp
#            done
#
## 5b. Point output for spectra -----------------------------------------------
#
#         echo " WW3: Output for 1D spectra."
#
#         for OUTP_FILES in `ls input/ww3_outp_1*`
#            do
#               ln -s ${OUTP_FILES} ./ww3_outp.inp
#               ${PATH_SER}/ww3_outp >> ${OUTPUT} 2>&1
#               #/global/homes/t/timmer/ww3_418/model/built_exes/NCEP_st4_bt_shrd/ww3_outp
#               OUT_TAB=`cat ${OUTP_FILES} | grep -v '^[ ]*$' | tail -1 | gawk '{ print $4 }'`
#               cat tab${OUT_TAB}.ww3 > ${PATH_O}/spec1D_`head -5 ${OUTP_FILES} | sed -ne 's/^.*\([34]....\)$/\1/p'`_${COUNT}
#               #cat tab${OUT_TAB}.ww3 > spec1D_`head -5 ${OUTP_FILES} | sed -ne 's/^.*\(4....\)$/\1/p'`
#               rm ./ww3_outp.inp
#            done
#
## 5c. Point output for spectra -----------------------------------------------
#
#         echo " WW3: Output for 2D spectra."
#
#         for OUTP_FILES in `ls input/ww3_outp_2*`
#            do
#               ln -s ${OUTP_FILES} ./ww3_outp.inp
#               ${PATH_SER}/ww3_outp >> ${OUTPUT} 2>&1
#               #/global/homes/t/timmer/ww3_418/model/built_exes/NCEP_st4_bt_shrd/ww3_outp
#               OUT_TAB=`cat ${OUTP_FILES} | grep -v '^[ ]*$' | tail -1 | gawk '{ print $4 }'`
#               OUT_SPC=`cat ${OUTP_FILES} | sed -nr 's/^.*[12][0-9]([0-9]{6}) ([0-2][0-9]).*$/\1\2/p'`
#               cat ww3.${OUT_SPC}.spc > ${PATH_O}/spec2D_`head -5 ${OUTP_FILES} | sed -ne 's/^.*\([34]....\)$/\1/p'`_${COUNT}
#               #cat ww3.${OUT_SPC}.spc > spec2D_`head -5 ${OUTP_FILES} | sed -ne 's/^.*\(4....\)$/\1/p'`
#               rm ./ww3_outp.inp
#            done
#
# 6. Gather relevant output data. -------------------------------------------

      echo " WW3: Wavewatch execution complete."

#      if [ "${FAILED_RUN}" = "0" ]; then

# Capture the final values of parameters.
#               PARAMS=`cat ${GRID_FILE} | grep -B1 '\$ End Parameters' | head -1 | sed -e 's/^..//'`

## Loop over tab files.
#               for TAB_FILES in `ls tab*ww3`
#                  do
#                     cat ${TAB_FILES} | sed -e '1i '"${PARAM_NAMES}"'' \
#                     -e '1i '"${PARAMS}"'' \
#                     > ${PATH_O}/`echo ${TAB_FILES} | sed -e 's/\.ww3//'`_${COUNT}
#                     #> tab_`head -5 ${TAB_FILES} | sed -ne 's/^.*\(4....\)$/\1/p'`_${COUNT}
#                  done

# Move the restart file.
      rm restart.ww3
      mv restart001.ww3 log.ww3 nest1.ww3 out_grd.ww3 out_pnt.ww3 ${PATH_O} 2> /dev/null
      echo " WW3: Linking new restart file for run: ${RUN_YEAR}/${COUNT}."
# Don't link if in December (last month).
      if [ ${COUNT} != 12 ]; then
         ln -s ${PATH_O}/restart001.ww3 ./restart.ww3
      fi

# Clean up.
#      rm *ww3 ww3*spc 2> /dev/null

   done

