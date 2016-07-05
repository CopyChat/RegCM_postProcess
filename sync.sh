#!/bin/bash - 
#===============================================================================
#
#          FILE: rsync.sh
# 
USAGE=" ./rsync.sh  "
# 
#   DESCRIPTION:  
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Tang (Tang), chao.tang.1@gmail.com
#  ORGANIZATION: le2p
#       CREATED: 11/12/15 10:12:33 CET
#      REVISION:  ---
#===============================================================================

#set -o nounset                             # Treat unset variables as an error
shopt -s extglob 							# "shopt -u extglob" to turn it off
source ~/Shell/functions.sh      			# TANG's shell functions.sh

#=================================================== 
Dir="/Users/tang/climate/Modeling/ICTP"

for Model in Micro_GE_UW_RRTM.G651E0008 Emanless Grelmore Micro_GE_UW_RRTM.G71E0007 G71E0001 Micro_GE_UW_RRTM Reference Grelless Micro_GE_UW_RRTM.G61E001 
do
    color 1 7 "==================== $Model ==================="
    echo "rsync -arzhSPH ctang@argo:/home/netapp-clima-scratch/ctang/Modeling/$Model/*.in* $Dir/$Model"
    rsync -arzhSPH ctang@argo:/home/netapp-clima-scratch/ctang/Modeling/$Model/*.in* $Dir/$Model

    echo "rsync -arzhSPH ctang@argo:/home/netapp-clima-scratch/ctang/Modeling/$Model/output/pprcm2*  $Dir/$Model/output/"
    rsync -arzhSPH ctang@argo:/home/netapp-clima-scratch/ctang/Modeling/$Model/output/pprcmdata/pprcm*  $Dir/$Model/output/

    echo "rsync -arzhSPH ctang@argo:/home/netapp-clima-scratch/ctang/Modeling/$Model/output/pprcmdata/Micro*.nc  $Dir/$Model/output/"
    rsync -arzhSPH ctang@argo:/home/netapp-clima-scratch/ctang/Modeling/$Model/output/pprcmdata/Micro*.nc  $Dir/$Model/output/

done
