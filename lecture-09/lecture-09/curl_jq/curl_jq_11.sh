#!/bin/bash

function github_post_request()
{
    curl --request POST \
        --header "Accept: application/vnd.github+json" \
        --header "Authorization: Bearer $GITHUB_PERSONAL_ACCESS_TOKEN" \
        --header "X-GitHub-Api-Version: 2022-11-28" \
        --header "Content-Type: application/json" \
        --dump-header /dev/stderr \
        --silent \
        --output "$3" \
        --data-binary "@$2" \
        "$1"
}

REQUEST_PATH=$(mktemp)
RESPONSE_PATH=$(mktemp)
echo "{}" > $REQUEST_PATH
# https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#create-an-issue
github_post_request "https://api.github.com/repos/btu-mit-08-2023/l08/issues" $REQUEST_PATH $RESPONSE_PATH
cat $RESPONSE_PATH | jq
rm $RESPONSE_PATH
rm $REQUEST_PATH
