#!/bin/bash

#removes secrets manifest file if already available
rm secrets.yaml

echo "
apiVersion: v1
kind: Secret
metadata:
  name: metricbeat-secrets
  namespace: kube-system
data:" >> secrets.yaml

for file in CREDS/*; do 
    if [ -f "$file" ]; then 
      if [[ $file != *".secret" ]]; then
        name=${file#CREDS/}
        echo "  $name: \"$(cat $file | base64)\"" >> secrets.yaml
      fi
    fi 
done