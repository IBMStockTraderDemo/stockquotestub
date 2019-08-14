#!/bin/bash


# Dectivate the stock quote virtual service 
# This is done by re-setting the portfolio service to call the real service
#
# Expects the following parameters for the virtual service to be passed in as the following parameters string:
#
#    -n namespace: <k8s namespace in which service is running>
#    -s servicename: <k8s service name>
#    -h host: <external IP address for accessing the service>
#
# It is assumed that other necessary  can be retreived from acceing
# the virtaul servuce definition in kubernetes

#
# Parse the Parameters
#
TMPFILE=_saved_url

help()
{
  echo 'deactivatestub.sh PARAMS ...  '
  echo '-n namespace the target namespace'
  echo '-s servive name for the servivce to be actvated in the namespace'
  echo '-o host address for an external entry (e.g. NodePort) for the cluster'
  echo '-h this message. Help message'
  exit 1
}

while getopts n:s:o:h option
do
  case "${option}"
  in
    n) NAMESPACE=${OPTARG};;
    s) SERVICENAME=${OPTARG};;
    o) HOST=${OPTARG};;
    h)
      help
      ;;
    :)
      echo "option $OPTARG needs a value"
      help
      ;;
    \?)
      echo "$OPTARG : invalid option"
      help
      ;;
  esac
done

if [ -z $NAMESPACE ]
then
  echo "Missing namespace (option -n)"
  help
fi
if [ -z $SERVICENAME ]
then
  echo "Missing service name (option -s)"
  help
fi
if [ -z $HOST ]
then
  echo "Missing host (option -o)"
  help
fi

#
# Get the config map for servces in stock trader
# well will patch this map to point to the virtual service and then restart the components that use the 
# service
#
CMAP=$(oc get --no-headers=true cm -n $NAMESPACE -o name | awk -F "/" '{print $2}' | grep config)
if [ -z $CMAP ]
then
  echo Configuration map cannot be found
  help
fi
echo Updating the configuration map $CMAP to substitute Original Service for stockQuote.url

OLDURL=$(cat $TMPFILE)

echo Patching congifmap $CMAP to set stockQuote.url to $OLDURL
oc patch cm st1-4-config --patch '{"data": {"stockQuote.url": "'$OLDURL'"}}'

echo Restarting Portfolio pods to pick up updated configmap with original stock-quote service
oc delete po -l app=portfolio -n $NAMESPACE