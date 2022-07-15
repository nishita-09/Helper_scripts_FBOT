SERVICE_SET=hlo
SERVICE_LIST="hlo"
SPINNAKER_REPO="/Users/npattanayak/tutorial-environment/spinnaker"
FIRE_ORCHESTRATION_VMFS=$2
cd $FIRE_ORCHESTRATION_VMFS

while IFS=, read -r FI FD; do 
   echo "Processing for FI: $FI, FD: $FD"; 
   python3 -m vmf_generator.vmf_generator --falcon-instance $FI --functional-domain $FD --vmf-service-set $SERVICE_SET --service-list $SERVICE_LIST --add-change-template 36418947 --spinnaker-repo $SPINNAKER_REPO
done < $1