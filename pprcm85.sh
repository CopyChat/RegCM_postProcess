#!/bin/bash - 
#===============================================================================
#
#          FILE: pprcm2.sh
# 
         USAGE=" ./pprcm2.sh [OPTION...] [+ RegCM outpur directory]"
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
#  ORGANIZATION: KLA, le2p, La Reunion, France
#       CREATED: 02/15/2014 09:52:53 RET
#      REVISION:  ---
#===============================================================================
#set -o nounset                              # Treat unset variables as an error
export PATH=/usr/local/bin/:$PATH 
NewTag="GFDL_hist"
YEAR1="1996"
YEAR2="2005"

Dir=$(pwd)

####################################
### monthly mean & merge
####################################
#=================================================== clean up
for tag in SRF RAD ATM STS
do
    for year in $(seq -s " " ${YEAR1} ${YEAR2})
    do
    	nof=$(eval ls *$tag.$year??0100.nc 2>&- | wc -l)
    	echo "----------------------------------"
    	echo " there are $nof $tag files in $year"
    	echo "----------------------------------\n"

    	for file in $(eval ls *$tag.$year??0100.nc 2>&-)
    	do
            echo "================ $file === in $(eval date)"
    		echo "cdo timmean $file $file.timmean.temp 2>&-  # timmean for monthly file"
    		cdo timmean $file $file.timmean.$year.temp 2>&-  # timmean for monthly file
            
            # STS is already data
            if [ "$tag" = "STS" ];then
                cdo -r fldmean $file $file.day.fldmean.$year.temp
            else

                # statistics:
                echo " ------ \n calculate statistics: ------ \n"
                cdo -r dayvar $file $file.$tag.dayvar.$year.temp
                cdo -r daystd $file $file.$tag.daystd.$year.temp

                # means
                echo " ------ \n calculate daymean: ------ \n"
                cdo -r daymean $file $file.daymean.$year.temp 2>&-
                echo " ------ \n calculate fldmean: ------ \n"
                cdo -r fldmean $file.daymean.$year.temp $file.day.fldmean.$year.temp
            fi
    	done # loop for month

        # for statistics
        echo " ------ \n mergetime statistics: ------ \n"
        cdo mergetime *$tag.daystd.$year.temp $tag.daystd.$year.nc.temp
        cdo mergetime *$tag.dayvar.$year.temp $tag.dayvar.$year.nc.temp

        # for temperal mean
        echo " ------ \n mergetime temperal means: ------ \n"
		echo "cdo mergetime *$tag.*timmean.$year.temp $tag.all.$year.nc.temp"
		cdo mergetime *$tag.*timmean.$year.temp $tag.all.$year.nc.temp

        # for ydaymean
        cdo mergetime *$tag.*daymean.$year.temp $tag.all.day.$year.nc.temp

        # for fldmean 
        echo " ------ \n mergetime fldmeans: ------ \n"
        echo "cdo mergetime *$tag.*fldmean.$year.temp $tag.all.day.fldmean.$year.temp"
        cdo mergetime *$tag.*fldmean.$year.temp $tag.all.day.fldmean.$year.temp

    done # loop for year 
    

    # for statistics
    if [ "$tag" = "STS" ];then
        echo "\nSTS is already daily, no daily statistics.\n"
    else
        echo " ------ \n time is shifted after cdo process, shift back: ------ \n"
        echo " ------ \n shift back: statistics ------ \n"
        cdo mergetime *$tag.dayvar.????.temp second.mois.$tag.dayvar.nc
        cdo shifttime,-1m second.mois.$tag.dayvar.nc $NewTag.$tag.dayvar.${YEAR1}-${YEAR2}.nc

        cdo mergetime *$tag.daystd.????.temp second.mois.$tag.daystd.nc
        cdo shifttime,-1m second.mois.$tag.daystd.nc $NewTag.$tag.daystd.${YEAR1}-${YEAR2}.nc
    fi 

    # for ydaymean
    cdo mergetime $tag.all.day.????.nc.temp second.mois.$tag.all.daymean.nc
    cdo shifttime,-1m second.mois.$tag.all.daymean.nc $NewTag.$tag.all.daymean.${YEAR1}-${YEAR2}.nc

    # for temperal mean
    cdo mergetime $tag.all.????.nc.temp second.mois.$tag.nc
    cdo shifttime,-1m second.mois.$tag.nc $NewTag.$tag.all.mon.mean.${YEAR1}-${YEAR2}.nc

    # for fldmean 
    cdo mergetime $tag.all.day.fldmean.????.temp second.mois.$tag.all.day.fldmean.nc
    cdo shifttime,-1m second.mois.$tag.all.day.fldmean.nc $NewTag.$tag.all.day.fldmean.${YEAR1}-${YEAR2}.nc


    # clean up, only *.nc left
    rm *temp 2>&-

