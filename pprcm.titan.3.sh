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
#  REQUIREMENTS: ---  ifunctions,cdo2, awk, grads, 
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


#=================================================== Peng:
#Secondly, I study the two seasonal mean for all the parameters for CCM and RRTM. You could also calculate it so that the data size will reduce too.
#At TOA: LWN (net LW) and SWN at clear sky and all sky condition;(RTL, RSNT, RTNLCL, RTNSCL in my version)
#At surface: LWN, SWN, LW (RSNL, RSNS, RSDL in my version)
#2 meter Temperature, precipitation, total cloud cover;(TAS, PR, CLT in my version)
#and because surface albedo is calculated as (1-SWN/downward surface SW), so I think you also need to save the parameter 'downward surface SW' (RSDS in my version)
#=================================================== Peng.

# Define the variables to be select, calculate & plot
############################################################
namelist=("RAD" "STS") 			# DO NOT change the order !!
varlist=("cl" "mask,pr,prmax,tas")
#:TODO:03/13/2014 08:32:58 AM RET:Tang: make sure no varibles with the same name
outname=("rad" "sts") 			# output file name: $prefix.$outname.out.nc
plotvars=("pr" "tas")  			# the variables to be ploted
sta_vars=( "pr" "tas" ) 		# variables to be analyzed, 

OBS_DATA=/worktmp2/RegCM_DATA/OBSDATA/

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
	#dir=${DefaultDir##/*/}  # :TODO:03/13/2014 08:21:33 AM RET:Tang: 
	dir=$(echo $DefaultDir | awk -F "/" '{print $(NF-1)}')

	#prefix=${88:-$dir}  # :TODO:03/13/2014 09:15:38 AM RET:Tang: default
	prefix="Reu"


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
### select the variables
####################################
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
while [ $i -lt ${#namelist[*]} ]
do
	tag=${namelist[$i]}

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
    cdo shifttime,-1m second.mois.$tag.nc $NewTag.$tag.all.mon.mean.2001-2005.nc

done








#=================================================== clean up
for tag in SRF RAD 
do
    
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








	for file in $(ls *$name.????????00.nc 2>&- )
	do
		echo "================" $file
		cdo2 -b 64 selvar,${varlist[$i]} $file ${outname[$i]}.$file.temp 2>&-
	done
	cdo2 -b 64 mergetime ${outname[$i]}*$name*.temp ${outname[$i]}.all.nc
	cdo2 -b 64 -r ymonmean ${outname[$i]}.all.nc ${outname[$i]}.all.nc.temp

	#ncpdq ${outname[$i]}.all.nc.temp $prefix.${outname[$i]}.out.nc 2>&-
	if [ $(ls $prefix.${outname[$i]}.out.nc 2>&- | wc -l ) -lt 1 ];then  # maybe no ncpdq command
		cp ${outname[$i]}.all.nc.temp $prefix.${outname[$i]}.out.nc 
#echo " can not run ncpdq, so NO add_offset, NO missing_value"
		echo "leave the outpuf file unpacked..."
	fi
	if [ ${namelist[$i]} = "STS" ]; then stsname=${outname[$i]}; fi
	GrADSNcPrepare $prefix.${outname[$i]}.out.nc 2>&-
	rm *.temp* 2>&- 
	((i++))
done
 # :TODO:03/10/2014 22:50:01 RET:Tang: 
#=================================================== clean
rm *.all.nc *.nc.temp 2>&-
echo "========== DONE ============"
ls -lh $prefix.*out.nc
fi

#############################################
### 	calculate MEAN, COR, BIAS, RMSE     
#############################################
#
#
#
####################################
####  PLOT with GrADS
####################################

