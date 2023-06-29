#!/bin/bash

function jq_update()
{
    local IO_PATH=$1
    local TEMP_PATH=$(mktemp)
    shift
    cat $IO_PATH | jq "$@" > $TEMP_PATH
    mv $TEMP_PATH $IO_PATH
}

# https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#create-an-issue
REQUEST_PATH=$(mktemp)
echo "{}" > $REQUEST_PATH
echo "STEP 1"
cat $REQUEST_PATH | jq
echo "STEP 2"
jq_update $REQUEST_PATH '.title = "Title"'
echo "STEP 3"
cat $REQUEST_PATH | jq
echo "STEP 4"
rm $REQUEST_PATH
