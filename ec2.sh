ZONE_ID="Z01272351LK3NIV2TJGOQ"
DOMAIN="devtb.online"
SG_NAME="allow-all"

create_ec2() {
  echo -e '#!/bin/bash' >/tmp/user-data
  echo -e "\nset-hostname ${COMPONENT}" >>/tmp/user-data
  PRIVATE_IP=$(aws ec2 run-instances \
      --image-id "${AMI_ID}" \
      --instance-type t2.micro \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}, {Key=Monitor,Value=yes}]" \
      --security-group-ids "${SG_ID}" \
      --user-data file:///tmp/user-data \
      | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

  if  sed -e "s/IPADDRESS/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}/" -e "s/DOMAIN/${DOMAIN}/" route53.json >/tmp/record.json
      aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json 2>/dev/null
  then
    echo "Server Created - SUCCESS - DNS RECORD - ${COMPONENT}.${DOMAIN}"
  else
    echo "Server Created - FAILED - DNS RECORD - ${COMPONENT}.${DOMAIN}"
    exit 1
  fi
}

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-8-DevOps-Practice" | jq '.Images[].ImageId' | sed -e 's/"//g')
if [ -z "${AMI_ID}" ]; then
  echo "AMI_ID not found"
  exit 1
fi

SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=${SG_NAME}" | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')
if [ -z "${SG_ID}" ]; then
  echo "Given Security Group does not exit"
  exit 1
fi

for component in catalogue cart user shipping frontend payment mongodb mysql rabbitmq redis dispatch; do
  COMPONENT="${component}"
  create_ec2
done

PUBLIC_IP=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicIpAddress]" --filters Name=tag:Name,Values=frontend --output text)

iliyas() {
  sed -e "s/IPADDRESS/${PUBLIC_IP}/" -e "s/DOMAIN/${DOMAIN}/" route53-main.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json 2>/dev/null
}

this() {
  "echo this"
}