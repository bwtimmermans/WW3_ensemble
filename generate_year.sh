#!/bin/sh

###########################################
# Script for writing a new job directory. #
#                                         #
#-----------------------------------------#
# Version 0.2 09/10/2015                  #
#                                         #
###########################################

# Assign variables  #
#===================#

   VARS_FILE="exp_details"

# Process the files #
#===================#

   VAR_LIST=`cat ${VARS_FILE} | head -1`
   VAR_NAME_1=`echo ${VAR_LIST} | gawk '{ print $1 }'`
   VAR_NAME_2=`echo ${VAR_LIST} | gawk '{ print $2 }'`
   VAR_NAME_3=`echo ${VAR_LIST} | gawk '{ print $3 }'`
   VAR_NAME_4=`echo ${VAR_LIST} | gawk '{ print $4 }'`
   VAR_NAME_5=`echo ${VAR_LIST} | gawk '{ print $5 }'`
   VAR_NAME_6=`echo ${VAR_LIST} | gawk '{ print $6 }'`
   VAR_NAME_7=`echo ${VAR_LIST} | gawk '{ print $7 }'`
   VAR_NAME_8=`echo ${VAR_LIST} | gawk '{ print $8 }'`
   VAR_NAME_9=`echo ${VAR_LIST} | gawk '{ print $9 }'`
   VAR_NAME_10=`echo ${VAR_LIST} | gawk '{ print $10 }'`
   VAR_NAME_11=`echo ${VAR_LIST} | gawk '{ print $11 }'`
   VAR_NAME_12=`echo ${VAR_LIST} | gawk '{ print $12 }'`
   VAR_NAME_13=`echo ${VAR_LIST} | gawk '{ print $13 }'`
   VAR_NAME_14=`echo ${VAR_LIST} | gawk '{ print $14 }'`
   VAR_NAME_15=`echo ${VAR_LIST} | gawk '{ print $15 }'`

   COUNT="2"
   VARS=`cat ${VARS_FILE} | sed -ne ''${COUNT}'p'`

   while [ "${VARS}" != "" ]
      do
         VAR_1=`echo ${VARS} | gawk '{ print $1 }'`
         VAR_2=`echo ${VARS} | gawk '{ print $2 }'`
         VAR_3=`echo ${VARS} | gawk '{ print $3 }'`
         VAR_4=`echo ${VARS} | gawk '{ print $4 }'`
         VAR_5=`echo ${VARS} | gawk '{ print $5 }'`
         VAR_6=`echo ${VARS} | gawk '{ print $6 }'`
         VAR_7=`echo ${VARS} | gawk '{ print $7 }'`
         VAR_8=`echo ${VARS} | gawk '{ print $8 }'`
         VAR_9=`echo ${VARS} | gawk '{ print $9 }'`
         VAR_10=`echo ${VARS} | gawk '{ print $10 }'`
         VAR_11=`echo ${VARS} | gawk '{ print $11 }'`
         VAR_12=`echo ${VARS} | gawk '{ print $12 }'`
         VAR_13=`echo ${VARS} | gawk '{ print $13 }'`
         VAR_14=`echo ${VARS} | gawk '{ print $14 }'`
         VAR_15=`echo ${VARS} | gawk '{ print $15 }'`

         LOC_COUNT=`expr ${COUNT} - 1`

# Loop over the different input templates files.
# Note: Experiment name has to be VAR_1VAR_2
         EXP=${VAR_1}${VAR_2}
         if [ -d "${EXP}" ]
            then
               echo " WARNING: JOB already exists. Exiting."
               exit 1
         fi

         cp -R global_template ${EXP}
         for TEMPLATE in `ls global_template/input/ww3_shel_nml \
                             global_template/input/ww3_prnc_nml.* \
                             global_template/input/ww3_ounf_template.nml \
                             global_template/input/ww3_outp_*_template.inp \
                             global_template/script_outp_params_ops.sh \
                             global_template/script_outp_1D_ops.sh \
                             global_template/script_ounf_ops.sh \
                             global_template/ww3_run.sl \
                             global_template/script_ops.sh`
            do
               TEMP_TYPE=`echo ${TEMPLATE} | cut -f2,3 -d'/'`
               OUTPUT_FILE="${EXP}/${TEMP_TYPE}"

               cat ${TEMPLATE} | sed \
               -e 's/<'${VAR_NAME_1}'>/'${VAR_1}'/g' \
               -e 's/<'${VAR_NAME_2}'>/'${VAR_2}'/g' \
               -e 's/<'${VAR_NAME_3}'>/'${VAR_3}'/g' \
               -e 's/<'${VAR_NAME_4}'>/'${VAR_4}'/g' \
               -e 's/<'${VAR_NAME_5}'>/'${VAR_5}'/g' \
               -e 's/<'${VAR_NAME_6}'>/'${VAR_6}'/g' \
               -e 's/<'${VAR_NAME_7}'>/'${VAR_7}'/g' \
               -e 's/<'${VAR_NAME_8}'>/'${VAR_8}'/g' \
               -e 's/<'${VAR_NAME_9}'>/'${VAR_9}'/g' \
               -e 's/<'${VAR_NAME_10}'>/'${VAR_10}'/g' \
               -e 's/<'${VAR_NAME_11}'>/'${VAR_11}'/g' \
               -e 's/<'${VAR_NAME_12}'>/'${VAR_12}'/g' \
               -e 's/<'${VAR_NAME_13}'>/'${VAR_13}'/g' \
               -e 's/<'${VAR_NAME_14}'>/'${VAR_14}'/g' \
               -e 's/<'${VAR_NAME_15}'>/'${VAR_15}'/g' \
               > "${OUTPUT_FILE}"
            done

         COUNT=`expr ${COUNT} + 1`
         VARS=`cat ${VARS_FILE} | sed -ne ''${COUNT}'p'`

# Scripted operations post creation.
      ./${EXP}/script_ops.sh > ./${EXP}/script_ops_out_pre

      done

