#!/bin/bash - 
#===============================================================================
#
#          FILE: findvar.sh
# 
#USAGE="./findvar.sh  "
# 
#   DESCRIPTION:  
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Tang (Tang), chao.tang.1@gmail.com
#  ORGANIZATION: le2p
#       CREATED: 02/05/2015 07:12:33 PM CET
#      REVISION:  ---
#===============================================================================

#set -o nounset                             # Treat unset variables as an error

#=================================================== 
cd $(pwd)

DIR=/home/esp-shared-a/Observations/
cd $DIR


for model in $(ls)
do
    echo model is $model
    echo $DIR/$model/
    cd $DIR/$model/
    for file in $(ls *.nc)
    do
        #echo $DIR/$model/$file $(eval ncdump -h $DIR/$model/$file | grep "long_name" | egrep -v "height|latitude|time|longitude" | grep "cloud" ) 
        echo $DIR/$model/$file $(eval ncdump -h $DIR/$model/$file | grep "long_name" | egrep -v "height|latitude|time|longitude" | grep "cloud") >> ~/cloud/list.$model
    done 
    #sort ~/cloud/list.$model | uniq >> ~/cloud/list.$model.uniq

done

