#! /bin/bash
# Program to determine the available diskspace on an ESXi Server
# ARG1: diskname
# ARG2: threshold warning
# ARG2: threshold critical
# Threshold values are expected in GB

# IP from esxi
IP_ESXI=172.26.20.50

# Nagios Plugin States
OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3

#---------------------------------------------------------------------------------------------------
DISK=$1
THRESHOLD_WARN=$2
THRESHOLD_CRIT=$3

#---------------------------------------------------------------------------------------------------
# Olf 140127
#DISK_ID="$(ssh $IP_ESXI 'ls -l /vmfs/volumes' | grep $DISK | awk '{print $11}')"

#---------------------------------------------------------------------------------------------------
# get the available space from the disk
# Olf 140127
#SPACE="$(ssh $IP_ESXI 'df' | grep $DISK_ID | awk '{printf "%.0f",$4}')"
SPACE="$(ssh $IP_ESXI 'df' | grep $DISK | awk '{printf "%.0f",$4}')"

# recalculate disksize in GB (from Byte)
SPACE=`expr $SPACE \/ 1073741824`

if [[ "$SPACE" -eq "" ]];then
  echo "Couldn´t determine diskspace"
  exit $UNKNOWN
fi
#---------------------------------------------------------------------------------------------------
# set status
STATUS=$OK
if [ "$SPACE" -lt "$THRESHOLD_WARN" ]
then
  STATUS=$WARNING
fi
if [ "$SPACE" -lt "$THRESHOLD_CRIT" ]
then
  STATUS=$CRITICAL
fi

#---------------------------------------------------------------------------------------------------
# output
POSTFIX="GB"

# if [ "$SPACE" -gt "1024" ]
# then
  # SPACE=`expr $SPACE \/ 1024` | awk '{printf "%.2f", $1}'
  # POSTFIX="TB"
# fi

if [ "$STATUS" == "$WARNING" ]
then
  echo "WARNING: diskspace on $DISK: $SPACE $POSTFIX"
fi
if [ "$STATUS" == "$CRITICAL" ]
then
  echo "CRITICAL: diskspace on $DISK: $SPACE $POSTFIX"
fi
if [ "$STATUS" == "$OK" ]
then
  echo "OK: diskspace on $DISK: $SPACE $POSTFIX"
fi

exit $STATUS
