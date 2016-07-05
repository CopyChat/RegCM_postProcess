#!/bin/bash - 
#===============================================================================
#
#          FILE: pprcm2.sh
# 
         USAGE="./pprcm2.sh [OPTION...] [+ RegCM outpur directory]"
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
NewTag="Micro.UW.CLM45"
####################################
### monthly mean & merge
####################################

#Secondly, I study the two seasonal mean for all the parameters for CCM and RRTM. You could also calculate it so that the data size will reduce too.
#At TOA: LWN (net LW) and SWN at clear sky and all sky condition;(RTL, RSNT, RTNLCL, RTNSCL in my version)
#At surface: LWN, SWN, LW (RSNL, RSNS, RSDL in my version)
#2 meter Temperature, precipitation, total cloud cover;(TAS, PR, CLT in my version)
#and because surface albedo is calculated as (1-SWN/downward surface SW), so I think you also need to save the parameter 'downward surface SW' (RSDS in my version)







#=================================================== clean up
for tag in SRF RAD 
do
    for year in 2001 2002 2003 2004 2005
    do
    	nof=$(eval ls *$tag.$year????00.nc 2>&- | wc -l)
    	echo "----------------------------------"
    	echo " there are $nof $tag files"
    	echo "----------------------------------"

    	for file in $(eval ls *$tag.$year????00.nc 2>&-)
    	do
    		echo "================" $file
    		echo "cdo timmean $file $file.timmean.temp 2>&-  # timmean for monthly file"
    		cdo timmean $file $file.timmean.$year.temp 2>&-  # timmean for monthly file
    	done

		echo "cdo mergetime *$tag.*timmean.$year.temp $tag.all.nc"
		cdo mergetime *$tag.*timmean.$year.temp $tag.all.$year.nc
    done

    cdo mergetime $tag.all.*.nc second.mois.$tag.nc
    cdo shifttime,-1m second.mois.$tag.nc $NewTag.$tag.all.mon.mean.2001-2005.nc

done

####################################
### monthly mean & merge
####################################
#=================================================== select var

radfile="$NewTag.RAD.all.mon.mean.2001-2005.nc"
srffile="$NewTag.SRF.all.mon.mean.2001-2005.nc"

cdo -r selvar,rsns,rsnl,rsnscl,rtnlcl,rsnlcl,rts,rsnt,clt,rtl,dlwssr,dlwssrd,dswssr,dswssrd,cl,clw $radfile $NewTag.RAD.mon.mean.2001-2005.nc 
cdo -r selvar,pr,evspsbl,hfss,rsdl,rsds,prc,aldirs,aldifs,tas $srffile $NewTag.SRF.mon.mean.2001-2005.nc 
#=================================================== ymonmean
cdo -r ymonmean $NewTag.SRF.mon.mean.2001-2005.nc $NewTag.SRF.ymon.mean.2001-2005.nc 
cdo -r ymonmean $NewTag.RAD.mon.mean.2001-2005.nc $NewTag.RAD.ymon.mean.2001-2005.nc 

for file in $NewTag.SRF.ymon.mean.2001-2005.nc $NewTag.RAD.ymon.mean.2001-2005.nc 
do
    cdo -r seltimestep,5,6,7,8,9,10 $file ${file%.nc}.MJJASO.nc
    cdo -r seltimestep,1,2,3,4,11,12 $file ${file%.nc}.NDJFMA.nc
done

#=================================================== done

        #=================================================== move
        mkdir pprcmdata
        mv RAD.all.200?.nc pprcmdata/
        mv SRF.all.200?.nc pprcmdata/
        mv $NewTag.???.all.mon.mean.2001-2005.nc pprcmdata/
        ln -sf $(pwd)/pprcmdata/$NewTag.???.all.mon.mean.2001-2005.nc ./
        mv $NewTag.???.mon.mean.2001-2005.nc pprcmdata/
        mv $NewTag.???.ymon.mean.2001-2005.nc pprcmdata/
        mv $NewTag.???.ymon.mean.2001-2005.MJJASO.nc pprcmdata/
        mv $NewTag.???.ymon.mean.2001-2005.NDJFMA.nc pprcmdata/
        #=================================================== done
