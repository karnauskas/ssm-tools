#!/usr/bin/env bash
set -e

# Note: make a file called "ssm-script" with your script
# This script requires execution priveleges on the  AWS-RunShellScript SSM Command

PATH_TO_SCRIPT=$1

if [[ -z "$PATH_TO_SCRIPT" ]]; then
  echo "Usage: ./ssm-poll.sh myscript.sh"
fi

# Wrap each command in quotes and commas so it can pass as an array to the aws call
COMMANDS=$(cat $PATH_TO_SCRIPT | sed -e "s/^/\"/" | sed -e "s/$/\"/" | tr "\n" "," | sed -e "s/\,$//")

OUTPUT_OPTIONS="--output-s3-bucket-name $S3_OUTPUT --output-s3-key-prefix $PATH_TO_SCRIPT"
POLLING_TIME=1

function wait_for_ssm_command() {
  command_id=$1

  # if invocation is blank
  while true
  do
    invocation=$(aws ssm list-command-invocations --command-id $command_id | jq -r '.CommandInvocations[0]')

    if [[ -z "$invocation" ]]; then
      echo "Didn't find any results for this command, sleeping until we see a result."
      sleep $POLLING_TIME
    else
      status=$(echo $invocation | jq -r '.StatusDetails')

      if [[ $status == "InProgress" ]]; then
        echo "Command in progress, waiting..."
        sleep $POLLING_TIME
      elif [[ $status == "Success" ]]; then
        echo "Success! Output: $(echo $invocation | jq -r '.StandardOutputUrl')"
        exit 0
      else
        echo "Error! Status: $status; Output at: $(echo $invocation | jq -r '.StandardErrorUrl')"
        instance_id=$(echo $invocation | jq -r '.InstanceId')

        # No slash between S3_OUTPUT and PATH_TO_SCRIPT because PATH_TO_SCRIPT already starts with one
        output=$(aws s3 cp --quiet s3://$S3_OUTPUT$PATH_TO_SCRIPT/$command_id/$instance_id/awsrunShellScript/0.awsrunShellScript/stderr /dev/stdout)

        echo "Error: $output"
        exit 1
      fi
    fi
  done
}

echo "Executing command..."
out=$(aws ssm send-command --document-name "AWS-RunShellScript" --parameters "{\"commands\":[$COMMANDS]}" --region us-east-1 $PROFILE --targets $TARGETS $OUTPUT_OPTIONS --max-errors 1)

command_id=$(echo $out | jq -r '.Command.CommandId')
wait_for_ssm_command $command_id
