#!/bin/bash

REPOSITORY_OWNER="btu-mit-08-2023"
REPOSITORY_NAME="l09"
REPOSITORY_BRANCH="main"

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

function jq_update()
{
    local IO_PATH=$1
    local TEMP_PATH=$(mktemp)
    shift
    cat $IO_PATH | jq "$@" > $TEMP_PATH
    mv $TEMP_PATH $IO_PATH
}

REPOSITORY_PATH=$(mktemp --directory)

git clone git@github.com:${REPOSITORY_OWNER}/${REPOSITORY_NAME}.git $REPOSITORY_PATH
pushd $REPOSITORY_PATH
COMMIT_HASH=$(git rev-parse $REPOSITORY_BRANCH)
AUTHOR_EMAIL=$(git log -n 1 --format="%ae" $COMMIT_HASH)
popd
rm -rf $REPOSITORY_PATH
echo "COMMIT_HASH = $COMMIT_HASH"
echo "AUTHOR_EMAIL = $AUTHOR_EMAIL"

AUTHOR_USERNAME=""
# https://docs.github.com/en/rest/search?apiVersion=2022-11-28#search-users
RESPONSE_PATH=$(mktemp)
github_api_get_request "https://api.github.com/search/users?q=$AUTHOR_EMAIL" $RESPONSE_PATH

TOTAL_USER_COUNT=$(cat $RESPONSE_PATH | jq ".total_count")

if [[ $TOTAL_USER_COUNT == 1 ]]
then
    USER_JSON=$(cat $RESPONSE_PATH | jq ".items[0]")
    AUTHOR_USERNAME=$(cat $RESPONSE_PATH | jq --raw-output ".items[0].login")
fi

REQUEST_PATH=$(mktemp)
RESPONSE_PATH=$(mktemp)
echo "{}" > $REQUEST_PATH
DESCRIPTION="Your commit $COMMIT_HASH sucks, dude!"
jq_update $REQUEST_PATH --arg date "$(date +%A)" '.title = "Screw you, expecially on " + $date'
jq_update $REQUEST_PATH --arg description "$DESCRIPTION" '.body = "Entire https://btu.edu.ge/ regrets knowing you\n\n" + $description + "\n\nTHE BUGMAKER LOL"'
jq_update $REQUEST_PATH '.labels = ["ci-pytest", "ci-black"]'
jq_update $REQUEST_PATH --arg username "$AUTHOR_USERNAME"  '.assignees = [$username]'
# https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#create-an-issue
github_post_request "https://api.github.com/repos/${REPOSITORY_OWNER}/${REPOSITORY_NAME}/issues" $REQUEST_PATH $RESPONSE_PATH
cat $RESPONSE_PATH
cat $RESPONSE_PATH | jq ".html_url"
rm $RESPONSE_PATH
rm $REQUEST_PATH
