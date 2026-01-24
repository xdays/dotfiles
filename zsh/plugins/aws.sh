# aws related
aws-s3du() {
    aws s3 ls --summarize --human-readable --recursive s3://$1/ | tail -n 3
}

aws-s3size() {
    bucket=$1
    region=${2:-"us-west-2"}
    start=$(date +"%Y-%m-%dT00:00:00" --date="2 days ago")
    end=$(date +"%Y-%m-%dT00:00:00")
    f="0"
    for t in StandardStorage GlacierStorage IntelligentTieringAIAStorage \
        IntelligentTieringFAStorage IntelligentTieringIAStorage GlacierS3ObjectOverhead \
        GlacierObjectOverhead;do
        size=$(aws cloudwatch get-metric-statistics --namespace AWS/S3 \
            --start-time "$start" \
            --end-time "$end" \
            --period 86400 \
            --statistics Average \
            --metric-name BucketSizeBytes \
            --dimensions Name=BucketName,Value="$bucket" Name=StorageType,Value=$t \
            | jq 'if (.Datapoints | length) > 0 then .Datapoints[0].Average else 0 end')
        f="$f+$size"
    done
    echo "($f)/1024/1024/1024/1024" | bc
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
