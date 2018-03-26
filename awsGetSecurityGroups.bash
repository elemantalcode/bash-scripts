#!/bin/bash
# awsdGetSecurityGroups v0.1a : List all AWS security groups : https://github.com/elemantalcode/bash-scripts

# Requires AWS-CLI to be configured correctly and assumes we have multiple profiles set up

# Space separated list of profile
PROFILES="sandbox dev test production"

# Function to extract rules from Security Group
function getSg() {
  CHECK="IpPermissionsEgress"
  [ "$1" == "In" ] && CHECK="IpPermissions"
    RULE=$( aws ec2 describe-security-groups --region "$REGION" --profile "$PROFILE" --group-ids "$GID" --query \
      "SecurityGroups[*].${CHECK}[].{From:FromPort,To:ToPort,Range:IpRanges[*].CidrIp}" \
      | jq -r '.[] | "Port: " + (.From|tostring) + "-" + (.To|tostring) + " IP: " + .Range[]' )
    ipOrSg "$1"
}

# IP Range or attached to Security Group?
function ipOrSg (){
  CHECK="IpPermissionsEgress"
  DIRECTION="<="
  [ "$1" == "In" ] && CHECK="IpPermissions" && DIRECTION="=>"
  if [ "$RULE" == "" ] ; then
    RULE=$( aws ec2 describe-security-groups --region "$REGION" --profile "$PROFILE" --group-ids "$GID" --query \
      "SecurityGroups[*].${CHECK}[].{From:FromPort,To:ToPort,Range:UserIdGroupPairs[*].GroupId}" \
      | jq -r '.[] | "Port: " + (.From|tostring) + "-" + (.To|tostring) + " IP: " + .Range[]' )
    [ "$RULE" == "" ] && RULE="        $DIRECTION No Rule Defined"
  fi
}

# For every PROFILE get every REGION
for PROFILE in ${PROFILES[*]}; do
  REGIONS=$( aws ec2 describe-regions --region us-west-1 --profile "$PROFILE" | jq -r '.[] | .[].RegionName' )

  # For every REGION get the Security Groups
  echo "=> $PROFILE"
  for REGION in ${REGIONS[*]}; do
    echo "  => $REGION"
    aws ec2 describe-security-groups --region "$REGION" --profile "$PROFILE" \
      | jq -r '.SecurityGroups[] | .GroupId + ":" + .GroupName' | while IFS=: read -r GID NAME
      do
        # Print each security group
        echo "    => $GID $NAME"
          # First show ingress
          getSg "In"
          echo "$RULE" | sed -e 's/^Port/        => Port/g'

          # Also show Egress
          getSg "Out"
          echo "$RULE" | sed -e 's/^Port/        <= Port/g'
      done
  done
done
