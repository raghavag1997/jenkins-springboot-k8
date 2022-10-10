result=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq )
score=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].score)

echo $result
echo $score

if [ $score -gt 2 ]; then
       echo "Meeting with Secuirty Standadard"
else
       echo "Not Meeting"
fi;
