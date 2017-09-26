# SSM Tools

Tools to use with amazon ssm to send commands to instances

## Setup

First, add a policy to allow an IAM user or process to execute ssm commands and
specify which commands to run on which instances. Here's an example of the
setup for running SSM commands on EMR. Note that it's pretty permissive, using the
AWS-RunShellScript command, which means the user can execute arbitrary commands.
We lock down which instances can run this by using tags.

See [terraform/example.tf](https://github.com/reverbdotcom/ssm-tools/blob/master/terraform/example.tf) for how to set up the policies for this tool to work.
We define the iam policy, but attaching that policy to an EC2 instance or IAM user is an exercise left to the reader.

## ssm-poll

The ssm-poll.sh script is designed to execute a command and then wait for its completion. It will exit with 0 if it completes successfully.

Usage:

    S3_OUTPUT=reverb-command-output \
    PROFILE="--profile profile-name" \
    TARGETS="Key=tag:example,Values=foobar Key=tag:another_tag,Values=some_value" \
    ./ssm-poll.sh ~/myscript.sh


If you don't need an IAM profile, for example if running this on an instance that already has the priveleges required, just omit it:

    ./ssm-poll.sh ~/myscript.sh
