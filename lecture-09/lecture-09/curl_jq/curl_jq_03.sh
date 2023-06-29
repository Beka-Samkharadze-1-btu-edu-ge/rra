#!/bin/bash

function github_api_get_request()
{
    curl --request GET \
        --header "Accept: application/vnd.github+json" \
        --header "Authorization: Bearer $GITHUB_PERSONAL_ACCESS_TOKEN" \
        --header "X-GitHub-Api-Version: 2022-11-28" \
        --dump-header /dev/stderr \
        --silent \
        "$1"
}

# https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-the-authenticated-user
ME_JSON=$(github_api_get_request "https://api.github.com/user")

echo "BEGIN"
echo $ME_JSON
echo "END"
