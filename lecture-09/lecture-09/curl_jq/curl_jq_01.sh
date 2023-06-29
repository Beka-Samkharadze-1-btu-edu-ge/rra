#!/bin/bash

# https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-the-authenticated-user
curl --request GET \
    --header "Accept: application/vnd.github+json" \
    --header "Authorization: Bearer $GITHUB_PERSONAL_ACCESS_TOKEN" \
    --header "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/user"
