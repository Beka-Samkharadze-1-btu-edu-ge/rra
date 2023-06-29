#!/bin/bash

# https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#create-an-issue
REQUEST_PATH=$(mktemp)
echo "{}" > $REQUEST_PATH
echo "STEP 1"
cat $REQUEST_PATH | jq
echo "STEP 2"
cat $REQUEST_PATH | jq '.title = "Title"' > $REQUEST_PATH
echo "STEP 3"
cat $REQUEST_PATH | jq
echo "STEP 4"
rm $REQUEST_PATH
