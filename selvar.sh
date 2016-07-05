#!/bin/bash - 
#===============================================================================
#
#          FILE: pprcm2.sh
# 
#        USAGE=" ./pprcm2.sh [OPTION...] [+ RegCM outpur directory]"
# 
#   DESCRIPTION: do Post-Processing RegCM calculation &
# 				plot of the netCDF outcome data
# 
#       OPTIONS: ---  default: corrent directory
#       		 ---  -p, plot with GrADS ONLY 
#       		 ---  -c, ONLY calculate the partial relation coefficients
#       		 ---  -s, ONLY select the target variables
#       		 ---  -m, use the monthly mean data
#       		 ---  -e, use EIN data
#       		 ---  -x, EIN data vs OBS data
#       		 ---  -t, to test the code ONLY
#       		 ---  -o, ONLY calculate the ocean
#       		 ---  -l, ONLY calculate the land
#       		 ---  -y, indicate to year for selection,default is 5
#
#  REQUIREMENTS: ---  cdo, awk, grads, gradsmap2, gradsbias2,
# 					  stdmap.gs, stdbiasmap.gs color.gs,cbarn.gs
# 					  GrADSNcPrepare in RegCM-4.3.5.6/bin
# 					  there is a tar file in ~/backup/pprcm.tar
# 					  mask.sh
#          BUGS: ---  no ncpdq command, leave the ofile unpacked
#       		 ---  -x, cannot plot, ein15 refuse sdfopen 
#        USAGES: ---  1,put the requirements in the right directory
#          		 ---  2,modify gradsmap & gradsbias, see themselves
# 		         ---  3,modify this file as required 
#       		 ---  4,I CLOSED the Warning about Inconsistent variable
# 					  definition for xlat and xlon.
# 		         ---  5,make sure parameters in this file compatible 
# 					  with echo other 
#        AUTHOR: Tang (Tang), chao.tang.1@gmail.com
#  ORGANIZATION: le2p
#       CREATED: 02/15/2014 09:52:53 RET
#      REVISION:  ---
#===============================================================================
#set -o nounset                              # Treat unset variables as an error
export PATH=/usr/local/bin/:$PATH 

####################################
### monthly mean & merge
####################################
#=================================================== select var

radfile="SWIO.RAD.all.mon.mean.2001-2005.nc"
srffile="SWIO.SRF.all.mon.mean.2001-2005.nc"

cdo -r selvar,rsns,rsnl,rsnscl,rtnlcl,rsnlcl,rts,rsnt,clt,rtl,dlwssr,dlwssrd,dswssr,dswssrd,cl,clw $radfile SWIO.RAD.mon.mean.2001-2005.nc 
cdo -r selvar,pr,evspsbl,hfss,rsdl,rsds,prc,aldirs,aldifs,tas $srffile SWIO.SRF.mon.mean.2001-2005.nc 
#=================================================== ymonmean
cdo -r ymonmean SWIO.SRF.mon.mean.2001-2005.nc SWIO.SRF.ymon.mean.2001-2005.nc 
cdo -r ymonmean SWIO.RAD.mon.mean.2001-2005.nc SWIO.RAD.ymon.mean.2001-2005.nc 

for file in SWIO.SRF.ymon.mean.2001-2005.nc SWIO.RAD.ymon.mean.2001-2005.nc 
do
    cdo -r seltimestep,5,6,7,8,9,10 $file ${file%.nc}.MJJASO.nc
    cdo -r seltimestep,1,2,3,4,11,12 $file ${file%.nc}.NDJFMA.nc
done

#=================================================== move
mkdir pprcmdata
mv RAD.all.200?.nc pprcmdata/
mv SRF.all.200?.nc pprcmdata/
mv SWIO.???.mon.mean.2001-2005.nc pprcmdata/
mv SWIO.???.ymon.mean.2001-2005.nc pprcmdata/
mv SWIO.???.ymon.mean.2001-2005.MJJASO.nc pprcmdata/
mv SWIO.???.ymon.mean.2001-2005.NDJFMA.nc pprcmdata/
#=================================================== done
