#!/bin/bash - 
#===============================================================================
#
#          FILE: data.manage.sh
# 
USAGE="./data.manage.sh  "
# 
#   DESCRIPTION:  
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Tang (Tang), chao.tang.1@gmail.com
#  ORGANIZATION: le2p
#       CREATED: 07/07/16 10:02:52 RET
#      REVISION:  ---
#===============================================================================

#set -o nounset                             # Treat unset variables as an error
shopt -s extglob 							# "shopt -u extglob" to turn it off
source ~/Shell/functions.sh      			# TANG's shell functions.sh

#=================================================== 

VARIABLE=("tas" "pr" "rsds" "clt" )

#=================================================== for RegCM data

for f in Had_hist.RAD.mon.mean.2001-2005.nc Had_hist.SRF.mon.mean.2001-2005.nc
do
    swio2 $f
done
for f in Had_hist.RAD.mon.mean.2001-2005.swio.nc Had_hist.SRF.mon.mean.2001-2005.swio.nc
do
    cdo timmean $f ${f%swio.nc}swio.timmean.nc
    GrADSNcPrepare ${f%swio.nc}swio.timmean.nc
done


#=================================================== for Had data
for var in ${VARIABLE[*]}
do
    cp /Users/tang/climate/CMIP5/monthly/${var}/hist/HadGEM2-ES/${var}*199601-200512.nc ./
done

for f in $(ls *199601-200512.nc)
do
    echo file is $f

    swio2 $f
done
for f in $(ls *199601-200512.swio.nc)
do
    cdo selyear,2001,2002,2003,2004,2005 $f $f.selyear.temp
    cdo timmean $f.selyear.temp $f.timmean.swio.nc.temp
done

for f in $(ls *_Amon_HadGEM2-ES_historical_r1i1p1_199601-200512.swio.nc.timmean.swio.nc.temp)
do
    mv $f ${f%_Amon*}_Amon_HadGEM2-ES_historical_r1i1p1_200101-200512.timmean.swio.nc
done
rm -rf *199601* 2>&-

ls -lhrt



