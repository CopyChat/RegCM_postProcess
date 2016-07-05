#!/bin/bash - 
#===============================================================================
#
#          FILE: getvar.sh
# 
#         USAGE: ./getvar.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Tang (Tang), tangchao90908@sina.com
#  ORGANIZATION: KLA
#       CREATED: 09/09/2014 11:40:15 AM RET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
source /labos/le2p/ctang/Shell/functions.sh


#=================================================== 

	DIR=/worktmp2/RegCM_DATA/Modeling/EIN15

	i=1
	for dir in EIN15
	do
		for rad in RRTM CCM
		do
			for conv in GE EE GG EG TT 
			do
				for moisture in SUBEX Micro
				do
					for pbl in Holtslag UW
					do
						namelist=${dir}_${rad}_${conv}_${moisture}_${pbl}_BATS_Zeng_2001-2005.in
						output=${i}_output_${dir}_${rad}_${conv}_${moisture}_${pbl}_BATS_Zeng
						runlog=runlog.$namelist
						pbs=$namelist.pbs
						#mv $DIR/$output/ ${i}_$output
						

						color 1 7 "---------------------------------------------------$i----------------"
						cd $DIR/$output

#						for file in $(ls ${i}_???.all.200?.nc)
#						do
#							a=$(cdo2 -r showtimestamp $file | grep "2003-01-01T00:00:00")
#							if [ $(echo $a | awk '{print NF}') = 13 ];then
#								color -n 7 1 "got the file ";color -n 1 7 " $file " ;color -n 1 7 " in model: "; color 7 1 " $i "
#								color 2 5 "eval echo $a"
#								cdo2 -r seltimestep,2,3,4,5,6,7,8,9,10,11,12,13 $file $file.temp
#								mv $file $file.backup
#								mv $file.temp $file
#								cdo2 -r shifttime,-1month $file sft.$file
#							fi
#
#							cdo2 -r shifttime,-1month $file sft.$file
#
#						done
						
						cd $DIR/$output

#=================================================== mon.mean
#							rm $i.RAD.mon.mean.2001-2005.selvar.nc
						
							 cdo2 -r selvar,clt,rsns,rsnscl,rsnl,rsnlcl,rts,rtl,rtnlcl,rsnt $i.RAD.mon.mean.2001-2005.nc $i.RAD.mon.mean.2001-2005.selvar.nc 
							 #cdo2 -r selvar,tas,pr $i.SRF.mon.mean.2001-2005.nc $i.SRF.mon.mean.2001-2005.selvar.nc
#=================================================== 
						cd $DIR/$output

						#rm $i.RAD.ymon.mean.2001-2005.nc
		cdo2 -r ymonmean $i.RAD.mon.mean.2001-2005.selvar.nc $i.RAD.ymon.mean.2001-2005.nc

#						rm $i.RAD.ymon.mean.2001-2005.MJJASO.nc
#						rm $i.RAD.ymon.mean.2001-2005.NDJFMA.nc
	 for name in RAD 
	 do
		 echo "cdo2 -r seltimestep,5,6,7,8,9,10 $i.$name.ymon.mean.nc ${i}.$name.ymon.mean.2001-2005.MJJASO.nc"
		 echo "cdo2 -r seltimestep,1,2,3,4,11,12 $i.$name.ymon.mean..nc $i.$name.ymon.mean.2001-2005.NDJFMA.nc"
		 cdo2 -r seltimestep,5,6,7,8,9,10 $i.$name.ymon.mean.2001-2005.nc ${i}.$name.ymon.mean.2001-2005.MJJASO.nc
		 cdo2 -r seltimestep,1,2,3,4,11,12 $i.$name.ymon.mean.2001-2005.nc $i.$name.ymon.mean.2001-2005.NDJFMA.nc
	 done
#=================================================== 
						cd $DIR


						((i++))
					done
				done
			done
		done
	done

