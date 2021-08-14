# aws related
aws-s3du() {
    aws s3 ls --summarize --human-readable --recursive s3://$1/ | tail -n 3
}

aws-s3size() {
    bucket=$1
    region=${2:-"us-west-2"}
    now=$(date +%s)
    aws cloudwatch get-metric-statistics --namespace AWS/S3 \
    --start-time "$(echo "$now - 172800" | bc)" \
    --end-time "$now" \
    --period 86400 \
    --statistics Average \
    --region $region \
    --metric-name BucketSizeBytes \
    --dimensions Name=BucketName,Value="$bucket" Name=StorageType,Value=StandardStorage \
    --query 'Datapoints[0].Average'

}

aws-echo() {
    echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
    echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
    echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
    echo "export AWS_REGION=$AWS_DEFAULT_REGION"
}

aws-export() {
    PROFILE=${1:-"default"}
    export AWS_ACCESS_KEY_ID=$(aws --profile $PROFILE configure get aws_access_key_id)
    export AWS_SECRET_ACCESS_KEY=$(aws --profile $PROFILE configure get aws_secret_access_key)
    export AWS_DEFAULT_REGION=$(aws --profile $PROFILE configure get region)
    export AWS_REGION=$(aws --profile $PROFILE configure get region)
    aws-echo
}

aws-rds-list() {
    aws rds describe-db-instances --query 'DBInstances[*].Endpoint.Address' | jq -r '.[]'
}

alias aws-profiles="cat ~/.aws/credentials | grep -o '\[[^]]*\]' | sed 's@\[@@;s@\]@@'"
export AWS_PAGER=""
