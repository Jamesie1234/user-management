#!/bin/bash
set –e

USER_STACK_NAME="UserManagementStack"
GROUP_STACK_NAME="UserGroupManagementStack"
#PROFILE="ss-prod"
ACCOUNT_ID="$ACCOUNT_ID" #"$ACCOUNT_ID" #Replace with account ID if running it locally #$ACCOUNT_ID
REGION="$REGION"   #"$REGION" #Replace with account region if running it locally #$REGION

#Create or update IAM user pipeline
if ! aws cloudformation describe-stacks --stack-name ${USER_STACK_NAME} --region ${REGION} ; then
    echo "1"
    echo "Stack ${main_pipeline_stack} does not exist... Creating the stack..."
    aws cloudformation create-stack --stack-name ${USER_STACK_NAME} --region ${REGION} --template-body file://infrastructure/user-management/iam-users/aws_capability_iam_users.yaml --capabilities CAPABILITY_NAMED_IAM
else
    echo "Updating ${USER_STACK_NAME} stack.."
    aws cloudformation deploy --stack-name ${USER_STACK_NAME} \
        --region ${REGION} \
        --template-file "infrastructure/user-management/iam-users/aws_capability_iam_users.yaml" \
        --force-upload  \
        --capabilities "CAPABILITY_NAMED_IAM" \
        --no-fail-on-empty-changeset
fi

#Create or update IAM user role stack
echo "starting ${GROUP_STACK_NAME} stack /create/update"
if ! aws cloudformation describe-stacks --stack-name ${GROUP_STACK_NAME} --region ${REGION} ; then
    echo "1"
    echo "Stack ${GROUP_STACK_NAME} does not exist... Creating the stack..."
    aws cloudformation create-stack --stack-name ${GROUP_STACK_NAME} \
        --region ${REGION} \
        --template-body file://infrastructure/user-management/iam-roles/aws_capability_iam.yaml \
        --capabilities "CAPABILITY_NAMED_IAM"
        \
else
    echo "Updating ${GROUP_STACK_NAME} stack..."
    aws cloudformation deploy \
        --region ${REGION} \
        --stack-name ${GROUP_STACK_NAME} \
        --template-file "infrastructure/user-management/iam-roles/aws_capability_iam.yaml" \
        --capabilities CAPABILITY_NAMED_IAM \
        --no-fail-on-empty-changeset \
        --force-upload
fi

