#!/bin/bash

#
# Activate the stock quote virtual service 
# This is done by re-targeting the portfolio service to call the stub
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
  echo 'activatestub.sh PARAMS ...  '
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
echo Updating the configuration map $CMAP to substitute Virtual Service for stockQuote.url

#
# Get the current URL name in the config map for the stock-quote-service
#
CURRENTURL=$(oc get cm $CMAP -o jsonpath='{.data.stockQuote\.url}')

#
# Construct the new url to the virtual service stub
#
PORT=$(oc get svc $SERVICENAME -n $NAMESPACE -o jsonpath='{.spec.ports[?(@.name == "http")].port}')
if [ -z PORT ]
then
    echo Could not get port number from service $SERVICENAME
    help
fi
NEWURL=http://$SERVICENAME:$PORT/stock-quote

#
# detemine of the stub is already active
#
if [ $CURRENTURL ==  $NEWURL ]
then
  echo Virtual Service $SERVICENAME is already active
  exit 0
fi

#
# Save the currenlt URL from the config map so that it can be restored when deactivating the stub
#
echo $CURRENTURL >$TMPFILE
echo Saved original $CMAP stockQuote.url value: $(cat $TMPFILE) in $TMPFILE

echo Patching congifmap $CMAP to set stockQuote.url to $NEWURL
oc patch cm st1-4-config --patch '{"data": {"stockQuote.url": "'$NEWURL'"}}'

echo Restarting Portfolio pods to pick up updated configmap with quote virtual service
oc delete po -l app=portfolio -n $NAMESPACE

