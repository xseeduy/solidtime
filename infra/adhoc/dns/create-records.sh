#!/bin/bash
# create-records.sh
# Script de referencia: crea el CNAME track.xseed.com.uy en Route53.
#
# NOTA: Actualmente NO se usa porque el dominio xseed.com.uy se gestiona
# desde el proveedor UY, no desde Route53. Este script queda como referencia
# para el futuro si se decide delegar la zona a Route53.
#
# Uso:
#   export ALB_DNS_NAME="<alb-dns-name>.us-east-1.elb.amazonaws.com"
#   ./create-records.sh

set -euo pipefail

AWS_PROFILE="${AWS_PROFILE:-xseed}"
HOSTED_ZONE_NAME="xseed.com.uy"
ALB_DNS_NAME="${ALB_DNS_NAME:-}"

if [ -z "$ALB_DNS_NAME" ]; then
  echo "ERROR: Debes definir ALB_DNS_NAME"
  echo "  export ALB_DNS_NAME=\"<alb-dns>.us-east-1.elb.amazonaws.com\""
  exit 1
fi

ZONE_ID=$(aws route53 list-hosted-zones \
  --profile "$AWS_PROFILE" \
  --query "HostedZones[?Name==\`${HOSTED_ZONE_NAME}.\`].Id" \
  --output text | sed 's|/hostedzone/||')

if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" == "None" ]; then
  echo "ERROR: No se encontró la hosted zone '$HOSTED_ZONE_NAME' en Route53"
  exit 1
fi

echo "Hosted Zone ID: $ZONE_ID"
echo "ALB DNS: $ALB_DNS_NAME"
echo "Creando registro CNAME track.xseed.com.uy..."

cat > /tmp/dns-records.json << EOF
{
  "Comment": "CNAME track.xseed.com.uy - creado $(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "track.xseed.com.uy",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{ "Value": "${ALB_DNS_NAME}" }]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets \
  --profile "$AWS_PROFILE" \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch file:///tmp/dns-records.json

echo "✅ Registro DNS creado:"
echo "  track.xseed.com.uy → ${ALB_DNS_NAME}"