done # loop for tag

####################################
### selection, monthly mean & merge
####################################

radfile="$NewTag.RAD.all.mon.mean.${YEAR1}-${YEAR2}.nc"
srffile="$NewTag.SRF.all.mon.mean.${YEAR1}-${YEAR2}.nc"
atmfile="$NewTag.ATM.all.mon.mean.${YEAR1}-${YEAR2}.nc"
stsfile="$NewTag.STS.all.mon.mean.${YEAR1}-${YEAR2}.nc"

#--------------------------------------------------- montly fldmean 

echo ------------------- to save monthly fldmean in ATM RAD SRF STS  ------------
cdo -r fldmean $radfile $NewTag.RAD.all.mon.fldmean.${YEAR1}-${YEAR2}.nc
cdo -r fldmean $srffile $NewTag.SRF.all.mon.fldmean.${YEAR1}-${YEAR2}.nc
cdo -r fldmean $atmfile $NewTag.ATM.all.mon.fldmean.${YEAR1}-${YEAR2}.nc
cdo -r fldmean $stsfile $NewTag.STS.all.mon.fldmean.${YEAR1}-${YEAR2}.nc

#=================================================== select var

echo ------------------- to select vars for only RAD SRF  -----------------------

echo "cdo -r selvar,rsns,rsnl,rsnscl,rtnlcl,rsnlcl,rts,rsnt,clt,rtl,dlwssr,dlwssrd,dswssr,dswssrd,cl,clw $radfile $NewTag.RAD.mon.mean.${YEAR1}-${YEAR2}.nc "
cdo -r selvar,rsns,rsnl,rsnscl,rtnlcl,rsnlcl,rts,rsnt,clt,rtl,dlwssr,dlwssrd,dswssr,dswssrd,cl,clw $radfile $NewTag.RAD.mon.mean.${YEAR1}-${YEAR2}.nc 

echo "cdo -r selvar,pr,evspsbl,hfss,rsdl,rsds,prc,aldirs,aldifs,tas $srffile $NewTag.SRF.mon.mean.${YEAR1}-${YEAR2}.nc "
cdo -r selvar,pr,evspsbl,hfss,rsdl,rsds,prc,aldirs,aldifs,tas $srffile $NewTag.SRF.mon.mean.${YEAR1}-${YEAR2}.nc 

#=================================================== ymonmean
echo ------------------- to select vars for only RAD SRF: multiyear monthly mean -----------------------

echo "cdo -r ymonmean $NewTag.SRF.mon.mean.${YEAR1}-${YEAR2}.nc $NewTag.SRF.ymon.mean.${YEAR1}-${YEAR2}.nc "
cdo -r ymonmean $NewTag.SRF.mon.mean.${YEAR1}-${YEAR2}.nc $NewTag.SRF.ymon.mean.${YEAR1}-${YEAR2}.nc 

echo "cdo -r ymonmean $NewTag.RAD.mon.mean.${YEAR1}-${YEAR2}.nc $NewTag.RAD.ymon.mean.${YEAR1}-${YEAR2}.nc "
cdo -r ymonmean $NewTag.RAD.mon.mean.${YEAR1}-${YEAR2}.nc $NewTag.RAD.ymon.mean.${YEAR1}-${YEAR2}.nc 

