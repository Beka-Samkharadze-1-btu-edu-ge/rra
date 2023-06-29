#!/bin/bash

function github_api_get_request()
{
    curl --request GET \
        --header "Accept: application/vnd.github+json" \
        --header "Authorization: Bearer $GITHUB_PERSONAL_ACCESS_TOKEN" \
        --header "X-GitHub-Api-Version: 2022-11-28" \
        --output "$2" \
        --dump-header /dev/stderr \
        --silent \
        "$1"
}

# https://docs.github.com/en/rest/search?apiVersion=2022-11-28#search-users
RESPONSE_PATH=$(mktemp)
github_api_get_request "https://api.github.com/search/users?q=roman@adontz.com" $RESPONSE_PATH

cat $RESPONSE_PATH | jq

TOTAL_USER_COUNT=$(cat $RESPONSE_PATH | jq ".total_count")

if [[ $TOTAL_USER_COUNT == 1 ]]
then
    USER_JSON=$(cat $RESPONSE_PATH | jq ".items[0]")

    echo $USER_JSON | jq

    USER_LOGIN=$(cat $RESPONSE_PATH | jq --raw-output ".items[0].login")

    echo $USER_LOGIN
else
    echo "$TOTAL_USER_COUNT users found"
fi
