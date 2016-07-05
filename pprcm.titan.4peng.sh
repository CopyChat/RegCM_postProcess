#!/bin/bash - 
#===============================================================================
#
#          FILE: pprcm.sh
# 
         USAGE=" ./pprcm.sh [OPTION...] [+ RegCM outpur directory]"
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
#
#  REQUIREMENTS: ---  functions.sh, cdo2, awk, grads, 
# 					  GrADSNcPrepare in RegCM-4.3.5.6/bin
# 					  there is a tar file in ~/backup/pprcm.tar
# 					  mask.sh
#          BUGS: ---  no ncpdq command on titan, leave the ofile unpacked
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

shopt -s extglob 							# "shopt -u extglob" to turn it off
. ~/Shell/functions.sh      			# TANG's shell functions.sh

#=================================================== Peng:
#Secondly, I study the two seasonal mean for all the parameters for CCM and RRTM. You could also calculate it so that the data size will reduce too.
#At TOA: LWN (net LW) and SWN at clear sky and all sky condition;(RTL, RSNT, RTNLCL, RTNSCL in my version)
#At surface: LWN, SWN, LW (RSNL, RSNS, RSDL in my version)
#2 meter Temperature, precipitation, total cloud cover;(TAS, PR, CLT in my version)
#and because surface albedo is calculated as (1-SWN/downward surface SW), so I think you also need to save the parameter 'downward surface SW' (RSDS in my version)
#=================================================== Peng.

# Define the variables to be select, calculate & plot
############################################################
outputlist=("RAD" "SRF" ) 			# DO NOT change the corresponding order !!

#:TODO:03/13/2014 08:32:58 AM RET:Tang: make sure no varibles with the same name
varlist=(\
    "rsns,rsnl,rtnscl,rtnlcl,rsnt,clt,rtl"\  # RAD
    "pr,rsdl,rsds,tas"\ # SRF
        )


############################################################
# commander line arguments predefined:
plot=0;cal=0;select=0;monthly=0;ein=0;cross=0;land=0;ocean=0
#=================================================== 
while getopts ":pcsmxetlo" opt; do
	case $opt in 
		p) plot=1 ;;
		c) cal=1 ;;
		s) select=1 ;;
		m) monthly=1 ;;
		e) ein=1 ;;
		x) cross=1 ;;
		l) land=1 ; mask=land ;;
		o) ocean=1 ; mask=ocean ;;
		t) Test=1 ;;
		\?) echo $USAGE && exit 1
	esac
done
shift $(($OPTIND - 1))

#  if no option is given, then plot, calculate and make selections.
if [ $(( $plot + $cal + $select )) -eq 0 ]; then plot=1;cal=1;select=1; fi

if [ $cross -eq 1 ]; then ein=0; fi  # ERA-Interim options

echo "___________________________________________________________________"
color 1 7 " plot=$plot cal=$cal select=$select monthly=$monthly ein=$ein cross=$cross mask=$mask"
echo "~------------------------------------------------------------------"


#=================================================== 
Dir=${1:-.} 						 # default dir

if ! [ -e "$Dir" ] ; then
	echo $USAGE; echo "$Dir doesn't exist" ; exit 1
elif ! [ -d "$Dir" ]; then 
	echo $USAGE; echo "While, $Dir isn't a directory"; exit 1
else 

	cd $Dir; DefaultDir=$(pwd)
	#================================= default output file name
	prefix="Reu"

	#prefix=${88:-$dir}  # :TODO:03/13/2014 09:15:38 AM RET:Tang: default
	color 3 7 "output file :  $prefix.*.out.nc"
	echo "################################################"
	sleep 1
fi
#=================================================== 
# check is there're two vars has the same name

vsize1=${varlist[@]//,/ }  		# duplicate varnames
vsize2=$(tr ' ' '\n' <<< "${varlist[@]//,/ }" | sort -u | tr '\n' ' ')

if [ ${#vsize2} -lt ${#vsize1} ]; then
	echo "Attentiont: At least two vars have the same names!"
	echo "One variable name would be changed, Continue? (Yes/n)?"
	read answer
	if [ $answer = "Yes" ]; then : else exit 1; fi
fi
#===================================================

if [ "$Test" = "1" ]; then echo "-t for TEST!"; exit 1; fi
####################################
### to select the variables
####################################


# make monthly mean of all the variables

if [ $select -eq 1 ]; then
	#================================= test the directory
	if [ $(ls *S*.????????00.nc 2>&- | wc -l) -lt 1 ];then
		echo "SORRY, NO RegCM output file in $DefaultDir"
		echo $USAGE; exit 1
	fi
#=================================================== clean up
rm $prefix.*.out.nc *.all.nc *.nc.temp 2>&-
#=================================================== 

i=0
while [ $i -lt ${#outputlist[*]} ]
do
	tag=${outputlist[$i]}
    for year in $(seq -s " " 2001 2005)
    do
    	nof=$(eval ls *$tag.$year????00.nc 2>&- | wc -l)
    	echo "----------------------------------"
    	echo " there are $nof $tag files"
    	echo "----------------------------------"
	
        if [ $nof -lt 1 ];then ((i++));continue; fi

    	for file in $(eval ls *$tag.$year????00.nc 2>&-)
    	do
    		echo "================" $file
    		echo "cdo timmean $file $file.timmean.temp 2>&-  # timmean for monthly file"
    		cdo timmean $file $file.timmean.$year.temp 2>&-  # timmean for monthly file
    	done
		echo "cdo mergetime *$tag.*timmean.$year.temp $tag.all.nc"
		cdo mergetime *$tag.*timmean.$year.temp $tag.all.$year.nc
    done
    # time is shifted by cdo process, shift it back:
    cdo mergetime $tag.all.*.nc second.mois.$tag.nc
    cdo shifttime,-1m second.mois.$tag.nc $prefix.$tag.all.mon.mean.2001-2005.nc


    # to select var
    cdo -r selvar,${outputlist[$i]} $prefix.${outputlist[$i]}.all.mon.mean.2001-2005.nc \
        $prefix.${outputlist[$i]}.mon.mean.2001-2005.nc 
    # make ymonmean
    cdo -r ymonmean $prefix.${outputlist[$i]}.mon.mean.2001-2005.nc \
        $prefix.${outputlist[$i]}.ymon.mean.2001-2005.nc 
    # season
    cdo -r seltimestep,5,6,7,8,9,10 \
        $prefix.${outputlist[$i]}.ymon.mean.2001-2005.nc \
        $prefix.${outputlist[$i]}.ymon.mean.2001-2005.MJJASO.nc
    cdo -r seltimestep,1,2,3,4,11,12 \
        $prefix.${outputlist[$i]}.ymon.mean.2001-2005.nc \
        $prefix.${outputlist[$i]}.ymon.mean.2001-2005.NDJFMA.nc
done



#=================================================== clean up
rm *.nc.temp 2>&-
# :TODO:03/10/2014 22:50:01 RET:Tang: 