echo ------------------- to select vars for only RAD SRF: multilyear seasonal mean -----------------------

for file in $NewTag.SRF.ymon.mean.${YEAR1}-${YEAR2}.nc $NewTag.RAD.ymon.mean.${YEAR1}-${YEAR2}.nc 
do
    echo "cdo -r seltimestep,5,6,7,8,9,10 $file ${file%.nc}.MJJASO.nc"
    cdo -r seltimestep,5,6,7,8,9,10 $file ${file%.nc}.MJJASO.nc

    echo "cdo -r seltimestep,1,2,3,4,11,12 $file ${file%.nc}.NDJFMA.nc"
    cdo -r seltimestep,1,2,3,4,11,12 $file ${file%.nc}.NDJFMA.nc
done
        
echo "=========================== selection done ==============================="
#=================================================== done



        #=================================================== move
        mkdir -p pprcmdata/monthly

        # all variables monthly mean data
        mv $NewTag.???.all.mon.mean.${YEAR1}-${YEAR2}.nc pprcmdata/monthly/
        ln -sf $(pwd)/pprcmdata/monthly/$NewTag.???.all.mon.mean.${YEAR1}-${YEAR2}.nc ./

        # selected variables monthly mean data
        mv $NewTag.???.mon.mean.${YEAR1}-${YEAR2}.nc pprcmdata/monthly/
        mv $NewTag.???.ymon.mean.${YEAR1}-${YEAR2}.nc pprcmdata/monthly/

        # selected variables seasonal mean data
        mv $NewTag.???.ymon.mean.${YEAR1}-${YEAR2}.MJJASO.nc pprcmdata/monthly/
        mv $NewTag.???.ymon.mean.${YEAR1}-${YEAR2}.NDJFMA.nc pprcmdata/monthly/

        echo "=========================== move done ==============================="




#==================================== to save daily data samples
cd $Dir; mkdir pprcmdata/daily 


# for RAD ATM

echo ------------------- to save RAD ATM in 1996 2000 2005 ------------
for tag in RAD ATM
do
    for year in 1996 2005
    do
        mv SWIO_$tag.$year????00.nc pprcmdata/daily
        ln -sf $Dir/pprcmdata/daily/SWIO_$tag.$year????00.nc $Dir/
    done
done

# For SRF STS

echo ------------------- to save all: SRF STS clm --------------------

for tag in SRF STS clm
do
    mv SWIO*$tag.*.nc pprcmdata/daily
    ln -sf $Dir/pprcmdata/daily/SWIO*$tag* $Dir/
done

echo ------------------- to save variables for bias correction: RAD STS--------------------


echo " to be added later , by ctang"


for tag in ATM RAD STS SRF
do
    mv $NewTag.$tag.all.daymean.${YEAR1}-${YEAR2}.nc $Dir/pprcmdata/daily/
    ln -sf $Dir/pprcmdata/daily/$NewTag.$tag.all.daymean.${YEAR1}-${YEAR2}.nc $Dir/
done


#==================================== to save fldmean
echo ------------------- to save all: fldmean --------------------
mkdir pprcmdata/fldmean
mv *.all.day.fldmean.${YEAR1}-${YEAR2}.nc pprcmdata/fldmean
mv *.all.mon.fldmean.${YEAR1}-${YEAR2}.nc pprcmdata/fldmean


#==================================== to save statistics
echo ------------------- to save all: statistics--------------------


mkdir pprcmdata/statistics

mv $NewTag.???.daystd.${YEAR1}-${YEAR2}.nc pprcmdata/statistics
mv $NewTag.???.dayvar.${YEAR1}-${YEAR2}.nc pprcmdata/statistics

#=================================================== SAV
echo ------------------- to save all SAV --------------------
mkdir pprcmdata/SAV

mv *SAV* pprcmdata/SAV/
ln -sf $Dir/pprcmdata/SAV/*SAV* $Dir/


#=================================================== done

echo "=========================== save done ==============================="
