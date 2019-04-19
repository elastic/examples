# Create an Elastic Cloud deployment

Visit https://cloud.elastic.co and sign up for a free trial, or sign in to your account.  Create a deployment.

Make sure that you take note of the CLOUD ID and Elastic Password.

# Set the credentials
There are two files to edit to create a k8s secret when you are connecting to the managed Elasticsearch Service in Elastic Cloud.  The files are: 

1. ELASTIC_CLOUD_AUTH
1. ELASTIC_CLOUD_ID

Set these with the information provided to you from the Elasticsearch Service console when you created the deployment.  Here are some examples:

## ELASTIC_CLOUD_ID
```
devk8s:ABC123def456ghi789jkl123mno456pqr789stu123vwx456yza789bcd012efg345hijj678klm901nop345zEwOTJjMTc5YWQ0YzQ5OThlN2U5MjAwYTg4NTIzZQ==
```

## ELASTIC_CLOUD_AUTH
Just the username, a colon (`:`), and the password, no whitespace or quotes:
```
elastic:VFxJJf9Tjwer90wnfTghsn8w
```

# Edit the required files:
```
vi ELASTIC_CLOUD_ID
vi ELASTIC_CLOUD_AUTH
```
# Create a Kubernetes secret
This command creates a secret in the Kubernetes system level namespace (kube-system) based on the files you just edited:

    kubectl create secret generic dynamic-logging \
      --from-file=./ELASTIC_CLOUD_ID \
      --from-file=./ELASTIC_CLOUD_AUTH \
      --namespace=kube-system

# Continue with the install
Open [README-Main.md](README-Main.md) and complete the tutorial
